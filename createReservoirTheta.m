function createReservoirTheta()

    global d

    N_et  = round( d.MG.N_steps / d.res.N_neurons);                                     % stepsize
    theta = N_et : N_et : d.MG.N_steps-N_et;                                            % d.MG.N_steps - 1 steps. Last one has to be d.MG.N_steps
    % add or subtract an integer smaller than N_et/2 in order to get
    % randomized theta-lengths
    a = version; 
    
    % if version is newer than and including 2010a, use randi instead of
    % randint
    if regexp( a( end-5 : end-1 ), '201\d[ab]' ) == 1
        theta = theta + randi( N_et, 1, length( theta ) )       - round( N_et / 2 );
    else
        theta = theta + randint( 1, length(theta), N_et ) + 1   - round( N_et / 2 ); 
    end
    theta = [ theta   d.MG.N_steps ];                                                   % theta consists of d.MG.N_steps - 1 steps. As last timepoint add the d.MG.N_steps'th theta

    d.res.theta = theta;

end