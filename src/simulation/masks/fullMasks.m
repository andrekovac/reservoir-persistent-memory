function [ input_masks feedback_mask ] = fullMasks( proportions, strengths, ind_feedback, N_neurons )
% 'proportion(i)' reflects the ratio of the non-zero elements of mask i in
% direct comparison to the other masks. 
% 'strengths' specifies the strength of the non-zero elements of a mask
% 
% example: 
% [ input_masks feedback_mask ] = createReservoirMasks( [ 1, 2, 3 ], [ 1 2 3], 2, 12 )
% 
% input_masks =
% 
%      1     1    -1     1    -1     1    -1    -1    -1     1     1    -1
%      3    -3     3     3    -3     0    -3    -3     3    -3     3     3
% 
% 
% feedback_mask =
% 
%      2     2    -2    -2    -2     2     2    -2    -2     2    -2     2

masks   = zeros( length( strengths ), N_neurons );

a       = version;
        
for i = 1 : length( strengths )

   	if regexp( a(end-5:end-1 ), '201\d[ab]' ) == 1
      	masks( i, : )   = ( 2 * randi(   2, 1, N_neurons ) - 3 ) * strengths(i);        
    else
       	masks( i, : )   = ( 2 * randint( 1, N_neurons, 2 ) - 3 ) * strengths(i);
  	end;
        
end;


if ind_feedback < 1
    feedback_mask         = [];
else
    feedback_mask         = masks( ind_feedback, : );
    masks( ind_feedback, : )    = [];
end

input_masks           = masks;