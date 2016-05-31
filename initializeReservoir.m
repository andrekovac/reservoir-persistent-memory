function initializeReservoir()

global d;

d.res.R                         = zeros( 1, 1 + d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl + d.task.N_vl ) );
d.res.R( 1 : 1 + d.MG.N_steps ) = d.res.initial_values;                             

createReservoirTheta;    % indices of virtual nodes
createRerservoirO;
createReservoirInput;
