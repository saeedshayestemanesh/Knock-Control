function mKnkOut= mKnk(n,M,pCurve,theta,myAngles,fig)

% mKnk Mean (closed-loop) number of knock events in first n cycles
%
% Syntax
%  mKnkOut= mKnk(n,M,pCurve,theta)
%  mKnkOut= mKnk(n,M,pCurve,theta,myAngles)
%  mKnkOut= mKnk(n,M,pCurve,theta,myAngles,fig)
%
% Description
% |mKnkOut= mKnk(n,M,pCurve,theta)| returns |mKnkOut| a [length(theta) x (n+1)] matrix
% of the expected number of knock events for each cycle [0:n] starting from all possible 
% initial spark angles |theta|, given also the state transition matrix |M|, and knock 
% probability curve |pCurve|.  The |i| -th row of |mKnOut| therefore gives the mean number  
% of knock events at cycle number |i-1| as a function of initial spark angle, while the 
% |j| -th column of |mKnOut| gives the time history of the number of knock events starting
% from initial spark angle |theta(j)|.
%
% |mKnkOut= mKnk(n,M,pCurve,theta,myAngles)| with specified initial spark angles |myAngles| 
% only computes the results for the desired angles, and therefore returns a 
% [length(myAngles) x (n+1)] matrix |mKnkOut|.  If |myAngles| is empty, |myAngles= unique(theta)|.
%
% |mKnk(-)| with no left hand arguments, or |mKnk(-,'Fig')| with specified input |'Fig'|, 
% also plots the number of knock events at cycle n as a function of the initial spark 
% angles |theta|.  It also plots the time evolution of the expected number of knock
% events for the specified initial angles |myAngles| and the difference between this 
% and the expected number of knock events if operating at BL spark conditions.
%
% Examples  NEED TO DO!!!
% 
% See also
% mSpk pdfKnk

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Compute the results for all initial angles theta
mKnkOut1= zeros(size(M,1),n+1);
for i= 1:n,
    mKnkOut1(:,i+1)= M*mKnkOut1(:,i) + pCurve;
end

% Output only selected angles, myAngles
if (nargin)<5,
    mKnkOut= mKnkOut1;
else
    if isempty(myAngles), myAngles= unique(theta); end;
    for i=1:length(myAngles), myIndexes(i)= find(theta>=myAngles(i),1,'first'); end;
    mKnkOut= mKnkOut1(myIndexes,:);
end;


% Plot results if required
if (nargout==0) || ((nargin>=6) && ~isempty(fig)),

    % First plot the expected # knock events experienced by cycle n, for different intial start angles
    figure, plot(theta, mKnkOut1(:,end));
    xlabel('Initial relative spark angle [deg]'); 
    ylabel(['Expected number of knock events in first ' num2str(n) ' cycles']);
    
    % Now plot the evolution of this expectation as a fn of time for a select few initial angles of interest
    figure, plot([0:n],mKnkOut');
    xlabel('Cycle number'); 
    ylabel('Expected number of knock events');

    % Now plot evolution of this expectation as a fn of time relative to the target knock expectation
    BLindx= find(theta>=0,1,'first');
    figure, plot([0:n],mKnkOut'-repmat([0:n]'*pCurve(BLindx),1,size(mKnkOut,1)));
    xlabel('Cycle number'); 
    ylabel('Expected excess/deficiency of knock events');

end;