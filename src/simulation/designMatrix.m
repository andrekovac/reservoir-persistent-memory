function design_matrix = designMatrix( phase )

global d;

if strcmpi( phase , 'offset_teacher_forcing' )
    ind_start   = 1 + d.MG.N_steps;
    ind_end     =     d.MG.N_steps * ( 1 + d.task.offset_tf );
    N           = d.task.offset_tf;
end;
if strcmpi( phase , 'teacher_forcing' )
    ind_start   = 1 + d.MG.N_steps * ( 1 + d.task.offset_tf );
    ind_end     =     d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf );
    N           = d.task.N_tf;
end;
if strcmpi( phase , 'offset_training' )
    ind_start   = 1 + d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf );
    ind_end     =     d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr );
    N           = d.task.offset_tr;
end;
if strcmpi( phase , 'training' )
    ind_start   = 1 + d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr );
    ind_end     =     d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr );
    N           = d.task.N_tr;
end;
if strcmpi( phase , 'offset_validation' )
    ind_start   = 1 + d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr );
    ind_end     =     d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl );
    N           = d.task.offset_vl;
end;
if strcmpi( phase , 'validation' )
    ind_start   = 1 + d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl );
    ind_end     =     d.MG.N_steps * ( 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl + d.task.N_vl );
    N           = d.task.N_vl;
end;


R_relevant_part = d.res.R( ind_start : ind_end );
indices         = repmat( d.res.theta, N, 1 ) + repmat( ( 0 : N - 1 )', 1, d.res.N_neurons ) * d.MG.N_steps;
design_matrix   = [ ones( N, 1 ) R_relevant_part( indices ) ];

