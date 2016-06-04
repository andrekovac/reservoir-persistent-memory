function generateResults()

global d

design_matrix_tf = designMatrix( 'teacher_forcing' );
design_matrix_tr = designMatrix( 'training' );
design_matrix_vl = designMatrix( 'validation' ); 

% targets (for better readability)
targets_tf    = d.task.feedback_targets( : , 1 + d.task.offset_tf                                                                     :  d.task.offset_tf + d.task.N_tf                                  );
targets_tr    = d.task.readout_targets(  : , 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr                                    :  d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr );
targets_tf_vl = d.task.feedback_targets( : , 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl   :  end                                                             );
targets_vl    = d.task.readout_targets(  : , 1 + d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl   :  end                                                             );

%% Feedback neuron

% for c = 1 : size( d.task.feedback_target, 1 )  % alternative
for c = 1 : size( d.res.feedback_mask, 1 )
  	% predictions
  	d.results.pred.y_pred_tf_tf(:,c)    = design_matrix_tf	*  d.reg.feedback_weights(:,c);                                                  % generate feedback-neuron predictions on teacher forcing set
   	d.results.pred.y_pred_tf_vl(:,c)    = design_matrix_vl	*  d.reg.feedback_weights(:,c);                                                  % generate feedback-neuron predictions on validation set

   	% errors
   	d.results.errors.MSE_tf_tf(c)       = MSE(  d.results.pred.y_pred_tf_tf(:,c),  targets_tf(c,:)   ,   d.task.N_tf,  'normalize', 'off');
  	d.results.errors.NRMSE_tf_tf(c)     = MSE(  d.results.pred.y_pred_tf_tf(:,c),  targets_tf(c,:)   ,   d.task.N_tf,  'normalize', 'on' );
   	d.results.errors.MSE_tf_vl(c)       = MSE(  d.results.pred.y_pred_tf_vl(:,c),  targets_tf_vl(c,:),   d.task.N_vl,  'normalize', 'off');
   	d.results.errors.NRMSE_tf_vl(c)     = MSE(  d.results.pred.y_pred_tf_vl(:,c),  targets_tf_vl(c,:),   d.task.N_vl,  'normalize', 'on' );

  	% correlation coefficient
  	d.results.correlation.CC_tf_tf(c,:) = pCor( d.results.pred.y_pred_tf_tf(:,c), targets_tf(c,:)   ,    d.results.lag_cc );
  	d.results.correlation.CC_tf_vl(c,:) = pCor( d.results.pred.y_pred_tf_vl(:,c), targets_tf_vl(c,:),    d.results.lag_cc );
end
    
%% Readout targets

for c = 1 : size( d.task.readout_targets, 1 )
  	% predictions
   	d.results.pred.y_pred_tr(:,c)    = design_matrix_tr  * d.reg.readout_weights(:,c);                                              % generate readout target predictions on training set
  	d.results.pred.y_pred_vl(:,c)    = design_matrix_vl  * d.reg.readout_weights(:,c);                                              % generate readout target predictions on validation set
        
  	% errors
  	d.results.errors.MSE_tr(c)       = MSE( d.results.pred.y_pred_tr(:,c),  targets_tr(c,:), d.task.N_tr,  'normalize', 'off');
  	d.results.errors.NRMSE_tr(c)     = MSE( d.results.pred.y_pred_tr(:,c),  targets_tr(c,:), d.task.N_tr,  'normalize', 'on' );
   	d.results.errors.MSE_vl(c)       = MSE( d.results.pred.y_pred_vl(:,c),  targets_vl(c,:), d.task.N_vl,  'normalize', 'off');
   	d.results.errors.NRMSE_vl(c)     = MSE( d.results.pred.y_pred_vl(:,c),  targets_vl(c,:), d.task.N_vl,  'normalize', 'on' );
        
   	% correlation coefficient
  	d.results.correlation.CC_tr(c,:) = pCor( d.results.pred.y_pred_tr(:,c), targets_tr(c,:), d.results.lag_cc );
   	d.results.correlation.CC_vl(c,:) = pCor( d.results.pred.y_pred_vl(:,c), targets_vl(c,:), d.results.lag_cc );
end;

end

%% Auxiliary functions

function error = MSE( prediction, target, length, varargin )    % computes MSE and NRMSE
    error = 1 / length * sum( ( prediction - target' ) .^2 );   % mean squared error
    if strcmpi(varargin{2}, 'on')
        error = sqrt( error / var(target) );                    % normalize if desired
    end
end


function r = pCor( x, y, maxLag )                               % computes pearson correlation coefficient between x,y
    r = xcov( x, y, maxLag, 'unbiased' );
    r = r ./ sqrt( var(x) * var(y) );                           % normalize cross-variance
end