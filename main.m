%% ----- setup -----

% make sure that your current folder is the project folder, i.e.
% 'reservoir-persistent-memory' if you cloned without renaming from Github.
% Otherwise the addpath command will not work properly.

% clear workspace
clear all
% add all subfolders to the path --> make all functions in subdirectories available
addpath(genpath(pwd));

%% ------------- main script to run all scripts ------------------

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

% General schema

% 1. Simulation
% 2. Plot task - time series / desired vs. observed / correlation


%--- Sine curve WITH feedback loop
main_fct_task_with_fdb;
plotResults_fctTask_WITH_Fdb_TASKS;

%--- Sine curve WITHOUT feeback loop - to observe the difference
%main_fct_task_without_fdb;

%--- Three tasks (linear and nonlinear target function) WITH feedback loop
%main_linear_nonLinearTask;

%--- Ramping task WITH feedback loop
%main_rampingTask_with_fdb;

%--- Ramping task WITHOUT feedback loop
%main_rampingTask_without_fdb;
