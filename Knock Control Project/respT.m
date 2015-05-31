function [T,nk]=respT(M,thetaTarg,theta,pCurve,fig)

% respT Transient response statistics for a traditional knock controller
%
% Syntax
% [T,nk]=respT(M,thetaTarg,theta,pCurve)
% [T,nk]=respT(M,thetaTarg,theta,pCurve,fig)
%
% Description
% |[T,nk]=respT(M,thetaTarg,theta,pCurve)| returns |T| a vector of the expected response times
% from all possible initial spark angles |theta|, to reach or crossover a target spark angle
% |thetaTarg|, given also the state transition matrix |M|, and knock probability curve
% |pCurve|.  The function also returns a corresponding vector |nk| of the expected number 
% of knock events that occur during this transient response time interval.
%
% |respT(-)| with no left hand arguments, or |respT(-,'Fig')| with specified input |'Fig'|, 
% also plots the expected response times and expected number of knock events as a function
% of the initial spark angles |theta|.
%
% Examples  TO DO***
% myPcurve= knockP(tradTx,myCdf,1,theta);   % Knock probability curve [length(theta) x 1]
% m1=1; m2=99;                              % Define controller gains
% [M,Madv,Mret]= markovMx(myPcurve,m1,m2);  % M matrices corresponding to this Pcurve / threshold
% 
% See also
% mSpk mKnk

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Compute Mstar
numStates= size(M,1);
Mstar= M;
myIndex= find(theta<thetaTarg,1,'last')+1;
Mstar(myIndex:end,1:myIndex)= 0;
Mstar(1:myIndex,myIndex:end)= 0;

% Find the expected number of cycles to reach thetaTarg from all start angles thetai
C= [ones(1,myIndex-1), 0 , ones(1,numStates-myIndex)]'; %All 1 except at target.
T= - inv(Mstar-eye(size(Mstar)))*C;

% Find the expected number of knock events during response from thetai to thetaTarg.
D= pCurve;  D(myIndex)=0;
nk= - inv(Mstar-eye(size(Mstar)))*D;

% Plot results if required
if (nargout==0) || ((nargin>=5) && ~isempty(fig)),

    figure, stairs(theta,T);
    xlabel('Initial relative spark angle [deg]'); 
    ylabel('Expected response time [cycles]'); 
    text(0.7,0.85,['\theta_{targ} = ' num2str(thetaTarg,2) ' deg'],'units','normalized');
    line([thetaTarg thetaTarg],[0 100],'color','r','linestyle','--','linewidth',2);
    
    figure, stairs(theta,nk);
    xlabel('Initial relative spark angle [deg]'); 
    ylabel('Expected number of knock events');  
    text(0.1,0.85,['\theta_{targ} = ' num2str(thetaTarg,2) ' deg'],'units','normalized');
    line([thetaTarg thetaTarg],[0 1.5],'color','r','linestyle','--','linewidth',2);

end;