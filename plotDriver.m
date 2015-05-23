% PlotDriver script for stochastic simulation paper #2:
% Stochastic Simulation and Performance Analysis of Classical Knock Control Algorithms
% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014

close all

% Set default plot parameters
set(0,'DefaultLineLineWidth',2)
set(0,'DefaultFigurePaperPosition',[0.25 0.25 5 4]);

% Define data and variables for analysis
load sweep;                                                                 % d=(7 element cell array of knock intensities, each 1002x6), sa=sparkAdvance= [-4:2];
BLindx= 5;                                                                  % Index of the BL knock experiment
cyl= 1;                                                                     % Index of cylinder#'s to be analyzed
Delta= 0.015;                                                               % Define algorithm resolution [deg]
delta= 0.105;                                                               % Define spark angle actuator resolution [deg]
m1=1; m2=99;                                                                % Define controller gains

% Compute the normalized cdf for each expt in the sweep;
myCdf= eCdf(d,sa,[1:6]);                                                    % Estimate the cdf = [cdf.Fx cdf.x] from the data
normVal= p2x(.99,myCdf(BLindx),1);                                          % Find the value that gives 1% knock for cyl #1 at BL
myCdf= normCdf(myCdf,normVal,[1:6]);                                        % Normalize all cylinders with respect to this value

% Compute knock thresholds
tradTx= p2x(0.99,myCdf(BLindx),cyl);                                        % tradTx= 1% knock probability threshold [1 x nCyl]
myTxs= [tradTx;];                                                           % Define which thresholds to use

% Compute knock probability curves                                          % Paper Fig 1:  Knock probability curves
theta= [-3.9:Delta:2]';                                                       % Define anglebase on which to interpolate the results
myPcurves= knockP(myTxs,myCdf,cyl,theta,'Fig'); hold all;                   % Knock probability curves [nTheta x nCyl x nThreshRows]
% Deal with limited actuator resolution
theta1= floor((theta+5*eps)./delta).*delta;                                 % Determine actuated angles, theta1, for each controller state theta
myPcurve= myPcurves(:,:,1);                                                 % Specify which probability curve to analyze, eg. for threshold #1
myPcurve1= interp1(theta,myPcurve,theta1,'PCHIP');                          % Determine actual knock probability curve for each controller state theta
plot(theta,myPcurve1);                                                      % Plot actual knock probability curve
myPcurvesPoints= knockP(myTxs,myCdf,cyl,sa);                                % Knock probability curves at measured spark angle points
plot(sa,myPcurvesPoints,'ro');

% Perform a time history simulation for a traditional controller            % Paper Fig 2
figure
    p= 0.01;           
    knockGenTheta= theta;            
    knockGenP= myPcurve1;
    retardGain= m2*Delta; 
    advanceGain= m1*Delta;
    initialSpark= -1.6;            
    rand('state',2000);
    sim('knock0'); 
    relSpark= yout.signals(2).values;
    plot([1:length(relSpark)],relSpark,'--','color',[0 0.5 0]); hold all; %,'color',[0 0.5 0]
    initialSpark= 1.6;              
    rand('state',500);
    sim('knock0');
    relSpark= yout.signals(2).values;
    plot([1:length(relSpark)],relSpark,'b');
    xlim([-10 500]);
    ylim([-2.5 2]);
    line([0 500],[0 0],'linestyle',':','color','k','linewidth',1);
    xlabel('Cycle number');
    ylabel('Relative spark advance [deg]');
    legend('\theta_0= BL-1.6^{\circ}', '\theta_0= BL+1.6^{\circ}');


% Perform a stochastic simulation for a traditional controller
[M,Madv,Mret]= markovMx(myPcurve1,m1,m2);                                   % M matrices for corresponding to this Pcurve / threshold
initSpk= 0;                                                                 % Define initial condition (either spark value, or P0 vector)
myCycles= [0:230];                                                          % Define cycles to be analyzed: either scalar inf, n, or vector [1:n]                                    
[ssPn,SSspkStats,SSpStats]= pdfSpk(inf,M,initSpk,theta1,myPcurve1,'Fig');   % Paper Fig 3, 4: Steady state Pn(theta) and Pn(p) and response statistics
[Pn,spkStats]= pdfSpk(myCycles,M,initSpk,theta1,myPcurve1,'Fig');           % Paper Fig 5: Pn(theta) at n=230 and response statistics

