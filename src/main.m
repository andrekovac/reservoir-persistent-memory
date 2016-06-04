%% ------------- Setup ------------------

% make sure that your current folder is the src folder inside the project folder, i.e.
% 'reservoir-persistent-memory/src' if you cloned without renaming from Github.
% Otherwise the addpath command will not work properly.

% clear workspace
clear all
% add all subfolders to the path --> make all functions in subdirectories available
addpath(genpath(pwd));

%% ------------- Parameters ------------------

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
% 2. Plots - time series / desired vs. observed / correlation

%% Sine curve WITH feedback loop
main_fct_task_with_fdb;
close all;  % Matlab sometimes needs to take a deep breath
pause(0.1)
fctTask_WITH_Fdb_plot_task;
fctTask_WITH_Fdb_plot_task_zoom;
fctTask_WITH_Fdb_plot_feedback_function;
fctTask_plot_input;

%% Sine curve WITHOUT feeback loop (to observe the failing of the task)
% main_fct_task_without_fdb;
% close all
% pause(0.1)
% fctTask_WITHOUT_Fdb_plot_task;
% fctTask_WITHOUT_Fdb_plot_task_zoom;
% fctTask_plot_input;

%% Three tasks (linear and nonlinear target function) WITH feedback loop
% main_linear_nonLinearTask;         % with feedback loop
% close all
% pause(0.1)
% linearTask_WITH_Fdb_plot_task1;
% linearTask_WITH_Fdb_plot_task2;
% linearTask_WITH_Fdb_plot_task3;
% linearTask_plot_feedback_function;
% linearTask_plot_input;

%% Ramping task WITH feedback loop
% main_rampingTask_with_fdb;
% close all
% pause(0.1)
% rampTask_WITH_Fdb_plot_task1;
% rampTask_WITH_Fdb_plot_task2;
% rampTask_WITH_Fdb_plot_task3;
% rampTask_WITH_fdb_feedback_function1;
% rampTask_WITH_fdb_feedback_function2;
% rampTask_plot_input;

%% Ramping task WITHOUT feedback loop (to observe the failing of the task)
% main_rampingTask_without_fdb;
% close all
% pause(0.1)
% rampTask_WITHOUT_Fdb_plot_task1;
% rampTask_plot_input;