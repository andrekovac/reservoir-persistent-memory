% close all;

global d;

% d = myData{1};

scrsz = get(0,'ScreenSize');



start = 50 + 50000 + 50 + 20000 + 50;
% stdData.task.N_tf              = 50000;          % number of teacher forcing data
% stdData.task.N_tr              = 10000;          % number of training data
% stdData.task.N_vl              = 10000;          % number of validation data
% stdData.task.offset_tf         = 50;             % offset (measured in nr. of data points) before teacher forcing data
% stdData.task.offset_tr         = 50;             % offset (measured in nr. of data points) before test data
% stdData.task.offset_vl         = 50;             % offset (measured in nr. of data points) before validation data
% 
% % rampingTask needs longer training and validation
% stdData.task.N_tr_ramps        = 20000;          % number of training data for rampingTask
% stdData.task.N_vl_ramps        = 20000;          % number of validation data for rampingTask



% inputs and desired values
input               = d.task.input;
feedback_target     = d.task.feedback_targets;
readout_targets      = d.task.readout_targets;

% targets (for better readability)
target_tf          = d.task.feedback_targets( : , d.task.offset_tf + 1                                                                     :  d.task.offset_tf + d.task.N_tf                                  );
target_tf_vl       = d.task.feedback_targets( : , d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl + 1   :  end                                                             );
target_tr          = d.task.readout_targets(  : , d.task.offset_tf + d.task.N_tf + d.task.offset_tr + 1                                    :  d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr );
target_vl          = d.task.readout_targets(  : , d.task.offset_tf + d.task.N_tf + d.task.offset_tr + d.task.N_tr + d.task.offset_vl + 1   :  end                                                             );


prediction_tf_tf    = d.results.pred.y_pred_tf_tf;
prediction_tf_vl    = d.results.pred.y_pred_tf_vl;
prediction_tr       = d.results.pred.y_pred_tr;
prediction_vl       = d.results.pred.y_pred_vl;

% transpose predictions
prediction_tf_tf    = prediction_tf_tf';
prediction_tf_vl    = prediction_tf_vl';
prediction_tr       = prediction_tr';
prediction_vl       = prediction_vl';

% correlation coefficients
pCor_tf_tf          = d.results.correlation.CC_tf_tf;
pCor_tf_vl          = d.results.correlation.CC_tf_vl;
pCor_tr             = d.results.correlation.CC_tr;
pCor_vl             = d.results.correlation.CC_vl;

% NRMSE
NRMSE_tf_tf         = d.results.errors.NRMSE_tf_tf;
NRMSE_tf_vl         = d.results.errors.NRMSE_tf_vl;
NRMSE_tr            = d.results.errors.NRMSE_tr;
NRMSE_vl            = d.results.errors.NRMSE_vl;



% --------------------- plot parameters ----------------------
figure(6)
set( 6, 'Position', [ scrsz(3)/5    170         scrsz(3)*0.55       300         ] );
%                   [ left          bottom      width               height       ]

rTotal = 8;
cTotal = 14;

rPlot  = 8;
rSmall = 2;
% --------------------- plot parameters ----------------------



% -------- Task number ----------
taskNr = 1;
% -------- Task number ----------


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------------ main plot --------------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
area = [];
for i = 0:2
    area = [ area , (i*cTotal)+1 : (i*cTotal) + rPlot ];
end
subp1 = subplot( rTotal , cTotal ,        area );

time = start + 2000 : start + 7000;
%time = 3000:6000;
y = input(end-1:-1:1, time)';

