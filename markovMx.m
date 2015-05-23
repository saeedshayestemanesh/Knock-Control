function [M,Madv,Mret]= markovMx(pCurve,m1,m2)

% markovMx Construct state transition matrices for a traditional knock controller
%
% Syntax
% [M,Madv,Mret]= markovMx(pCurve,m1,m2)
%
% Description
% |[M,Madv,Mret]= markovMx(pCurve,m1,m2)| returns the [numStates x numStates] state transition
% matrices for a traditional knock controller, given |pCurve|, a vector of knock probabilities, 
% controller advance step |m1|, and retard step |m2|.  
%
% Examples
% theta=[-3:2]; BLindx=4;                   % Specify spark angles used for the sweep, and BL knock index
% xi= loadSweep(speed,load,theta);          % Load a corresponding cell array of [numCycles x numCyl] data
% myCdf= eCdf(xi,theta);                    % Compute enpirical Cdf for all cylinders and all spark conditions
% tradTx= p2x(0.99,myCdfn(BLindx),1);       % Compute 1% knock prob threshold for cyl #1 at BL
% theta= [-3:0.01:2]';                      % Define anglebase on which to interpolate the results
% myPcurve= knockP(tradTx,myCdf,1,theta);   % Knock probability curve [length(theta) x 1]
% m1=1; m2=99;                              % Define controller gains
% [M,Madv,Mret]= markovMx(myPcurve,m1,m2);  % M matrices corresponding to this Pcurve / threshold
% 
% See also
% 

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


numStates= length(pCurve);
imax = numStates -1;                                            % Max index i in the paper ...since i is indexed from zero

% Construct the state transition matrix
Madv = zeros(numStates);                                        % Create empty square matrix
Mret = zeros(numStates);                                        % Create empty square matrix
m1pColIndexes= [0:imax] + min(m1,imax-[0:imax]);                % Define non-zero elements, (i+m1') indexed from zero
m2pColIndexes= [0:imax] - min(m2,[0:imax]);                     % Define non-zero elements, (i-m2') indexed from zero
Madv([1:numStates] + m1pColIndexes * numStates) = (1-pCurve);   % MatrixIndex = row + (colIndexFromZero)*colLength
Mret([1:numStates] + m2pColIndexes * numStates) = pCurve;       % MatrixIndex = row + (colIndexFromZero)*colLength
M= Madv + Mret;
