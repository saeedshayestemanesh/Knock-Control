function [Pnk,knkStats]= pdfKnk(n,Madv,Mret,theta,myAngles,fig)

% pdfKnk Probability density function of the number of knock events in n cycles
%
% Syntax
% [Pnk,knkStats]= pdfKnk(n,Madv,Mret,theta)
% [Pnk,knkStats]= pdfKnk(n,Madv,Mret,theta,myAngles)
% [Pnk,knkStats]= pdfKnk(n,Madv,Mret,theta,myAngles,fig)
%
% Description
% |[Pnk,knkStats]= pdfKnk(n,Madv,Mret,theta)| returns |Pnk|, a |[length(theta) x (n+1)]|
% matrix containing pdf's of the number of knock events experienced in the first |n| cycles, 
% for all possible initial spark angle states |theta|, given also the 'advance' and 'retard' 
% state transition matrices, |Madv|, |Mret|.  The |i| -th row of |Pnk| therefore gives the
% pdf of the number of knock events experienced in the first |n| cycles, starting in initial
% state / spark angle |theta(i)|.  Note that the x-axis of this pdf is the number of knock 
% events, |k|, running from 0 up to a theoretical maximum |k=n|.  If the knock probability
% |p| is low, most of the columns for |k>>n*p| will be zero.
%
% Additional output argument |knkStats| is a |[2 x length(Pnk)]| matrix containing the 
% ensemble mean (row1) and ensemble variance (row2) for the distribution(s) in |Pnk|.  
%
% |[Pnk,knkStats]= pdfKnk(n,Madv,Mret,theta,myAngles)| with specified initial spark angles
% |myAngles| only computes the results for the desired angles, and therefore returns a 
% [(n+1) x length(myAngles)] matrix |mKnkOut|.  If |myAngles| is empty, |myAngles= unique(theta)|.
% 
% |pdfKnk(-)| with no left hand arguments, or |pdfKnk(-,'Fig')| with specified input |'Fig'|, 
% plots histograms of the computed pdf of knock events.  If myAngles is scalar, this is a bar
% graph histogram, otherwise it is a simple line plot histogram.
%
% Examples  NEED TO DO!!!
% 
% See also
% mKnk pdfSpk

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Compute the results for all initial states / angles theta
numStates= size(Madv,1);
Pnk1= zeros(numStates,n+1);      % Allocate space for the results
Pnk1(:,1)= 1;                    % Initialize all pdfs to have all prob in col #1 => no knock events when n=0;
for i=1:n,
    Pnk1(:,[1:i+1])= Madv*Pnk1(:,[1:i+1])+ [zeros(numStates,1) Mret*Pnk1(:,[1:i])];
end
Pnk1(Pnk1<1e-10)=0;

% Output only selected angles, myAngles
for i=1:length(myAngles), myIndexes(i)= find(theta>=myAngles(i),1,'first'); end;
Pnk= Pnk1(myIndexes,:);

% Output only selected angles, myAngles
if (nargin)<5,
    Pnk= Pnk1;
else
    if isempty(myAngles), myAngles= unique(theta); end;
    for i=1:length(myAngles), myIndexes(i)= find(theta>=myAngles(i),1,'first'); end;
    Pnk= Pnk1(myIndexes,:);
end;

% Compute knock event statistics
knkStats(1,:)= Pnk * [0:n]';                                % Expected value = sum(x*p(x))
knkStats(2,:)= Pnk * [0:n]'.^2 - knkStats(:,1).^2;


% Plot results if required
if (nargout==0) || ((nargin>=6) && ~isempty(fig)),

    % Plot PDF of number of knock events in n cycles for specific start angle theta='myAngle'
    maxk= find(sum(Pnk)>0,1,'last');
    maxk= ceil(maxk/10)*10;
    
    if length(myAngles)==1,
        figure, bar([0:maxk],Pnk(:,[1:maxk+1]));
        xlabel(['Number of knock events in first ' num2str(n) ' cycles (\theta_0=' num2str(myAngles) ')']);
        ylim([0 0.9]);
        text(5,0.7,['\mu_{kn} = ' num2str(knkStats(1),3)]);
    else
        figure;
        for i=1:length(myAngles),
            plot([0:maxk],Pnk(i,[1:maxk+1])); hold all;
        end;
        xlabel(['Number of knock events in first ' num2str(n) ' cycles (\theta_0= various)']);
    end;
    ylabel('Probability')
    xlim([-0.5 maxk]); 

end;


