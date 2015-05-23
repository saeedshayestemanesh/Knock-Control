function [TxVals,kpTarg]= optTx(cdfData,refIndx,cmpIndx,cyl,fig)

% optTx Computes optimized knock thresholds
%
% Syntax
% [TxVals,kpTarg]= optTx(cdfData,refIndx)
% [TxVals,kpTarg]= optTx(cdfData,refIndx,cmpIndx)
% [TxVals,kpTarg]= optTx(cdfData,refIndx,cmpIndx,cyl)
% [TxVals,kpTarg]= optTx(cdfData,refIndx,cmpIndx,cyl,fig)
%
% Description
% |[TxVals,kpTarg]= optTx(cdfData,refIndx,cmpIndx)| compares a reference distribution |cfdData(refIndx)|
% with one or more comparison distributions |cfdData(cmpIndx)| identified by the scalar or vector |cmpIndx|
% and returns |TxVals| a |[length(cmpIndx x nCyl]| matrix of optimum threshold values that minimize the
% overlap between reference and comparison distribution.  Output |kpTarg| is a corresponding matrix of 
% knock probability target values that result if the optimum threshold is applied to the reference distribution.
%
% |[TxVals,kpTarg]= optTx(cdfData,refIndx)| with no comparison distributions specified, or with cmpIndx=[]
% compares the reference distribution to all other distributions / experiments in |cdfData|.
%
% |[TxVals,kpTarg]= optTx(cdfData,refIndx,cmpIndx,cyl)| computes the optimum thesholds only 
% for the cylinder(s) that are specified by the scalar or vector argument |cyl|. 
% If |cyl| is empty |[]|, the knock probability curves are computed for all cylinders.
%
% |optTx(-)| with no left hand arguments, or |optTx(-,'Fig')| with specified input |'Fig'|, 
% also plots the computed overlap / misclassification probability curves.
%
% Examples
% NEED TO DO EXAMPLES RETURN OVERLAP PLOTS!!!
% theta=[-3:2]; BLindx=4;                     % Specify spark angles used for the sweep, and BL knock index
% xi= loadSweep(speed,load,theta);            % Load a corresponding cell array of [numCycles x numCyl] data
% myCdf= eCdf(xi,theta);                      % Compute enpirical Cdf for all cylinders and all spark conditions
% [newTx,kpTarg]= optTx(myCdf,BLindx,[],[],'Fig');  % all expts, optimized wrt BL distribution [nExpts x nCyl]
% theta1= [-3:0.01:2]';                       % Define anglebase on which to interpolate the results
% knockP(newTx(end,:),myCdf,[],theta1,'Fig'); % Compute and plot the optimum BL-to-(BL+2) knock prob curve
%
% See also
% eCdf normCdf p2x optTx 

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Check input arguments
if ~isa(cdfData,'struct'), error('cdfData should be a struct with fields x and Fx'); end;
if (nargin<3)||isempty(cmpIndx), cmpIndx= [1:length(cdfData)]; end;
if (nargin<4)||isempty(cyl), cyl= [1:size(cdfData(1).x,2)]; end;

% Determine an appropriate regular intensity grid spanning most x values
% and interpolate Fx values onto this grid.
xmax= -inf;
for i=1:length(cmpIndx),
    xmax= max([xmax,max(cdfData(cmpIndx(i)).x)]);
end;
xmax= 0.7*xmax;
xPts= [xmax/100:xmax/100:xmax]';
cdfDataRef= cdfData(refIndx);
cdfDataFx= x2p(xPts,cdfData(cmpIndx),cyl);
cdfDataRefFx= x2p(xPts,cdfDataRef,cyl);

% Determine the thresholds that minimize the overlap / misclassification probability
for i=1:length(cmpIndx), 
    diffP= cdfDataFx(i,:,:) - (1-cdfDataRefFx);
    for j=1:length(cyl),
        TxVals(i,j)= xPts(find(diffP(1,j,:)>=0,1,'first'));
    end;
    kpTarg(i,:)= 1 - x2p(TxVals(i,:),cdfDataRef,cyl);
end;

% % Determine the thresholds that minimize the overlap / misclassification probability
% for i=1:length(cmpIndx), 
% 	missclassifyP= squeeze(cdfDataFx(i,:,:))+(1-squeeze(cdfDataFx(refIndx,:,:)));
% 	missclassifyP= 1-abs(missclassifyP-1);
%     for j=1:length(cyl),
%         [~,indx]= min(missclassifyP(i,j));
%         TxVals(i,j)= xPts(find(diffP(1,j,:)>=0,1,'first'));
%     end;
%     kpTarg(i,:)= 1 - x2p(TxVals(i,:),cdfData(refIndx),cyl);
% end;



% Plot results if required
if (nargout==0) || ((nargin>=5) && ~isempty(fig)),

    figure, plot(cdfData(refIndx).x(:,cyl),1-cdfData(refIndx).Fx); 
    if length(cyl)==1, hold all; else hold; end;
    for i=1:length(cmpIndx),
        plot(cdfData(cmpIndx(i)).x(:,cyl),cdfData(cmpIndx(i)).Fx)
    end;
    xlabel('Threshold Intensity [-]'), 
    ylabel('CDF: F(x) and (1-F_{ref}(x))');

    figure,
    %for i=[1,3:length(cmpIndx)],
    for i=1:length(cmpIndx),
        missclassifyP= squeeze(cdfDataFx(i,:,:))+(1-squeeze(cdfDataRefFx));
        missclassifyP= 1-abs(missclassifyP-1);
        plot(xPts,missclassifyP); hold all;
    end;
    xlabel('Threshold Intensity [-]'), 
    ylabel('Total Misdiagnosis Probability: (\alpha + \beta)'); 
    ylim([0,1.05]);


end;

