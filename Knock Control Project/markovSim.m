%markovSim(theta,pvec,ptarg,Kret,Delta)

% Compute the advance gain, and the advance / retard indices
m1 = 1;
m2 = 99;
ptarg = m1/(m1+m2)
Kret = 1.5;
Kadv = Kret * m1/m2;
Delta = Kret/m2             %algorithm resolution
delta = 7*Delta; %0.1;      %actuator resolution [set delta= Delta if unconstrained]

theta = [-4:2]';
pvec = [0;0;0;0.000998003992015968;0.0109780439121756;0.140718562874252;0.394211576846307]';

%% Define the anglebase (ie. the angular states) of the controller and the corresponding knock probability p'=pvec1
theta1 = [ceil(theta(1)/Delta)*Delta:Delta:theta(end)]';  % Define anglebase and ensure borderline (BL) is represented
if delta~=0, theta1 = floor((theta1+5*eps)./delta).*delta; end; % Apply limited actuator resolution 'delta'
theta1= [theta1; theta(end)];
pvec1 = interp1(theta(:),pvec(:),theta1,'cubic');               % Interpolate the knock probability curve onto this anglebase
numStates = length(theta1)                                      % Number of states
imax = numStates -1;                                            % Max index i in the paper ...since i is indexed from zero

    % Plot the knock Probability characteristic
    %close all
    figure('paperposition',[0.25 0.25 5 4])
    plot(theta,pvec,'ro',theta1,pvec1,'-', 'linewidth',2); 
    hold on; stairs(theta1,pvec1,'-', 'linewidth',2)
    axis([-4 2 0 0.4])
    xlabel('Relative Spark Advance [deg]');
    ylabel('Probability');
    %title('Knock Probability Characteristic');


