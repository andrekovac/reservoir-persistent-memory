function trainOnReservoir( varargin )

global d

for i = 1 : 2 : length( varargin )
    
    switch varargin{ i }
        
    	case 'phase'
            
            if      strcmpi( varargin{ i+1 }, 'teacher_forcing' ) 
                
                phase           = 'teacher_forcing';
                N_tasks         = size( d.task.feedback_targets , 1 );
                design_matrix   = designMatrix( 'teacher_forcing' );
                ind_start       = 1 + d.task.offset_tf;
                ind_end         =     d.task.offset_tf + d.task.N_tf;
                targets         = d.task.feedback_targets( : , ind_start : ind_end );
                
            elseif  strcmpi( varargin{ i+1 }, 'training' )
                
                phase = 'training';
                N_tasks = size( d.task.readout_targets , 1 );
                design_matrix = designMatrix( 'training' );
                ind_start       = 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr;
                ind_end         =     d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr;
                targets         =  d.task.readout_targets( : , ind_start : ind_end );
                
            end;
            
            
        case 'ridge'
            
            if strcmpi( varargin{ i+1 } , 'on'  )   ridge = 1;  end;
            if strcmpi( varargin{ i+1 } , 'off' )   ridge = 0;  end;   
            
    end;
end;


weights = zeros( 1 + d.res.N_neurons, N_tasks );

for n = 1 : N_tasks
  	if ridge
        % train with ridge regression (regularization):
       	weights( : , n )  = ridge( targets( n , : )', design_matrix( :, 2 : end ), 0.0001, 0 );
    else
        % train feedback neuron with glmfit:
      	%weights( :, n )   = glmfit( design_matrix, targets( n , : )', 'normal', 'constant', 'off' );
        weights( :, n )   = robustfit( design_matrix, targets( n , : )', 'ols', [], 'off' );
    end
end


switch phase
    case 'teacher_forcing'
        d.reg.feedback_weights  = weights;
    case 'training'
        d.reg.readout_weights   = weights;
end;

