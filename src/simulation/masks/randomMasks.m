function [ input_masks feedback_mask ] = randomMasks( proportions, strengths, ind_feedback, N_neurons )
% 'proportion(i)' reflects the ratio of the non-zero elements of mask i in
% direct comparison to the other masks. 
% 'strengths' specifies the strength of the non-zero elements of a mask
% 
% example: 
% [ input_masks feedback_mask ] = randomMasks( [ 1, 2, 3 ], [ 1 2 3], 2, 12 )
% 
% input_masks =
% 
%      1     0     0     0     0     0     0     1     0     0     0     0
%      0    -3     3     0     3     3    -3     0     0     0     3     0
% 
% 
% feedback_mask =
% 
%      0     0     0    -2     0     0     0     0     2    -2     0    -2

masks   = zeros( length( strengths ), N_neurons );

if length(proportions) == 1
    
    masks = ( 2 * randi( 2, 1, N_neurons ) - 3 ) * strengths;
    
else
    gaps = floor ( cumsum( N_neurons * proportions( 1:end-1 ) / sum(proportions) ) );
    gaps = [ 0 ,  gaps , N_neurons ];
    ind = randperm( N_neurons );

    for i = 1 : length( proportions )
        masks( i , ind ( gaps(i) + 1 : gaps(i+1) ) )  = ( 2 * randi( 2, 1, gaps(i+1) - gaps(i) ) - 3 ) * strengths(i);    
    end
    
end


if ind_feedback < 1
    feedback_mask         = [];
else
    feedback_mask         = masks( ind_feedback, : );
    masks( ind_feedback, : )    = [];
end

input_masks           = masks;
   
