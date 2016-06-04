%close all;

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


prediction_tr       = d.results.pred.y_pred_tr;
prediction_vl       = d.results.pred.y_pred_vl;

% transpose predictions
prediction_tr       = prediction_tr';
prediction_vl       = prediction_vl';

% correlation coefficients
pCor_tr             = d.results.correlation.CC_tr;
pCor_vl             = d.results.correlation.CC_vl;

% NRMSE
NRMSE_tr            = d.results.errors.NRMSE_tr;
NRMSE_vl            = d.results.errors.NRMSE_vl;



% --------------------- plot parameters ----------------------
% set papersize for saving the figure as a pdf - A4 landscape
figure( 'PaperSize',[29.68 20.98], ...
        'Position', [ scrsz(3)/5    170         scrsz(3)*0.55       300         ] );
%                   [ left          bottom      width               height ]

rTotal = 8;
cTotal = 14;

rPlot  = 6; % change this for zoom! Formerly: 8 columns
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

plot( time , target_vl( taskNr , time ), 'Color', [ 36/255 92/255 211/255 ] , 'LineWidth', 1);
hold on
plot( time , prediction_vl( taskNr , time ), 'Color', [ 1 92/255 23/255 ] , 'LineWidth', 1);
hold off



% ======================== THINGS TO CHANGE ==============================
title( '\bfexperiment 1 - without feedback loop', 'fontsize', 12 );           % ------------ title 
xlabel( 'time', 'fontsize', 10 ); 

% ----- uncomment this for no labels on bottom!!! + xlabel weg --------
% set(gca,'XTickLabel','');

yMargin  = ( max( target_vl( taskNr , time ) ) - min( target_vl( taskNr , time ) ) ) / 10;
% ======================== ================ ==============================



%legend( 'desired', 'observed',   'Location', 'West');
%ylabel('desired/observed value', 'fontsize', 10);

set(gca, 'FontSize', 8 );

xMargin  = 0;  % set axis around given data points within a certain margin

%yMarginTop  = 0;   yMarginBottom = 0.5; 
%axis( [ min( time ) - xMargin      max( time ) + xMargin     ...
%        min( target_vl( taskNr , time ) ) - yMargin      max( target_vl( taskNr , time ) ) + yMargin] );

% zoomStart   = 3037;
% zoomEnd     = 3143;

% cue onset at 3078; 3078 - 19 = 3059

zoomStart   = 3059;
zoomEnd     = 3150;
length = zoomEnd - zoomStart;

set(gca,'XTick',[zoomStart 3078 3088 zoomEnd])

axis( [ zoomStart      zoomEnd     ...
        min( target_vl( taskNr , time ) ) - yMargin      max( target_vl( taskNr , time ) ) + yMargin] );
% ------------------------ ----------------------- ------------------------


gap = 2;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ---------------------- diagonal - desired vs. observed ---------------------
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
subplot( rTotal , cTotal ,        [ rPlot+gap:rPlot+gap+rSmall, ...
                                    cTotal+rPlot+gap:cTotal+rPlot+gap+rSmall, ...
                                    2*cTotal+rPlot+gap:2*cTotal+rPlot+gap+rSmall, ...
                                    3*cTotal+rPlot+gap:3*cTotal+rPlot+gap+rSmall, ...
                                    4*cTotal+rPlot+gap:4*cTotal+rPlot+gap+rSmall ] )
plot( prediction_tr( taskNr , time ) , target_tr( taskNr , time ) , '.', 'Color', [ 241/255 225/255 10/255 ] , 'LineWidth', 0.5);
hold on
plot( prediction_vl( taskNr , time ) , target_vl( taskNr , time ) , '.', 'Color', [ 143/255 100/255 0 ] , 'LineWidth', 0.5);
hold off
title( '\bfdesired vs. observed' , 'fontsize', 10 );
%xlabel( 'y_{pred}', 'fontsize', 10 );   
%ylabel( 'y', 'fontsize' , 10 );
%set(gca,'XTickLabel','', 'FontSize', 8 );
set(gca, 'FontSize', 8 );
%margin  = 0.8;  % set axis around given data points within a certain margin
margin  = ( max( prediction_vl( taskNr , time )  ) - min( prediction_vl( taskNr , time )  ) ) / 10;
axis( [ min( prediction_vl( taskNr , time )  ) - margin      max( prediction_vl( taskNr , time )  ) + margin     ...
        min( prediction_vl( taskNr , time )  ) - margin      max( prediction_vl( taskNr , time )  ) + margin] );

grid;
axis square
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

%title( '\bfCorrelation', 'fontsize', 10 );

% ----- uncomment this for no labels on bottom!!! + XTickLabel weg --------
 set(gca,'XTickLabel','');
set(gca, 'FontSize', 8 );
%set(gca, 'XTick', [1,2])
%set(gca, 'XTickLabel',{'tr','vl'})


xMargin         = 0.5;  % set axis around given data points within a certain margin
yMarginTop      = 1.02 ;
yMarginBottom   = 0.5;
axis( [ 1 - xMargin      2 + xMargin     ...
        yMarginBottom    yMarginTop ] );

text( 1 , 0.65 , num2str(y(1)) , 'FontSize' , 8 ,'rotation',90);
text( 2 , 0.65 , num2str(y(2)) , 'FontSize' , 8 ,'rotation',90);
% ------------------------ ----------------------- ------------------------
