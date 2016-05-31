function [ input_masks feedback_mask ] = subsetMasks( proportions, strengths, ind_feedback, N_neurons )
% 'proportion(i)' reflects the ratio of the non-zero elements of mask i in
% direct comparison to the other masks. 
% 'strengths' specifies the strength of the non-zero elements of a mask
% 
% example: 
% [ input_masks feedback_mask ] = subsetMasks( [ 1, 2, 3 ], [ 1 2 3], 2, 12 )
% 
% input_masks =
% 
%      1     1     0     0     0     0     0     0     0     0     0     0
%      0     0     0     0     0     0    -3    -3     3    -3     3     3
% 
% 
% feedback_mask =
% 
%      0     0    -2    -2    -2     2     0     0     0     0     0     0


global d;

% calculate the the first and last non-zero index for each mask:
ind_subs = zeros( length( proportions ) , 2 );

if length(proportions) == 1
    ind_subs = [1 d.res.N_neurons];
else
    ind_subs( 1 : end-1 , 2 )   = cumsum( floor( proportions( 1 : end-1 )' * N_neurons / sum( proportions ) ) );
    ind_subs( end , 2 )         = N_neurons;
    ind_subs( 2 : end , 1 )     = ind_subs( 1 : end-1 , 2 ) + 1;
    ind_subs( 1 , 1 )           = 1;
end

d.res.ind_subs = ind_subs;      % bind ind_subs to reservoir for plot in visualizeResults_new


masks   = zeros( length( strengths ), N_neurons );

a       = version;
        
for i = 1 : length( strengths )
            
   	N = ind_subs(i,2) - ind_subs(i,1) + 1;

   	if regexp( a(end-5:end-1 ), '201\d[ab]' ) == 1
      	masks( i, ind_subs(i,1) : ind_subs(i,2) )   = ( 2 * randi(   2, 1, N ) - 3 ) * strengths(i);        
    else
       	masks( i, ind_subs(i,1) : ind_subs(i,2) )   = ( 2 * randint( 1, N, 2 ) - 3 ) * strengths(i);
  	end;
        
end;


if ind_feedback < 1
    feedback_mask         = [];
else
    feedback_mask         = masks( ind_feedback, : );
    masks( ind_feedback, : )    = [];
end

input_masks           = masks;
   
