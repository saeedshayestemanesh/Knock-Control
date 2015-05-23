function [pCurve1,theta1]= knockP(Tx,cdfData,cyl,theta,fig)

% knockP Computes knock probability curves
%
% Syntax
% [pCurve1,theta1]= knockP(Tx,cdfData)
% [pCurve1,theta1]= knockP(Tx,cdfData,cyl)
% [pCurve1,theta1]= knockP(Tx,cdfData,cyl,theta)
% [pCurve1,theta1]= knockP(Tx,cdfData,cyl,theta,fig)
%
% Description
% |[pCurve1,theta1]= knockP(Tx,cdfData)| returns a |[nExpts x nCyl x size(Tx,1)]| matrix 
% of knock probability curve values  evaluated at spark angles |theta1=[cdfData.theta]|
% corresponding to the scalar, vector or matrix of specified knock intensity thresholds |Tx|.
%
% The columns of |Tx| represent cylinder specific thresholds to be applied, (the same 
% threshold is applied to all cylinders if there is only one column).  The rows entries of |Tx|
% denote different thresholds to be applied to any given cylinder, resulting in different knock 
% probability curves.  Input parameter |cdfData| is a structure array of experimental cdf data
% with fields |cdfData.x|, |cdfData.Fx|, and |cdfData.theta| - see eCdf
%
% |[pCurve1,theta1]= knockP(Tx,cdfData,cyl)| computes the knock probability curve values only 
% for the cylinder(s) that are specified by the scalar or vector argument |cyl|. 
% If |cyl| is empty |[]|, the knock probability curves are computed for all cylinders.
%
% |[pCurve1,theta1]= knockP(Tx,cdfData,cyl,theta)| computes and interpolates (cubic spline) the 
% knock probability curve onto the spark angle base defined by the vector |theta|, and the 
% output argument |theta1| then equals |theta|. If |theta| is empty, the angle base |[cdfData.theta]| is used.
%
% |knockP(-)| with no left hand arguments, or |knockP(-,'Fig')| with specified input |'Fig'|, 
% also plots the computed knock probability curves.
%
% Examples
% theta=[-3:2]; BLindx=4;               % Specify spark angles used for the sweep, and BL knock index
% xi= loadSweep(speed,load,theta);      % Load a corresponding cell array of [numCycles x numCyl] data
% myCdf= eCdf(xi,theta);                % Compute enpirical Cdf for all cylinders and all spark conditions
% tradTx= p2x(0.99,myCdfn(BLindx));     % Compute 1% knock prob thresholds [1 x nCyl] for each cyl at BL
% knockP(tradTx,myCdf,[],[],'Fig');     % Compute and plot the 1% knock prob curves for all cyl at the expt points
% theta1= [-3:0.01:2]';                 % Define anglebase on which to interpolate the results
% myTxs= p2x([0.99 0.8],myCdf(BLindx)); % Compute 1% and 20% knock prob thresholds [2 x nCyl] for each cyl at BL
% knockP(myTxs,myCdf,1,theta,'Fig');    % Compute and plot the 1% and 20% interpolated knock prob curves for cyl #1
%
% See also
% eCdf normCdf p2x optTx 

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Check input arguments
if ~isa(cdfData,'struct'), error('cdfData should be a struct with fields x and Fx'); end;
if (nargin<3)||isempty(cyl), cyl= [1:size(cdfData(1).x,2)]; end;
if (nargin<4)||isempty(theta), theta=[]; end;
if (size(Tx,2)==1) && (length(cyl)>1), Tx= repmat(Tx,1,length(cyl)); end;
if (size(Tx,2)~=length(cyl)),
    error(['Tx must either be a vector of intensities to be applied to all cylinders'...
           'or a matrix where the number of columns in Tx must match the length of cyl']);
end;

% Compute and interpolate the knock probability curve
pCurve= 1 - x2p(Tx,cdfData,cyl);                        % nTheta x nCyl x nProbTargets
if ~isempty(theta),
    for i=1:size(pCurve,3)
        pCurve1(:,:,i)= interp1([cdfData.theta],pCurve(:,:,i),theta,'PCHIP');
    end;
    theta1= theta;
else
    pCurve1= pcurve;
    theta1= [cdfData.theta];
end;


% Plot results if required
if (nargout==0) || ((nargin>=5) && ~isempty(fig)),
    figure, 
    for i=1:size(pCurve1,3),                             % for each ProbTarget
        plot(theta1,pCurve1(:,:,i)); hold all;           %   plot knockP vs sparkAdvance
    end;                                                 % end;
    xlabel('Relative spark advance [deg]');
    ylabel('Knock probability');
end;
