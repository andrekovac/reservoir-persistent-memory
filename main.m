clear all

%% ------------- script to get stereotype plots ------------------

global stdData;                                  % number of inputs for all tasks

stdData.task.N_tf              = 50000;          % number of teacher forcing data
stdData.task.N_tr              = 10000;          % number of training data
stdData.task.N_vl              = 10000;          % number of validation data
stdData.task.offset_tf         = 50;             % offset (measured in nr. of data points) before teacher forcing data
stdData.task.offset_tr         = 50;             % offset (measured in nr. of data points) before test data
stdData.task.offset_vl         = 50;             % offset (measured in nr. of data points) before validation data

% rampingTask needs longer training and validation
stdData.task.N_tr_ramps        = 20000;          % number of training data for rampingTask
stdData.task.N_vl_ramps        = 20000;          % number of validation data for rampingTask


% stdData.task.N_tf              = 6000;          % number of teacher forcing data
% stdData.task.N_tr              = 3000;          % number of training data
% stdData.task.N_vl              = 3000;          % number of validation data
% stdData.task.offset_tf         = 50;             % offset (measured in nr. of data points) before teacher forcing data
% stdData.task.offset_tr         = 50;             % offset (measured in nr. of data points) before test data
% stdData.task.offset_vl         = 50;             % offset (measured in nr. of data points) before validation data
% 
% % rampingTask needs longer training and validation
% stdData.task.N_tr_ramps        = 5000;          % number of training data for rampingTask
% stdData.task.N_vl_ramps        = 5000;          % number of validation data for rampingTask



% parameters which are the same in all three experiments can be adjusted
% here for all experiments
stdData.params.cueLength        = 5;
stdData.params.gapLengths       = [100 800];

stdData.params.N_neurons        = 300;
stdData.params.exp              = 1;
stdData.params.input_weight     = .01;
stdData.params.eta              = .5;
stdData.params.theta            = 2;
stdData.params.T_mg             = 1;
stdData.params.input_noise      = .000001;

stdData.params.lag_cc           = 15;


%% Call the main-method you want with standardised values
tic
main_fct_task_with_fdb;
toc
%main_fct_task_without_fdb; 
%main_linear_nonLinearTask;
%main_rampingTask_with_fdb;
%main_rampingTask_without_fdb;

%% Plot result

% Plot task - time series / desired vs. observed / correlation
plotResults_fctTask_WITH_Fdb_TASKS;