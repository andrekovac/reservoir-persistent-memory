function simulateReservoir( varargin )

global d;

N_fdb_targets = size( d.res.feedback_mask, 1 );

for i = 1:2:length(varargin)
    switch varargin{i}
    	case 'T_start'
        	T_start  = varargin{i+1};
      	case 'T_end'
          	T_end    = varargin{i+1};
       	case 'feedback'
            if strcmp( varargin{i+1}, 'on'  ) 
                feedback_weights = d.reg.feedback_weights;
                O               = repmat( d.res.O, N_fdb_targets , 1 );
                O               = O + d.res.N_neurons * ( 0 : N_fdb_targets - 1 )' *  ones( 1, d.MG.N_steps );
                if size( d.res.feedback_mask , 1 ) == 1
                    feedback_mask   = d.res.feedback_mask;
                    extra_value     = feedback_mask( 1 );
                else
                    feedback_mask   = d.res.feedback_mask';
                    extra_value     = feedback_mask( 1 , : )';
                end
                feedback_mask   = [ feedback_mask( O ) , extra_value ] * d.MG.input_weight;
            end;
           	if strcmp( varargin{i+1}, 'off' ) 
                feedback_weights = zeros( d.res.N_neurons + 1, N_fdb_targets );
                feedback_mask   = zeros( N_fdb_targets, d.MG.N_steps + 1    );
            end;
    end;
end;

k           = d.MG.k;
N_steps     = d.MG.N_steps;
eta         = d.MG.eta;
exp         = d.MG.exp;
T_mg        = d.MG.T_mg;
theta       = d.res.theta; 

input       = d.res.input( ( T_start - 1 ) * N_steps + 1 :   T_end       * N_steps + 1 );
R           = d.res.R(     ( T_start - 1 ) * N_steps + 1 : ( T_end + 1 ) * N_steps + 1 );

A =       -k/T_mg   + .5*         k^2/T_mg^2    + 1 ;
B = .5*k*eta/T_mg   - .5*eta    * k^2/T_mg^2        ;
C = .5*k*eta/T_mg                                   ;

for n = 0 : T_end - T_start
    
    hist_start      =  n * N_steps + 1;
    hist_end        = ( n + 1 ) * N_steps;
    
    R_old           =     R( hist_start : hist_end );
    I               = input( hist_start : hist_end + 1 ) + ( [ 1 R_old(theta) ] * feedback_weights ) * feedback_mask;
    
    R_old(end+1)    =     R( hist_end + 1 );
    
    for j = 1 : N_steps        
        
        R( hist_start + N_steps + j ) = A * R( hist_start + N_steps + j - 1 ) + B * (R_old(j)+I(j)) / ( 1 + (R_old(j)+I(j))^exp ) + C * (R_old(j+1)+I(j+1)) / ( 1 + (R_old(j+1)+I(j+1))^exp );

    end;

end;

d.res.R( ( T_start - 1 ) * N_steps + 1 : ( T_end + 1 ) * N_steps + 1 ) = R;