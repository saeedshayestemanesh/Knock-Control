function mSpkOut=mSpk(n,M,theta,myAngles,fig)

% mSpk Mean closed-loop spark angle, time-averaged over the first n cycles
%
% Syntax
%  mSpkOut=mSpk(n,M,theta)
%  mSpkOut=mSpk(n,M,theta,myAngles)
%  mSpkOut=mSpk(n,M,theta,myAngles,fig)
%
% Description
% |mSpkOut=mSpk(n,M,theta))| returns |mSpkOut| a [length(theta) x (n+1)] matrix
% of the time-averaged mean spark angle for each cycle [0:n] starting from all possible 
% initial spark angles |theta|, given also the state transition matrix |M|.  
% The |i| -th row of |mSpkOut| therefore gives the time-averaged mean spark angle   
% at cycle number |i-1| as a function of initial spark angle, while the 
% |j| -th column of |mSpkOut| gives the time history of the mean time-averaged spark 
% angle starting from initial spark angle |theta(j)|.
%
% |mSpkOut=mSpk(n,M,theta,myAngles)| with specified initial spark angles |myAngles| 
% only computes the results for the desired angles, and therefore returns a 
% [(n+1) x length(myAngles)] matrix |mSpkOut|.  If |myAngles| is omitted or empty, 
% |myAngles= unique(theta)|.
%
% |mSpk(-)| with no left hand arguments, or |mSpk(-,'Fig')| with specified input |'Fig'|, 
% plots the time-averaged mean spark angle at cycle n as a function of the initial spark 
% angles |theta|.  It also plots the time evolution of the time-averaged mean spark
% for the specified initial angles |myAngles|.
%
% Examples  NEED TO DO!!!
% 
% See also
% 

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Compute the results for all initial angles theta
mSpkOut1= zeros(size(M,1),n+1);
mSpkOut1(:,1)= theta;
for i= 1:n,
    mSpkOut1(:,i+1)= i/(i+1) * M*mSpkOut1(:,i) + theta./(i+1); 
end;

% Output only selected angles, myAngles
if (nargin)<5,
    mSpkOut= mSpkOut1;
else
    if isempty(myAngles), myAngles= unique(theta); end;
    for i=1:length(myAngles), myIndexes(i)= find(theta>=myAngles(i),1,'first'); end;
    mSpkOut= mSpkOut1(myIndexes,:);
end;


% Plot results if required
if (nargout==0) || ((nargin>=5) && ~isempty(fig)),

    % First plot the time averaged mean spark at cycle n, for different intial start angles
    figure, plot(theta, mSpkOut1(:,end));
    xlabel('Initial relative spark angle [deg]'); 
    ylabel(['Time-averaged spark angle at cycle number ' num2str(n)]);
    
    % Now plot the evolution of this expectation as a fn of time for a select few initial angles of interest
    figure, plot([0:n],mSpkOut');
    xlabel('Cycle number [-]');
    ylabel('Time averaged relative spark advance [deg]');
    
end;

