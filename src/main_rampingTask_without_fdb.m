% clear d;

global d;                                                                          % global variabel that contains all information

global stdData;
% take siimulation times from global variable
d.task.N_tf         = stdData.task.N_tf;
d.task.N_tr         = stdData.task.N_tr_ramps;
d.task.N_vl         = stdData.task.N_vl_ramps;
d.task.offset_tf    = stdData.task.offset_tf;
d.task.offset_tr    = stdData.task.offset_tr;
d.task.offset_vl    = stdData.task.offset_vl;

% 2 changes in comparison to main_rampingTask_with_fdb:
% 1) add following line:
feedback = 0;                                       % include feedback loop
% 2) during the second simulation step of reservoir, i.e. simulation of
% training and validation phase, choose 'feedback', 'off'

  d.task.names = {'short ramp', 'long ramp', 'long + short', 'long - short', '|input|^{1/short^2.5}'};
[ d.task.input                  ...
  d.task.feedback_targets       ... 
  d.task.readout_targets ]        = rampingTask( ...
        d.task.offset_tf + d.task.N_tf , d.task.offset_tr + d.task.N_tr + d.task.offset_vl + d.task.N_vl , ...
        'cue', [15 stdData.params.cueLength],           ... % [ cue magnitude , cue length ]
        'cueGapLengths', stdData.params.gapLengths,     ... % gap lengths bounds for training and validation, bounds for tf-phase will be 50% of it
        'rampAmplitude', [5 10],                        ...
        'rampLengths', [300 600],                       ...
        'noise', [1 10],                                ...
        'slope', 'falling',                             ...
        'targetNoise', 0.4,                             ...
        'poisson', 'off',                               ...
        'feedback', feedback );

  d.res.N_neurons                 = stdData.params.N_neurons;                                              % number of virtual nodes in reservoir (i.e. in one tau cycle)

  d.MG.exp                        = stdData.params.exp;                                                % exponent
  d.MG.input_weight               = stdData.params.input_weight;                                             % input weight
  d.MG.eta                        = stdData.params.eta;                                              % feedback weight
  d.MG.theta                      = stdData.params.theta;
  d.MG.tau_delay                  = d.MG.theta * d.res.N_neurons;                     % delay time, i.e. time for one tau cycle                    
  d.MG.T_mg                       = stdData.params.T_mg;                                              % time scale of Mackey-Glass system
  d.MG.k                          = d.MG.theta / 4;                                   % step size of the numerical dde solver. this code works only if MG.k is specified like that: devide d.MG.tau_delay / d.res.N_neurons by 3 instead or whatever natural number and it works
  d.MG.N_steps                    = round( d.MG.tau_delay / d.MG.k );                 % number of simluation steps are needed to get through one tau_delay

  d.res.input_noise               = stdData.params.input_noise;
  d.res.initial_values         	  = .01 * ones( 1, d.MG.N_steps + 1 );                % the initial values for the Mackey Glass equation
%[ d.res.input_masks               ...
%  d.res.feedback_mask ]           = subsetMasks( [2 2 1 1], [ .1 .1 .1 .1 ], 3:4, d.res.N_neurons );
%[ d.res.input_masks               ...
%  d.res.feedback_mask ]           = randomMasks( [2 2 1 1], [ .15 .15 .15 .15 ], 3:4, d.res.N_neurons );
[ d.res.input_masks               ...
  d.res.feedback_mask ]           = fullMasks( [2 2 1 1], [ .1 .1 .1 .1 ], 3:4, d.res.N_neurons );

  d.results.lag_cc = stdData.params.lag_cc;                                                              % compute correlation coefficient in range +-lag_cc


initializeReservoir;
simulateReservoir(  'T_start'   , 1, 'T_end', d.task.offset_tf + d.task.N_tf, 'feedback', 'off' );
trainOnReservoir(   'phase'     , 'teacher_forcing'     , 'ridge' , 'off' );
simulateReservoir(  'T_start'   , d.task.offset_tf + d.task.N_tf + 1, 'T_end', size( d.task.input, 2 ), 'feedback', 'off' );
trainOnReservoir(   'phase'     , 'training'            , 'ridge' , 'off' );
generateResults;