%plot(time, input(end-1:-1:1, time)', 'Linewidth', 2);

hold on
plot( time, input(2,time),'Color', 'blue', 'LineWidth',1);     % arb
plot( time, input(1,time), 'Color', 'green', 'LineWidth',2);     % cue
hold off


% ======================== THINGS TO CHANGE ==============================
title( '\bfinput', 'fontsize', 12 );           % ------------ title 
%xlabel( 'time', 'fontsize', 10 ); 

% ----- uncomment this for no labels on bottom!!! + xlabel weg --------
set(gca,'XTickLabel','');

yMargin  = ( max( max(input) ) - min( min(input) ) ) / 15;
% ======================== ================ ==============================



legend( 'u^{arb}', 'u^+',   'Location', 'West');
%ylabel('desired/observed value', 'fontsize', 10);

set(gca, 'FontSize', 8 );

xMargin  = 0;  % set axis around given data points within a certain margin

%yMarginTop  = 0;   yMarginBottom = 0.5; 
axis( [ min( time ) - xMargin      max( time ) + xMargin     ...
        min( min(input) ) - yMargin      max( max(input) ) + yMargin] );
% ------------------------ ----------------------- ------------------------


% gap = 2;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ---------------------- diagonal - pred vs. observed ---------------------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot( rTotal , cTotal ,        [ rPlot+gap:rPlot+gap+rSmall, cTotal+rPlot+gap:cTotal+rPlot+gap+rSmall ] )
% plot( prediction_tf_tf( taskNr , time ) , target_tf( taskNr , time ) , '.', 'Color', [ 241/255 225/255 10/255 ] , 'LineWidth', 0.5);
% hold on
% plot( prediction_tf_vl( taskNr , time ) , target_tf_vl( taskNr , time ) , '.', 'Color', [ 143/255 100/255 0 ] , 'LineWidth', 0.5);
% hold off
% title( '\bfdesired vs. observed' , 'fontsize', 10 );
% %xlabel( 'y_{pred}', 'fontsize', 10 );   
% %ylabel( 'y', 'fontsize' , 10 );
% %set(gca,'XTickLabel','', 'FontSize', 8 );
% set(gca, 'FontSize', 8 );
% %margin  = 0.8;  % set axis around given data points within a certain margin
% margin  = ( max( prediction_tf_vl( taskNr , time )  ) - min( prediction_tf_vl( taskNr , time )  ) ) / 10;
% axis( [ min( prediction_tf_vl( taskNr , time )  ) - margin      max( prediction_tf_vl( taskNr , time )  ) + margin     ...
%         min( prediction_tf_vl( taskNr , time )  ) - margin      max( prediction_tf_vl( taskNr , time )  ) + margin] );
% 
% grid;
%     
% % ------------------------ ----------------------- ------------------------
% 
% 
% 
% 
% 
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ------------------------ correlation coefficient ------------------------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot( rTotal , cTotal ,        [ 3*cTotal+rPlot+gap:3*cTotal+rPlot+gap+rSmall, 4*cTotal+rPlot+gap:4*cTotal+rPlot+gap+rSmall ] )
% lag = -d.results.lag_cc   :   1 :   d.results.lag_cc;
% plot( lag , pCor_tf_tf(taskNr,:) , 'Color', [ 241/255 225/255 10/255 ] , 'Linewidth', 1 );
% hold on
% plot( lag , pCor_tf_vl(taskNr,:) , 'Color', [ 143/255 100/255 0 ] , 'Linewidth', 1 );
% hold off
% title( '\bfcorrelation', 'fontsize', 10 );
% %xlabel( 'lag', 'fontsize' , 10 );       
% %ylabel( 'r(y,y_{pred})', 'fontsize', 10 );
% 
% set(gca, 'FontSize', 8 );
% %set(gca, 'XTick', -d.results.lag_cc   :   5 :   d.results.lag_cc)
% 
% % ----- uncomment this for no labels on bottom!!! + xlabel weg --------
% set(gca,'XTickLabel','');
% grid;
% 
% legend( 'training', 'validation',   'Location', 'West');
% 
% xMargin  = 0;  % set axis around given data points within a certain margin
% %yMarginTop  = ;
% yMarginBottom  = 0.05;
% axis( [ -d.results.lag_cc - xMargin          d.results.lag_cc + xMargin                   ...
%         min( pCor_tf_vl(taskNr,:) ) - yMarginBottom         1.01 ] );
%     %        min( pCor_vl(taskNr,:) ) - yMarginBottom   max( pCor_vl(taskNr,:)      ) + yMarginTop] );
% 
% % ------------------------ ----------------------- ------------------------
% 
% 
% 
% 
% 
% 
% 
% 
% gap2 = 1;
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% % ------------------------- NRMSE in bar diagram  -------------------------
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% subplot( rTotal , cTotal ,        [ rPlot+gap+rSmall+gap2+1:rPlot+gap+rSmall+gap2+1,                    cTotal+rPlot+gap+rSmall+gap2+1:cTotal+rPlot+gap+rSmall+gap2+1 , ...
%                                     2*cTotal+rPlot+gap+rSmall+gap2+1:2*cTotal+rPlot+gap+rSmall+gap2+1,                                                      ...
%                                     3*cTotal+rPlot+gap+rSmall+gap2+1:3*cTotal+rPlot+gap+rSmall+gap2+1,  4*cTotal+rPlot+gap+rSmall+gap2+1:4*cTotal+rPlot+gap+rSmall+gap2+1 ] )
% 
% y = [ NRMSE_tf_tf( taskNr ), NRMSE_tf_vl( taskNr ) ];
% bar( 1 , y(1) , 'FaceColor', [ 241/255 225/255 10/255 ], 'BarWidth', 1, 'LineWidth', 0.2);
% hold on
% bar( 2 , y(2) , 'FaceColor', [ 143/255 100/255 0 ], 'BarWidth', 1, 'LineWidth', 0.2);
% hold off
% 
% title( '\bfNRMSE', 'fontsize', 10 );
% 
% % ----- uncomment this for no labels on bottom!!! + XTickLabel weg --------
%  set(gca,'XTickLabel','');
% set(gca, 'FontSize', 8 );
% %set(gca, 'XTick', [1,2])
% %set(gca, 'XTickLabel',{'tr','vl'})
% 
% 
% xMargin         = 0.5;  % set axis around given data points within a certain margin
% yMarginTop      = max(y) / 10 ;
% yMarginBottom   = 0;
% axis( [ 1 - xMargin      2 + xMargin     ...
%         0 - yMarginBottom      max( y ) + yMarginTop ] );
% 
% text( 1 , max(y) / 3 , num2str(NRMSE_tf_tf(taskNr)) , 'FontSize' , 8 ,'rotation',90);
% text( 2 , max(y) / 3 , num2str(NRMSE_tf_vl(taskNr)) , 'FontSize' , 8 ,'rotation',90);
% % ------------------------ ----------------------- ------------------------

