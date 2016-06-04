function createRerservoirO()

global d;

O = zeros( 1, d.MG.N_steps );
for i = 1 : d.MG.N_steps 
 	O(i) = find( d.res.theta >= i, 1 );
end

d.res.O = O;  % bind O to reservoir