figure,                                                                     % Paper Fig 7: PnBar(theta) averaged over the first n=230 cycles
    PnBar= mean(Pn,2);
    [PnBar1,theta2]= compress(PnBar,theta1);
    bar(theta2,PnBar1(:,end));
    xlabel('Relative spark angle [deg]')
    text(0.7,0.85,['\mu_{\theta} = ' num2str(spkStats(1,end),2) ' deg'],'units','normalized');
    text(0.7,0.80,['\sigma_{\theta} = ' num2str(spkStats(2,end),2) ' deg'],'units','normalized');
    text(0.7,0.76,['n= 230 cycles'],'units','normalized');
    ylabel('Probability');  ylim([0 0.1]);

figure,                                                                     % Paper Fig 8: Ensemble mean spark time histories
    myCycles= [0:250];                                                      % Define cycles to be analyzed: either scalar inf, n, or vector [1:n]                                    
    myAngles= [0,0.7,1.6,-0.7,-1.6];                                        % Define initial spark angles to test
    for i=1:length(myAngles),                                               % For each initial spark angle...
        [Pn,spkStats,pStats]= pdfSpk(myCycles,M,myAngles(i),theta1,myPcurve1);  % Compute closed loop Pn and response statistics
        plot(myCycles,spkStats(1,:));  hold all;                                % Plot ensemble mean time history
    end;                                                                    % End for
    line([0 myCycles(end)],[0,0],'linestyle',':','color','k','linewidth',1);% Add BL axis line
    xlim([-5 myCycles(end)]);   ylim([-2 2]);                               % Set axes limits
    xlabel('Cycle number [-]');                                             % Label x axis
    ylabel('Mean relative spark angle [deg]');                              % Label y axis
    %legend('\theta_0= BL-1.6^{\circ}', '\theta_0= BL+1.6^{\circ}');

figure,                                                                     % Paper Fig 9: Ensemble mean instantaneous probability time histories
    myAngles= [0,0.7,1.6,-0.7,-1.6];                                        % Define initial spark angles to test
    for i=1:length(myAngles),                                               % For each initial spark angle...
        [Pn,spkStats,pStats]= pdfSpk(myCycles,M,myAngles(i),theta1,myPcurve1);  % Compute closed loop Pn and response statistics
        plot(myCycles,pStats(1,:));  hold all;                                  % Plot ensemble mean time history
    end;                                                                    % End for
    line([0 myCycles(end)],[0,0],'linestyle',':','color','k','linewidth',1);% Add BL axis line
    xlim([-5 myCycles(end)]);   ylim([0 0.05]);                             % Set axes limits
    xlabel('Cycle number [-]');                                             % Label x axis
    ylabel('Mean knock probability [-]');                                   % Label y axis

myAngles= [0,0.7,1.6,-0.7,-1.6];                                            % Define initial spark angles to test
mSpk(myCycles(end),M,theta1,myAngles,'Fig');                                % Paper Fig 10: Time-averaged mean starting from each angle in myAngles
initSpk= 0.7;
pdfKnk(100,Madv,Mret,theta1,initSpk,'Fig');                                 % Paper Fig 12: Distribution of # knock events starting at initSpk
%pdfKnk(myCycles(end),Madv,Mret,theta1,myAngles,'Fig');                     % Paper xxxxxx: Distribution of # knock events starting at myAngles
mKnk(myCycles(end),M,myPcurve1,theta1,myAngles,'Fig');                      % Paper Fig 13: # Knock events as fn of cycle number
[T,nk]=respT(M,SSspkStats(1),theta1,myPcurve1,'Fig');                       % Paper Figs 11, 14:  Response times and # knock events to thetaTarg=SS





