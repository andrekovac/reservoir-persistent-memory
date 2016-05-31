close all;

% Windows
%load('.\simulation_results\stereotyp_fct_task_WITH_fdb_data.mat')
% Linux
%load('./simulation_results/stereotyp_fct_task_WITH_fdb_data.mat')

global d;

%d = myData{1};

scrsz = get(0,'ScreenSize');

% inputs and desired values
input               = d.task.input;
feedback_target     = d.task.feedback_targets;
readout_target      = d.task.readout_targets;

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
% set papersize for saving the figure as a pdf - A4 landscape
figure( 'PaperSize',[29.68 20.98], ...
        'Position', [ scrsz(3)/5    170         1054       300         ] );
%                   [ left          bottom      width               height ]

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
for i = 0:4
    area = [ area , (i*cTotal)+1 : (i*cTotal) + rPlot ];
end
subp1 = subplot( rTotal , cTotal ,        area );

time = 2000:5000;
y = input(end-1:-1:1, time)';

%plot(time, input(end-1:-1:1, time)', 'Linewidth', 2);

plot( time , target_vl( taskNr , time ), 'Color', [ 36/255 92/255 211/255 ] , 'LineWidth', 1);
hold on
plot( time , prediction_vl( taskNr , time ), 'Color', [ 1 92/255 23/255 ] , 'LineWidth', 1);
hold off


% ======================== THINGS TO CHANGE ==============================
title( '\bfExperiment 1 - with feedback loop', 'fontsize', 12 );           % ------------ title 
xlabel( 'time', 'fontsize', 10 ); 
ylabel('activity', 'fontsize', 10);

% ----- uncomment this for no labels on bottom!!! + xlabel weg --------
%set(gca,'XTickLabel','');

yMargin  = ( max( target_vl( taskNr , time ) ) - min( target_vl( taskNr , time ) ) ) / 10;
% ======================== ================ ==============================



legend( 'desired', 'observed',   'Location', 'West');
%ylabel('desired/observed value', 'fontsize', 10);

set(gca, 'FontSize', 8 );

xMargin  = 0;  % set axis around given data points within a certain margin

%yMarginTop  = 0;   yMarginBottom = 0.5; 
axis( [ min( time ) - xMargin      max( time ) + xMargin     ...
        min( target_vl( taskNr , time ) ) - yMargin      max( target_vl( taskNr , time ) ) + yMargin] );
% ------------------------ ----------------------- ------------------------


gap = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------- diagonal - pred vs. observed ---------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot( rTotal , cTotal ,        [ rPlot+gap:rPlot+gap+rSmall, ...
                                    cTotal+rPlot+gap:cTotal+rPlot+gap+rSmall, ...
                                    2*cTotal+rPlot+gap:2*cTotal+rPlot+gap+rSmall, ...
                                    3*cTotal+rPlot+gap:3*cTotal+rPlot+gap+rSmall, ...
                                    4*cTotal+rPlot+gap:4*cTotal+rPlot+gap+rSmall ] )

margin  = ( max( prediction_tr( taskNr , time )  ) - min( prediction_tr( taskNr , time )  ) ) / 10;

% dash margins
m1 = min( prediction_tr( taskNr , time )  ) - 3*margin;
m2 = max( prediction_tr( taskNr , time )  ) + 3*margin;
% dashes
dash_gap = (m2-m1) * 1.2;                   % apply nice gap-dash ratio from rampTask 3
dash_gap = round(dash_gap * 1000) / 1000;   % round to three decimal places
dash = (m2-m1) * 0.75;                      % apply nice gap-dash ratio from rampTask 3
dash = round(dash * 1000) / 1000;           % round to three decimal places

hold on
    % create dashline with function dashline from MathWorks
    diagonal = dashline([  m1 , m2 ] , [  m1 , m2 ], dash_gap,dash,dash_gap,dash,'Color', [ 70/255 70/255 70/255 ] , 'LineWidth', 1.5);
    
    plot( target_tr( taskNr , time ) , prediction_tr( taskNr , time ) , '.', 'Color', [ 241/255 225/255 10/255 ] , 'LineWidth', 0.5);
    plot( target_vl( taskNr , time ) , prediction_vl( taskNr , time ) , '.', 'Color', [ 143/255 100/255 0 ] , 'LineWidth', 0.5);
hold off

% change legend entries, i.e. omit entry of diagonal
set(get(get(diagonal, 'Annotation'), 'LegendInformation'), 'IconDisplayStyle', 'off');

%title( '\bfdesired vs. observed' , 'fontsize', 10 );
xlabel( 'desired', 'fontsize', 10 );   
ylabel( 'observed', 'fontsize' , 10 );
%set(gca,'XTickLabel','', 'FontSize', 8 );
set(gca, 'FontSize', 8 );

axis( [ min( prediction_vl( taskNr , time )  ) - margin      max( prediction_vl( taskNr , time )  ) + margin     ...
        min( prediction_vl( taskNr , time )  ) - margin      max( prediction_vl( taskNr , time )  ) + margin] );

grid;
axis square
box on          % display frame around plot
legend( 'training', 'validation',   'Location', 'West');

% ------------------------ ----------------------- ------------------------



gap2 = 1;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ------------------------- Correlation in bar diagram  -------------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot( rTotal , cTotal ,        [ rPlot+gap+rSmall+gap2+1:rPlot+gap+rSmall+gap2+1,                    ...
                                    cTotal+rPlot+gap+rSmall+gap2+1:cTotal+rPlot+gap+rSmall+gap2+1 ,     ...
                                    2*cTotal+rPlot+gap+rSmall+gap2+1:2*cTotal+rPlot+gap+rSmall+gap2+1,  ...
                                    3*cTotal+rPlot+gap+rSmall+gap2+1:3*cTotal+rPlot+gap+rSmall+gap2+1,  ...
                                    4*cTotal+rPlot+gap+rSmall+gap2+1:4*cTotal+rPlot+gap+rSmall+gap2+1 ] )

middle = 16;
y = [ pCor_tr( taskNr , middle ), pCor_vl( taskNr , middle) ];
bar( 1 , y(1) , 'FaceColor', [ 241/255 225/255 10/255 ], 'BarWidth', 1, 'LineWidth', 0.2);
hold on
bar( 2 , y(2) , 'FaceColor', [ 143/255 100/255 0 ], 'BarWidth', 1, 'LineWidth', 0.2);
hold off

title( '\bfcorrelation', 'fontsize', 10 );

% ----- uncomment this for no labels on bottom!!! + XTickLabel weg --------
 set(gca,'XTickLabel','');
set(gca, 'FontSize', 8 );
set(gca, 'XTick', [1,2])
set(gca, 'XTickLabel',{'tr','vl'})

corr_bounds = [0.6, 1];

%set(gca, 'YTick', [corr_bounds(1),0.75,corr_bounds(2)])
%set(gca,'TickDir','out')
%set(gca,'Box','off')
%set(gca,'Visible','off')


%xMargin         = 0.5;  % set axis around given data points within a
%certain margin ---> value of 0.5 fills out the rectangle completely with
%both bars.
xMargin         = 0.7;  % set axis around given data points within a certain margin
yMarginTop      = 1.02 ;
%yMarginTop      = corr_bounds(2) ;
yMarginBottom   = corr_bounds(1);
axis( [ 1 - xMargin      2 + xMargin     ...
        yMarginBottom    yMarginTop ] );

%text( 1 , 0.65 , num2str(y(1)) , 'FontSize' , 8 ,'rotation',90);
%text( 2 , 0.65 , num2str(y(2)) , 'FontSize' , 8 ,'rotation',90);
text_position = corr_bounds(1) + (corr_bounds(2) - corr_bounds(1))*(2/5);
text( 1 , text_position , num2str(y(1)) , 'FontSize' , 8 ,'rotation',90);
text( 2 , text_position , num2str(y(2)) , 'FontSize' , 8 ,'rotation',90);
% ------------------------ ----------------------- ------------------------