%% Construct the state transition matrix
Madv = zeros(numStates);                                        % Create empty square matrix
Mret = zeros(numStates);                                        % Create empty square matrix
m1pColIndexes= [0:imax] + min(m1,imax-[0:imax]);                % Define non-zero elements, (i+m1') indexed from zero
m2pColIndexes= [0:imax] - min(m2,[0:imax]);                     % Define non-zero elements, (i-m2') indexed from zero
Madv([1:numStates] + m1pColIndexes * numStates) = (1-pvec1);    % MatrixIndex = row + (colIndexFromZero)*colLength
Mret([1:numStates] + m2pColIndexes * numStates) = pvec1;        % MatrixIndex = row + (colIndexFromZero)*colLength
M= Madv + Mret;


%% Find Pn(theta), the spark angle distribution at cycle number n
%  starting from initial angle theta= myAngle
n= 250; %60
myAngle= -1.6; %-1.6;
myIndex= find(theta1<=myAngle,1,'last');
P0= zeros(numStates,1); P0(myIndex)=1;
Pn= M'^n*P0;

    % Plot the distribution Pn(theta) at cycle n: (Fig 5 if n=230)
    [theta2,i1,i2]= unique(theta1);
    for i=1:length(theta2), Pn1(i)= sum(Pn(i2==i)); end
    Pn1(Pn1<1e-10)=0;
    figure('paperposition',[0.25 0.25 5 4])
    bar(theta2,Pn1)
    meanSparkn= Pn'*theta1;
    xlabel('Relative Spark Angle [deg]');
    ylabel('PDF');
    axis([-4 2 0 0.9]);
    line([meanSparkn(end) meanSparkn(end)],[0 0.4],'color','r','linestyle','--','linewidth',2);
    text(0.65,0.8,['Mean \theta = ' num2str(meanSparkn(end),2) ' deg'],'units','normalized');
  
% Also find the transient distribution for each of the first n cycles
Nstore= min(n,1500); 
Pn= zeros(numStates,Nstore);  % allocate space for results
Pn(myIndex,1)=1;
for i=0:n-2,
    Pn(:,mod(i+1,Nstore)+1)= M'*Pn(:,mod(i,Nstore)+1);
end;
meanSpark= Pn' * theta1;
meanProb= Pn' * pvec1;

    % Plot an intensity plot of the 3-D spark angle distribution: (Fig. 6 if n=250)
    figure('paperposition',[0.25 0.25 5 4])
    imagesc([1:n]',theta1',Pn+Pn(:,[2:end,1])+Pn([2:end,1],:));  %to make the line thicker
    set(gca,'ydir','normal');
    c= colormap; c(1,:)=1; colormap(c);
    xlabel('Cycle number [-]');
    ylabel('Relative Spark Advance [deg]');
    line([230 230],[-3.1 1.5],'color','r','linestyle','--','linewidth',2);
    
    % Plot mean spark angle as a function of time
    figure
    %figure('paperposition',[0.25 0.25 5 4])
    plot(meanSpark,'linewidth',2);  hold all;
    xlabel('Cycle number [-]');
    ylabel('Mean Relative Spark Advance [deg]');
    xlim([-5 n]);

    % Plot mean instantaneous probability as a function of time
    figure
    %figure('paperposition',[0.25 0.25 5 4])
    plot(meanProb,'linewidth',2);  hold all;
    xlabel('Cycle number [-]');
    ylabel('Mean Knock Probability');
    xlim([-5 n]);
    ylim([0 0.05]);
 

%% Find PnBar(theta), the spark angle distribution averaged over time, as time increases from 0 to n
PnBar1 = cumsum(Pn')' ./ repmat([1:n],numStates,1);

% PnBar= zeros(numStates,n);  % allocate space for results
% PnBar(myIndex,1)=1;
% PnBar(:,2)= 1/2*(M'*PnBar(:,1)+PnBar(:,1));
% for i=2:n-1,
%     PnBar(:,i+1)= 1/(i+1)*(i*(M'+eye(size(M')))*PnBar(:,i)+(i-1)*PnBar(:,i-1));
% end;
% find((PnBar(:,1:50)-PnBar1(:,1:50))>0.001)
% figure, stem(theta1,PnBar1(:,500));
% figure,stem(theta1,PnBar(:,500));
% return
 mThetaBar= PnBar1' * theta1;

PnBarAtEnd= PnBar1(:,end);
[theta2,i1,i2]= unique(theta1);
for i=1:length(theta2), PnBarAtEnd1(i)= sum(PnBarAtEnd(i2==i)); end

    % Plot time averaged spark distribution
    figure;
    %figure('paperposition',[0.25 0.25 5 4])
    bar(theta2,PnBarAtEnd1,0.7);
    xlabel('Relative Spark Advance [deg]');
    ylabel('PDF');
    axis([-4 2 0 0.1])
    line([mThetaBar(end) mThetaBar(end)],[0 0.08],'color','r','linestyle','--','linewidth',2);
    text(0.65,0.8,['Time Averaged Mean \theta = ' num2str(mThetaBar(end),2) ' deg'],'units','normalized');
    
    % Plot mBar(n,theta), themean spark angle, averaged over time, as time increases - computed from PnBar
    figure;
    %figure('paperposition',[0.25 0.25 5 4])
    plot(mThetaBar);
    xlabel('Cycle number [-]');
    ylabel('Time Averaged Relative Spark Advance [deg]');

    
%% Find mBar(n,theta), the mean spark angle averaged over time, as time increases from 0 to n
%  starting at initial spark angle, theta= myAngle - direct method
mThetaBar= zeros(numStates,n);
mThetaBar(:,1)= theta1;
for i= 1:n,
    mThetaBar(:,i+1)= i/(i+1) * M*mThetaBar(:,i) + theta1./(i+1); 
end;
     
    % Plot time averaged mean spark angle from some initial spark angle, myAngle, as a function of time
    %myAngle= 0;
    myIndex= find(theta1<=myAngle,1,'last');
    figure;
    %figure('paperposition',[0.25 0.25 5 4])
    %plot(meanSpark); hold all;          % the ensemble average
    plot(mThetaBar(myIndex,[1:n]),'linewidth',2); hold all;	% the time average
    %plot(meanSpark);
    xlabel('Cycle number [-]');
    ylabel('Time Averaged Relative Spark Advance [deg]');
    

%% Find Pinf(theta), the steady state spark angle distribution
Pinf= abs(null(M'-eye(size(M))));
Pinf= Pinf / sum(Pinf);    
[theta2,i1,i2]= unique(theta1);
for i=1:length(theta2), Pinf1(i)= sum(Pinf(i2==i)); end
meanSpark= Pinf1*theta2;  % Expected value = sum(x*p(x))

% Find Pinf(p), the steady state knock probability distribution
[pvec2,i1,i2]= unique(pvec1);
for i=1:length(pvec2), Pinf2(i)= sum(Pinf(i2==i)); end
meanProb= Pinf2*pvec2;    % Expected value = sum(x*p(x))

% Recompute Pinf(p) with lower resolution for nicer plot
deltap= 0.005;
if deltap~=0, pvec3= floor((pvec1+5*eps)./deltap).*deltap; end;
[pvec2,i1,i2]= unique(pvec3);
for i=1:length(pvec2), Pinf3(i)= sum(Pinf(i2==i)); end

    % Plot the steady state spark angle distribution
    figure('paperposition',[0.25 0.25 5 4])
    bar(theta2,Pinf1,0.7);
    xlabel('Relative Spark Advance [deg]');
    ylabel('PDF');
    axis([-4 2 0 0.1])
    line([meanSpark meanSpark],[0 0.08],'color','r','linestyle','--','linewidth',2);
    text(0.65,0.8,['Mean \theta = ' num2str(meanSpark,2) ' deg'],'units','normalized');

    % Plot the steady intantaneous knock probability distribution
    figure('paperposition',[0.25 0.25 5 4])
    bar(pvec2,Pinf3,0.9);
    xlabel('Instantaneous Knock Probability');
    ylabel('PDF');
    axis([-0.02 0.32 0 0.6])
    line([meanProb meanProb],[0 0.3],'color','r','linestyle','--','linewidth',2);
    text(0.65,0.8,['Mean p = ' num2str(meanProb)],'units','normalized');


%% Find Pn(k,theta), the distribution of the number of knock events in the next n cycles.
%  The ith row of Pn(k,theta) is a pdf where jth col is prob(j-1) knock events in first n cycles starting in state theta_i.
n= 100;                         
Pnk= zeros(numStates,n+1);      % Allocate space for the results
Pnk(:,1)= 1;                    % Initialize all pdfs to have all prob in col #1 => no knock events when n=0;
for i=1:n,
    Pnk(:,[1:i+1])= Madv*Pnk(:,[1:i+1])+ [zeros(numStates,1) Mret*Pnk(:,[1:i])];
end
meanKnock= Pnk * [0:n]';        % Expected value = sum(x*p(x))

    % Plot PDF of number of knock events in n cycles for specific start angle theta='myAngle'
    myAngle= 0;
    myIndex= find(theta1<=myAngle,1,'last');
    figure('paperposition',[0.25 0.25 5 4])
    bar([0:n],Pnk(myIndex,:));
    xlabel('Number of knock events');
    ylabel('PDF')
    xlim([-0.5 10]); ylim([0 0.9]);
    text(5,0.7,['Expected value: ' num2str(Pnk(myIndex,:)*[0:n]',3)]);
    %title(['PDF of # knock events in first ' num2str(n) ' cycles, with initial spark angle ' num2str(myAngle,1)]);

    % Plot expected number of knock events in first n cycles (derived from Pnk)
    figure('paperposition',[0.25 0.25 5 4])
    plot(theta1,meanKnock,'linewidth',2);
    xlabel('Initial Relative Spark Angle [deg]'); 
    ylabel('Expected Number of Knock Events');
    %title(['Expected Knock Events in First ' num2str(n) ' Cycles (Method1)']);
return

%% Find mkn(n,theta), the expected number of knock events in the first n cycles directly
n= 100;
mkn= zeros(numStates,n+1);
for i= 1:n,
    mkn(:,i+1)= M*mkn(:,i) + pvec1;
end

    % First plot the expected # knock events experienced by time t=n, for all initial states
    figure('paperposition',[0.25 0.25 5 4])
    plot(theta1, mkn(:,end),'linewidth',2);
    xlabel('Initial Relative Spark Angle [deg]'); 
    ylabel('Expected Number of Knock Events');
    %title(['Expected Knock Events in First ' num2str(n) ' Cycles (Method2)']);
    
    % Now plot the evolution of this expectation as a fn of time for a select few initial angles of interest
    myAngles= [-1 0 1 2];
    for i=1:length(myAngles), myIndexes(i)= find(theta1<=myAngles(i),1,'last'); end;
    figure('paperposition',[0.25 0.25 5 4])
    plot([0:n]',mkn(myIndexes,:)','linewidth',2);
    xlabel('Cycle Number'); 
    ylabel('Expected Number of Knock Events');
    %title(['Expected Knock Events for different initial spark angles: ' num2str(myAngles,1)]);

    % Now plot evolution of this expectation as a fn of time relative to the target knock expectation
    figure('paperposition',[0.25 0.25 5 4])
    plot([0:n]',mkn(myIndexes,:)'-repmat([0:n]'*0.01,1,length(myIndexes)),'linewidth',2);
    xlabel('Cycle Number'); 
    ylabel('Expected Excess/Deficiency of Knock Events');
    %title(['Excess or deficiency of Knock Events for different initial spark angles: ' num2str(myAngles,1)]);


%% Find T(targ,thetai), the response time from initial angle thetai to reach or crossover theta targ
myAngle= meanSpark;
myIndex= find(theta1<=myAngle,1,'last');
C= [ones(1,myIndex-1), 0 , ones(1,numStates-myIndex)]'; %All 1 except at target.
Mstar= M;
Mstar(myIndex:end,1:myIndex)= 0;
Mstar(1:myIndex,myIndex:end)= 0;
Ttheta= - inv(Mstar-eye(size(Mstar)))*C;

    figure('paperposition',[0.25 0.25 5 4])
    stairs(theta1,Ttheta,'linewidth',2);
    axis([-4 2 0 250])
    xlabel('Initial Relative Spark Angle [deg]'); 
    ylabel('Expected Response Time [cycles]'); 
    line([myAngle myAngle],[0 100],'color','r','linestyle','--','linewidth',2);
    %title('Expected Number of Cycles to Baseline');



%% Finding mkth(targ,thetai), the expected number of knock events during response from thetai to theta targ.
%* Uses target 'myangle' and associated Mstar matrix defined above
D= pvec1;  D(myIndex)=0;
mkth= - inv(Mstar-eye(size(Mstar)))*D;

    figure('paperposition',[0.25 0.25 5 4])
    stairs(theta1,mkth,'linewidth',2);
    axis([-4 2 0 2.5])
    xlabel('Initial Relative Spark Angle [deg]'); 
    ylabel('Expected Number of Knock Events');  
    line([myAngle myAngle],[0 1.5],'color','r','linestyle','--','linewidth',2);
    %title(['Expected Number of Knock Events to angle ' num2str(myAngle,1)]);


