function [input, feedback_target, readout_targets] = fctTask(N_tf, N_tr, varargin)
% creates input and targets for a simple task that relies on long-term
% memory. The third readout-target is the important target.

% %%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%
% input 1 and 2 are cues
% input 3 is sine function
% input 4 is feedback signal

% %%%%%%%%%%%%%%%% READOUTS %%%%%%%%%%%%%%%%%%%
% readout 1 is switch between sine function and constant guided by cues

% readout_targets: [ feedback signal ; fct ; switch between fct and
% lowerBound.


for i = 1:2:length(varargin)
    switch varargin{i}
    	case 'cueLength'
        	cueLength       = varargin{i+1};
      	case 'gapLengths'
          	gapLengths      = varargin{i+1};
            minGapLength    = gapLengths(1);
            maxGapLength    = gapLengths(2);
        case 'amplitude'
            bounds          = varargin{i+1};
            lowerBound      = bounds(1);
            upperBound      = bounds(2);
        case 'fct'
            fct             = varargin{i+1};
        case 'targetNoise'
            noiseLevel      = varargin{i+1};
        case 'past'
            past            = varargin{i+1};
        case 'feedback'                 % if feedback = 1, then add additional feedback input stream, if 0 don't do it.
            feedback        = varargin{i+1};
    end;
end;

% ------------------------ Create random gaps ----------------------------
    % Use different gap Length for teacher forcing and for later training
    % and validation!!!!

    sf = 0.5;           % shrink factor of gapLength

    % teacher forcing --> half gap size
    nrGapsTempTf                                        = ceil( N_tf / (minGapLength*sf) );                                      % max + 1 possible nr of gaps
    gapsTf                                              = randi( (maxGapLength*sf) - (minGapLength*sf) + 1, 1, nrGapsTempTf ) + (minGapLength*sf) - 1;  % create random gap lengths
    gapsPosTf                                           = cumsum( gapsTf, 2 );                                                           % time points of gaps
    gapsPosTf( gapsPosTf + cueLength - 1 > N_tf )       = [];                                                                         % erase all gaps outside of timeframe

    % training and validation --> given gap size
    nrGapsTempTr                                        = ceil( N_tr / (minGapLength) );                                      % max + 1 possible nr of gaps
    gapsTr                                              = randi( maxGapLength - minGapLength + 1, 1, nrGapsTempTr ) + minGapLength - 1;  % create random gap lengths
    gapsPosTr                                           = cumsum( gapsTr, 2 );                                                           % time points of gaps
    gapsPosTr( gapsPosTr + cueLength - 1 > N_tr )       = [];                                                                         % erase all gaps outside of timeframe

    % tie tf-phase and tr & val-phase gaps positions together!
    gapsPos     = [ gapsPosTf , gapsPosTr + gapsPosTf(end) ];               
% ------------------------ ------------------- ----------------------------



% ---------------------- initialize input & targets -----------------------
input               =    lowerBound * ones( 3 + feedback ,  N_tf + N_tr );     % initialize output variables
readout_targets     =    lowerBound * ones( 1,              N_tf + N_tr );
feedback_target     =    lowerBound * ones( 1,              N_tf + N_tr );
% ------------------------ ------------------- ----------------------------



% -------------------------- add smooth_lag -------------------------------
smooth_lag          = 10;       % add this to input to avoid changes in last few time steps caused by smoothing
extra_cut           = 5;        % just to be sure, take an extra bit off

% temp for time series, function with bounded amplitude and shifted center
input3              = (fct( 1 : N_tf+ N_tr + past + (smooth_lag+extra_cut) ) * (upperBound-lowerBound)) ...
                        + (lowerBound + ( (upperBound - lowerBound) * (1/3) ) );

input3              = smoothGaussian( input3 , smooth_lag , 5 , 5 );            % smooth input3
input3              = input3( 1 : end - (smooth_lag+extra_cut) );               % truncate input3 to cut of added smooth_lag
% ------------------------ ------------------- ----------------------------


% -------------------------- manage past  ---------------------------------
input3_readouts     = input3( 1 : end-past );                           % this part will be learned
input( 3 , : )      = input3( past+1 : end );                           % cut of first few inputs
% ------------------------ ------------------- ----------------------------

readout_targets( 1 , : ) = lowerBound + ( (upperBound - lowerBound) / 2 );

for m = 1 : 2 : length(gapsPos) - 1
    input(           1, gapsPos( m )   : gapsPos( m ) + cueLength - 1   )  =  upperBound;                                           % cue 1
    input(           2, gapsPos( m+1 ) : gapsPos( m+1 ) + cueLength - 1 )  =  upperBound;                                           % cue 2
    feedback_target( 1, gapsPos( m )   : gapsPos( m+1 ) - 1             )  =  upperBound;                                           % feedback   
    readout_targets( 1, gapsPos( m )   : gapsPos( m+1 ) - 1             )  =  input3_readouts( gapsPos( m ) : gapsPos( m+1 ) - 1 ); % target 3 = switch between function and 0
end

% ----------------------- include feedback  -------------------------------
if feedback
    input( 4, : )               =   feedback_target;                                                                                % teacher forcing signal
    input( 4, : )               =   input( 4, : ) + randn( 1, size( input, 2) ) * noiseLevel;                                       % add gaussian noise
    input( 4, N_tf + 1 : end )  =   0;                                                                                              % set teacher forcing signal to 0 after training of feedback neuron
end
% ------------------------ ------------------- ----------------------------

end



%%%%%%%%%%%%%%%%%%%%%%%% Auxiliary function %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function out = smoothGaussian(in, lag, mean, stdev)
    kernel              = normpdf( [ -lag : 1 : lag ] , mean, stdev );          % gaussian kernel
    out                 = conv2(in, kernel, 'same');                            % convolve with gaussian kernel
    out( isnan(out) )   = 0;                                                    % replace NaNs by zero
end