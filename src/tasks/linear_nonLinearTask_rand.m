function [input, feedback_target, readout_targets] = linear_nonLinearTask_rand( N_tf, N_tr , varargin )

% %%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%
% input 1 and 2 are cues
% input 3 and 4 are arbitrary signals
% input 5 is feedback signal

% %%%%%%%%%%%%%%%% READOUTS %%%%%%%%%%%%%%%%%%%
% readout 1 is switch between input 3 and constant * input 3
% readout 2 is switch between input3 + input4 and |input3 - input4|
% readout 3 is complicated non-linear manipulation of signals 3 and 4, i.e.
%              input3^3/10 + 0.2 * (input3 * input4)

for i = 1:2:length(varargin)
    switch varargin{i}
    	case 'cueLength'
        	cueLength       = varargin{i+1};
      	case 'gapLengths'
          	gapLengths      = varargin{i+1};
            minGapLength    = gapLengths(1);
            maxGapLength    = gapLengths(2);
        case 'amplitude_12'
            bounds12        = varargin{i+1};
            burst           = bounds12(2);
        case 'amplitude_34'
            bounds34        = varargin{i+1};
        case 'amplitude_tf'
            boundsTF        = varargin{i+1};
            teacherForcing  = boundsTF(2);
        case 'targetNoise'
            noiseLevel      = varargin{i+1};
        case 'poisson'
            if      strcmpi( varargin{i+1}, 'on'  )
                poisson = 1;
            elseif  strcmpi( varargin{i+1}, 'off'  )
                poisson = 0;
            end
    end;
end;


% ---------------------- initialize input & targets -----------------------
input               =    ones( 5, N_tf + N_tr );                                                                 % initialize output variables
readout_targets     =    ones( 3, N_tf + N_tr );
feedback_target     =    ones( 1, N_tf + N_tr );
% ------------------------ ------------------- ----------------------------



% -------------------------- add smooth_lag -------------------------------
smooth_lag      = 10;       % add this to input to avoid changes in last few time steps caused by smoothing
extra_cut       = 5;        % just to be sure, take an extra bit off

amp = 10;                                   % amplitude for random values
% random values
input3          = amp * 2 * ( rand( 1 , N_tf + N_tr + smooth_lag + extra_cut ) - 0.5 ) + bounds34(1);
input4          = amp * 2 * ( rand( 1 , N_tf + N_tr + smooth_lag + extra_cut ) - 0.5 ) + bounds34(2);

input3          = smoothGaussian( input3 , smooth_lag, 0, 5 );
input4          = smoothGaussian( input4 , smooth_lag, 0, 5 );

input3          = input3( 1 : end - (smooth_lag+extra_cut) );               % cut off added smooth_lag
input4          = input4( 1 : end - (smooth_lag+extra_cut) );               % cut off added smooth_lag

input( 3 , : )  = input3;
input( 4 , : )  = input4;
% ------------------------ ------------------- ----------------------------


readout_targets(1,:)    =    input( 4 , : );

% ------------------------- Create random gaps ----------------------------
%gapsPos         = createRandomGaps( N_tf + N_tr, minGapLength, maxGapLength, cueLength );                                 % gaps for inputs 1 and 2
gapsPos         = createRandomGaps( N_tf , N_tr, minGapLength, maxGapLength, cueLength );                                 % gaps for inputs 1 and 2


for m = 2 : 2 : length(gapsPos) - 1
    input(           1, gapsPos( m )   : gapsPos( m )   + cueLength - 1 )  =  burst;                                          % cue 1
    input(           2, gapsPos( m+1 ) : gapsPos( m+1 ) + cueLength - 1 )  =  burst;                                          % cue 2
    
    feedback_target( 1, gapsPos( m )   : gapsPos( m+1 ) - 1             )  =  teacherForcing;                                       % teacher forcing signal
    
    readout_targets( 1, gapsPos( m )   : gapsPos( m+1 ) - 1             )  =  2 * input( 3, gapsPos( m ) : gapsPos( m+1 ) - 1 );                                                % amplification target - switch between 2*r3 and r3
    readout_targets( 2, gapsPos( m )   : gapsPos( m+1 ) - 1             )  =  input( 3, gapsPos( m ) : gapsPos( m+1 ) - 1 ) + input( 4, gapsPos( m ) : gapsPos( m+1 ) - 1 );    % sum and subtraction target - switch between r3+r4 and |r3-r4|
    readout_targets( 2, gapsPos( m-1 ) : gapsPos( m )   - 1             )  =  abs( input( 3, gapsPos( m-1 ) : gapsPos( m ) - 1 ) - input( 4, gapsPos( m-1 ) : gapsPos( m ) - 1 ) );
end

% --------------------------- fill last gap -------------------------------
readout_targets( 2, gapsPos( end )     : end                            )  =  abs( input( 3, gapsPos( end ) : end ) - input( 4, gapsPos( end ) : end ) );

% - readout target 3 - complicated non-linear manipulation without switch -
readout_targets( 3, : )     =   ( input( 3, : ) .^3 ) / 10 + 0.2 * ( input( 4, : ) .* input( 3 , :) );                                                                         % feedback neuron target equals first readout target

input( 5, : )               =   feedback_target;                                                                              % teacher forcing signal
input( 5, : )               =   input( 5, : ) + randn( 1, size( input, 2 ) ) * noiseLevel;                                         % add gaussian noise
input( 5, N_tf + 1 : end )  =   0;                                                                                                 % set teacher forcing signal to 0 after training of feedback neuron

% add poisson noise and smooth with gaussian kernel. From a biological
% standpoint it is not very realistic to randomize data after calculation.
% But the code would get ugly, i.e. one more for loop when I want to
% randomize data before generation of targets.
if poisson
    input           = poissNoisePlusSmooth( input,           40, 0.5, 20 );
    feedback_target = poissNoisePlusSmooth( feedback_target, 40, 0.5, 20 );
    readout_targets = poissNoisePlusSmooth( readout_targets, 40, 0.5, 20 );
end
    
end



%%%%%%%%%%%%%%%%%%%%%%%% Auxiliary functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gapsPos = createRandomGaps( N_tf, N_tr, minGapLength, maxGapLength, cueLength )
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
    
    
    gapsPos = [ 1 gapsPos ];                                                                                                        % include gap from 1 to first random gapLength
end

function out = poissNoisePlusSmooth(in, lag, mean, stdev)
    out = poissrnd(in);                                                         % poissonize one or high dimensional input
    out = smoothGaussian( out , lag , mean , stdev );
end

function out = smoothGaussian(in, lag, mean, stdev)
    kernel              = normpdf( [ -lag : 1 : lag ] , mean, stdev );          % gaussian kernel
    out                 = conv2(in, kernel, 'same');                            % convolve with gaussian kernel
    out( isnan(out) )   = 0;                                                    % replace NaNs by zero
end
