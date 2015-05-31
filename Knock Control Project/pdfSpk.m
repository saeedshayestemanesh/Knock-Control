function [Pn,spkStats,pStats]= pdfSpk(n,M,P0,theta,pCurve,fig)

% pdfSpk Probability density function of closed-loop relative spark advance
%
% Syntax
% [Pn,spkStats,pStats]= pdfSpk(n,M,P0,theta,pCurve)
% [Pn,spkStats,pStats]= pdfSpk(n,M,P0,theta,pCurve,fig)
%
% Description
% |[Pn,spkStats,pStats]= pdfSpk(n,M,P0,theta,pCurve)| returns |Pn| the length(theta)
% element probability density fn of closed loop spark advance states, given |n| the 
% desired cycle number, |M| the state transition matrix |M|, and initial spark 
% distribution |P0|.  If |n=inf|, the steady state distribution is returned.
%
% If n is a vector [0:n], Pn is a [length(theta) x (n+1)] matrix containing the 
% evolution of the closed loop spark pdf with time / cycle number.  The |j| -th column of
% |Pn| therefore gives the closed loop pdf at cycle number |j-1|.  If P0 is a scalar value, 
% it is assumed to represent an initial spark advance angle with probability 1, from which
% the true P0 is constructed.
%
% Additional input arguments |theta| and |pCurve| are vectors containing (respectively) 
% the relative spark angles and knock probability at each controller state. Additional 
% output argument |spkStats| is a |[2 x length(Pn)]| matrix containing the ensemble mean
% (row1) and ensemble variance (row2) for the distribution(s) in |Pn|.  
% Output argument |pStats| is a similar matrix containing the mean and variance of the 
% instantaeous knock probability corresponding to the spark angle distributions |Pn|.
% 
% |pdfSpk(-)| with no left hand arguments, or |pdfSpk(-,'Fig')| with specified input |'Fig'|, 
% plots a histogram of the final spark angle probability density function at cycle |n| and of  
% the instantaneous knock probabilities.  If |n| is a vector, the evolution of |Pn| with cycle
% number is also plotted as an intensity image plot, and the ensemble mean spark advance and
% ensemble mean instantaeous knock probabilty are also plotted as a function of cycle number, |n|.
%
% Examples  NEED TO DO!!!
% 
% See also
% mSpk pdfKnk

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Check input arguments
if (length(n)>1) && (n(1)~=0), 
    error('Input parameter n should be a scalar or a vector [0:numCycles] - starting from cycle zero');
end;

% Redefine P0 if a scalar (representing an initial spark angle)
numStates= length(M);
if length(P0)==1,
    myIndex= find(theta>=P0,1,'first');
    P0= zeros(numStates,1); P0(myIndex+1)=1;
end;

% Compute Pn for all states
if length(n)==1,
    if n==inf,
        Pn= abs(null(M'-eye(size(M))));
        Pn= Pn / sum(Pn);    
    else
        Pn= M'^n*P0;
    end;
else
    Pn= zeros(numStates,length(n));  % allocate space for results
    Pn(:,1)= P0;
    for i= 2:length(n),
        Pn(:,i)= M' * Pn(:,i-1);
    end;
end;
Pn(Pn<1e-10)=0;

% Compute spark angle statistics
spkStats(1,:)= Pn' * theta;                                % Expected value = sum(x*p(x))
spkStats(2,:)= sqrt(Pn' * theta.^2 - spkStats(:,1).^2);

% Compute instantaneous knock probability statistics
pStats(1,:)= Pn' * pCurve;                                % Expected value = sum(x*p(x))
pStats(2,:)= sqrt(Pn' * pCurve.^2 - pStats(:,1).^2);

% Plot results if required
if (nargout==0) || ((nargin>=6) && ~isempty(fig)),
    [Pn1,theta1]= compress(Pn,theta);
    if length(n)>1,
        
        % Intensity plot of pdf vs cycleNumber
        figure  
        imagesc(n,theta1,Pn1);  % ...to make the line thicker
        set(gca,'ydir','normal');
        c= colormap; c(1,:)=1; colormap(c);
        xlabel('Cycle number [-]');
        ylabel('Relative spark advance [deg]');
        
        % Plot of mean spark vs cycleNumber
        figure, plot(n,spkStats(1,:));  
        xlabel('Cycle number [-]');
        ylabel('Relative spark angle [deg]');

        % Plot of mean knock Probability vs cycleNumber
        figure, plot(n,pStats(1,:));          
        xlabel('Cycle number [-]');
        ylabel('Instantaneous knock probability');
    end;   
    
    % Plot histogram of final spark angle distribution
    figure, bar(theta1,Pn1(:,end));
    xlabel('Relative spark angle [deg]')
    text(0.7,0.85,['\mu_{\theta} = ' num2str(spkStats(1,end),2) ' deg'],'units','normalized');
    text(0.7,0.80,['\sigma_{\theta} = ' num2str(spkStats(2,end),2) ' deg'],'units','normalized');
    
    if n(end)==inf, text(0.7,0.76,['n = steady state'],'units','normalized'); ylim([0 0.1]);
    else text(0.7,0.76,['n= ' num2str(n(end)) ' cycles'],'units','normalized');
    end;
    ylabel('Probability');

    % Plot histogram of final knock probability distribution
    deltap= 0.005;
    [Pn2,pCurve2]= compress(Pn,floor((pCurve+5*eps)./deltap).*deltap);
    figure, bar(pCurve2,Pn2(:,end));
    axis([-0.02 0.32 0 0.6])
    xlabel('Instantaneous knock probability');
    text(0.7,0.85,['\mu_{p} = ' num2str(pStats(1),2)],'units','normalized');
    if n(end)==inf, text(0.7,0.8,['n = steady state'],'units','normalized');;
    else text(0.7,0.8,['n= ' num2str(n(end)) ' cycles'],'units','normalized');
    end;
    ylabel('Probability');

end;
  
