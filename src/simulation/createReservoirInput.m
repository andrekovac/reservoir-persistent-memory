function createReservoirInput()

    global d;    
    
    N_channels  = size( d.task.input, 1 );
    all_masks   = [ d.res.input_masks; d.res.feedback_mask ]';
    O           = repmat( d.res.O, N_channels, 1 );
    O           = O + d.res.N_neurons * ( 0 : N_channels - 1 )' *  ones( 1, d.MG.N_steps );
    all_masks   = all_masks( O );

    d.res.input = d.MG.input_weight *                                              ... 
                  reshape(   all_masks' * d.task.input,                            ...  
                             size( d.task.input, 2 ) * d.MG.N_steps, 1 )'  ;       ...
 
% marginally more efficient and computationally equivalent to compute input
% here instead in simulateReservoir

% der input ist teilweise schon verrauscht ist?!?! (siehe feedback target!)
    % Reservoir gets a bit distorted input (+ gaussian noise) all the time
    % (without feedback too)!! Therefore there is no more 1to1 correspondence to Johannes' code.
    d.res.input = d.res.input + d.res.input_noise * randn( 1, length( d.res.input ) );
    d.res.input = [ d.res.input 0 ];                                                            % add additional 0 for last step in simulation
    % use 'd.res.input = [ 0 d.res.input ]' instead in order to get exactly the same
    % behaviour as in the code from johannes...

end