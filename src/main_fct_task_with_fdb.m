clear d;

%% parameters and input

global d;                                                                            % global variabel that contains all information

global stdData;
% take siimulation times from global variable
d.task.N_tf         = stdData.task.N_tf;
d.task.N_tr         = stdData.task.N_tr;
d.task.N_vl         = stdData.task.N_vl;
d.task.offset_tf    = stdData.task.offset_tf;
d.task.offset_tr    = stdData.task.offset_tr;
d.task.offset_vl    = stdData.task.offset_vl;

feedback = 1;                                       % include feedback loop
sine = @(x) 10 * sin(x);

  d.task.names = {'feedback again', 'copy fct', 'switch between fct and 0'};
[ d.task.input                  ...
  d.task.feedback_targets       ... 
  d.task.readout_targets ]        = fctTask( ...
        d.task.offset_tf + d.task.N_tf ,     d.task.offset_tr + d.task.N_tr + d.task.offset_vl + d.task.N_vl , ...
        'cueLength', stdData.params.cueLength,             ...
        'gapLengths', stdData.params.gapLengths,    ...     % gap lengths bounds for training and validation, bounds for tf-phase will be 50% of it
        'amplitude', [0 10],        ...     % amplitude of cues
        'fct', sine,                ...
        'targetNoise', 0.5,         ...
        'past', 0,                  ...
        'feedback', feedback );

  d.res.N_neurons                 = stdData.params.N_neurons;                                              % number of virtual nodes in reservoir (i.e. in one tau cycle)

  d.MG.exp                        = stdData.params.exp;                                                % exponent
  d.MG.input_weight               = stdData.params.input_weight;                                             % input weight
  d.MG.eta                        = stdData.params.eta;    % 0.7                                     % feedback weight
  d.MG.theta                      = stdData.params.theta; %2;      % 0.7
  d.MG.tau_delay                  = d.MG.theta * d.res.N_neurons;                     % delay time, i.e. time for one tau cycle
  d.MG.T_mg                       = stdData.params.T_mg;                                                % time scale of Mackey-Glass system
  d.MG.k                          = d.MG.theta / 4;  % / 8                            % step size of the numerical dde solver. this code works only if MG.k is specified like that: devide d.MG.tau_delay / d.res.N_neurons by 3 instead or whatever natural number and it works
  d.MG.N_steps                    = round( d.MG.tau_delay / d.MG.k );                 % number of simluation steps are needed to get through one tau_delay
  
  d.res.input_noise               = stdData.params.input_noise;
  d.res.initial_values         	  = .01 * ones( 1, d.MG.N_steps + 1 );                % the initial values for the Mackey Glass equation
%[ d.res.input_masks               ...
%  d.res.feedback_mask ]           = subsetMasks( [1 1 1 2], [ .1 .1 .1 .1 ], 4, d.res.N_neurons );
%[ d.res.input_masks               ...
%  d.res.feedback_mask ]           = randomMasks( [1 1 1 2], [ .1 .1 .1 .1 ], 4, d.res.N_neurons );
[ d.res.input_masks               ...
  d.res.feedback_mask ]           = fullMasks( [1 1 1 2], [ .1 .1 .1 .1 ], 4, d.res.N_neurons );


  d.results.lag_cc = stdData.params.lag_cc;                                                              % compute correlation coefficient in range +-lag_cc

initializeReservoir;
simulateReservoir(  'T_start'   , 1, 'T_end', d.task.offset_tf + d.task.N_tf, 'feedback', 'off' );
trainOnReservoir(   'phase'     , 'teacher_forcing'     , 'ridge' , 'off' );
simulateReservoir(  'T_start'   , d.task.offset_tf + d.task.N_tf + 1, 'T_end', size( d.task.input, 2 ), 'feedback', 'on' );
trainOnReservoir(   'phase'     , 'training'            , 'ridge' , 'off' );
generateResults;