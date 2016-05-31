function [input, feedback_targets, readout_targets] = rampingTask( N_tf, N_tr, varargin )

% %%%%%%%%%%%%%%%% INPUT %%%%%%%%%%%%%%%%%%%
% input 1 is cue signal
% input 2 is arbitrary noise signal
% input 3 and 4 are two feedback signals

% %%%%%%%%%%%%%%%% FEEDBACK TARGETS %%%%%%%%%%%%%%%%%%%
% feedback target 1 is short ramp
% feedback target 2 is long ramp

% %%%%%%%%%%%%%%%% READOUTS %%%%%%%%%%%%%%%%%%%
% readout 1 is short ramp + long ramp
% readout 2 is short ramp - long ramp
% readout 3 is complicated non-linear manipulation of ramps, i.e.
%           |noise|^(-2.5*short ramp)


% |---- cueGapLengths ----||------ rising/falling ------||-- rampLengths(2)+(maxGapLength-minGapLength) --||---- cueGapLengths ----| ...

%%% Example call of function (amplitude and cueLength as in Yoshi's paper):
%   [ input, feedback_targets, readout_targets ]  = rampingTask( 10000 , 15000 , 'cue', [200 50],   'cueGapLengths', [100 400],   'rampAmplitude', [0 200],    'rampLengths', [400 600],    'noise', 10,    'slope', 'falling',     'targetNoise', 0.8,    'poisson', 'off',    'scaling', 1,     'plot', 'on' );


for i = 1:2:length(varargin)
    switch varargin{i}
    	case 'cue'
            cueAmplitude    = varargin{i+1}(1);
        	cueLength       = varargin{i+1}(2);
      	case 'cueGapLengths'
          	gapLengths      = varargin{i+1};
            minGapLength    = gapLengths(1);
            maxGapLength    = gapLengths(2);
        case 'rampAmplitude'
            rampAmplitude   = varargin{i+1};
        case 'rampLengths'
            rampLengths      = varargin{i+1};
        case 'noise'
            noise           = varargin{i+1};
        case 'slope'
            if      strcmpi( varargin{i+1}, 'rising'  )
                slope = 1;
            elseif  strcmpi( varargin{i+1}, 'falling' )
                slope = -1;
            end
        case 'targetNoise'                              % disrupt target for teacher forcing with some gaussian noise
            noiseLevel      = varargin{i+1};
        case 'poisson'
            if      strcmpi( varargin{i+1}, 'on'  )
                poisson = 1;
            elseif  strcmpi( varargin{i+1}, 'off'  )
                poisson = 0;
            end
        case 'feedback'                 % if feedback = 1, then add 2 additional feedback input streams, if 0 don't do it.
            feedback        = varargin{i+1};
    end;
end;

% ---------------------- initialize input & feedback targets --------------
input               = rampAmplitude( 1 ) * ones( 2 + 2*feedback , N_tf + N_tr );                                          % 2 inputs + 2 teacher forcing signals
feedback_targets    = rampAmplitude( abs(slope + 0.5) + 0.5 ) * ones( 2, N_tf + N_tr );
% ------------------------ ------------------- ----------------------------

% ------------------------ Create random gaps ----------------------------
largeRampLength          = rampLengths(2);
%gapsPos             = createRandomGaps( N_tf + N_tr, minGapLength, maxGapLength, cueLength, rampLength);    % create gaps for cue, i.e. ramp onset
gapsPos             = createRandomGaps( N_tf , N_tr, minGapLength, maxGapLength, cueLength, largeRampLength);    % create gaps for cue, i.e. ramp onset
rampStart           = [ 0 , rampAmplitude(2) - rampAmplitude(1) ];
% ------------------------ ------------------- ----------------------------

for m = 1 : length(gapsPos) - 1
    input( 1, gapsPos( m ) : gapsPos( m ) + cueLength - 1 )  =  cueAmplitude;                              	% cue signal
    feedback_targets( 1, gapsPos( m ) : gapsPos( m ) + rampLengths(1) - 1 ) = ( rampStart( abs(slope - 0.5) + 0.5 ) + rampAmplitude( 1 ) ) * ones( 1, rampLengths(1) ) + slope * linspace( 1, rampAmplitude( 2 ) - rampAmplitude( 1 ), rampLengths(1) );  % ind is 1 if slope = 1 and 2 if slope = -1
    feedback_targets( 2, gapsPos( m ) : gapsPos( m ) + rampLengths(2) - 1 ) = ( rampStart( abs(slope - 0.5) + 0.5 ) + rampAmplitude( 1 ) ) * ones( 1, rampLengths(2) ) + slope * linspace( 1, rampAmplitude( 2 ) - rampAmplitude( 1 ), rampLengths(2) );
end

% -------------------------- add smooth_lag -------------------------------
smooth_lag                  = 10;       % add this to input to avoid changes in last few time steps caused by smoothing
extra_cut                   = 5;        % just to be sure, take an extra bit off

input2                      = ( noise(1) + rampAmplitude(1) ) * ones( 1, N_tf + N_tr + (smooth_lag+extra_cut) );                    	% noise baseline
input2                      = input2 + randn( 1, length(input2) ) * noise(2);                      % randomize noise
input2                      = smoothGaussian( input2, smooth_lag, 5, 5 );


input( 2, : )               = input2( 1 : end - (smooth_lag+extra_cut) );               % cut of added smooth_lag

% ------------------------ ------------------- ----------------------------




% ----------------------- include feedback  -------------------------------
if feedback
    input( 3:4, : )             = feedback_targets;                                                             % teacher forcing signal
    input( 3:4, : )             = input( 3:4, : ) + randn( 2, size( input, 2 ) ) * noiseLevel;                	% randomize teacher forcing signal
    input( 3:4, N_tf + 1 : end) = 0;                                                                         	% set teacher forcing signal to zero after feedback neuron training phase
end
% ------------------------ ------------------- ----------------------------



% ----------------------- readout targets ---------------------------------
readout_targets             = zeros( 3 , N_tf + N_tr );
%%%%%%%%%%%% do something with feedback signal
readout_targets( 1 , : )    = feedback_targets( 2 , : ) + feedback_targets( 1 , : );
readout_targets( 2 , : )    = feedback_targets( 2 , : ) - feedback_targets( 1 , : );
readout_targets( 3 , : )    = abs( input( 2 , : ) ) .^ ( 1 ./ ( feedback_targets( 1 , : ) ).^2.5 );
% ------------------------ ------------------- ----------------------------



% add poisson noise and smooth with gaussian kernel. From a biological
% standpoint it is not very realistic to randomize data after calculation.
% But the code would get ugly, i.e. one more for loop when I want to
% randomize data before generation of targets.
if poisson
    input               = poissNoisePlusSmooth( input,            15, 1, 6 );
    feedback_targets    = poissNoisePlusSmooth( feedback_targets, 15, 1, 6 );
    readout_targets     = poissNoisePlusSmooth( readout_targets,  15, 1, 6 );
end

    
end



%%%%%%%%%%%%%%%%%%%%%%%% Auxiliary functions %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function gapsPos = createRandomGaps( N_tf , N_tr, minGapLength, maxGapLength, cueLength, largeRampLength)
    
    sf = 0.5;           % shrink factor of gapLength
    % teacher forcing --> half gap size
    nrGapsTempTf                                        = ceil( N_tf / (minGapLength*sf) );                                      % max + 1 possible nr of gaps
    gapsPosTf                                           = randi( (maxGapLength*sf) - (minGapLength*sf) + 1, 1, nrGapsTempTf ) + (minGapLength*sf) - 1;  % create random gap lengths
    plateauTf                                           = 0; %round( (largeRampLength*sf)/5 );                                      % shorter plateau
    %                                                     gaps               + cumsum( largeRampLength + (maxGap-minGap) + plateau )
    gapsPosTf( 2:end )                                  = gapsPosTf( 2:end ) + cumsum( ( largeRampLength + ( maxGapLength*sf - minGapLength*sf ) + plateauTf ) * ones( 1, size(gapsPosTf, 2) - 1 )    , 2 );    % gap + asure that a gap is at least size of larger ramp + some plateau time
    gapsPosTf( gapsPosTf + cueLength - 1 > N_tf )       = [];                                                                         % erase all gaps outside of timeframe

    % training and validation --> given gap size
    nrGapsTempTr                                        = ceil( N_tr / (minGapLength) );                                      % max + 1 possible nr of gaps
    gapsPosTr                                           = randi( maxGapLength - minGapLength + 1, 1, nrGapsTempTr ) + minGapLength - 1;  % create random gap lengths
    plateauTr                                           = 0; %round( largeRampLength/5 );    
    gapsPosTr( 2:end )                                  = gapsPosTr( 2:end ) + cumsum( ( largeRampLength + (maxGapLength - minGapLength) + plateauTr ) * ones( 1, size(gapsPosTr, 2) - 1 ) , 2 );    % asure that a gap is at least size of larger ramp + some plateau time
    gapsPosTr( gapsPosTr + cueLength - 1 > N_tr )       = [];                                                                         % erase all gaps outside of timeframe

    % tie tf-phase and tr & val-phase gaps positions together!
    gapsPos     = [ gapsPosTf , gapsPosTr + gapsPosTf(end) ];
end


function out = poissNoisePlusSmooth(in, lag, mean, stdev)
    out                 = poissrnd(in);                                         % poissonize one or high dimensional input
    kernel              = normpdf( -lag : 1 : lag , mean, stdev );              % gaussian kernel
    out                 = conv2(out, kernel, 'same');                           % convolve with gaussian kernel
    out( isnan(out) )   = 0;                                                    % replace NaNs by zero
end

function out = smoothGaussian(in, lag, mean, stdev)
    kernel              = normpdf( [ -lag : 1 : lag ] , mean, stdev );          % gaussian kernel
    out                 = conv2(in, kernel, 'same');                            % convolve with gaussian kernel
    out( isnan(out) )   = 0;                                                    % replace NaNs by zero
end