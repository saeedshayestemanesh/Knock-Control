function nCdf=normCdf(cdfData,normVal,cyl,fig)

% nCdf Normalize cumulative density function data
%
% Syntax
% nCdf=normCdf(cdfData,normVal)
% nCdf=normCdf(cdfData,normVal,cyl)
% nCdf=normCdf(cdfData,normVal,cyl,'Fig')
%
% Description
% |nCdf=normCdf(cdfData,normVal)| normalizes cdfData.x, the empirical cumulative density function
% x-axis knock intensity data, with respect to the specified |normVal|. Input parameter |cdfData|
% is a structure array of experimental cdf data with fields |cdfData.x|, |cdfData.Fx|, 
% and |cdfData.theta| - see eCdf
%
% |nCdf=normCdf(cdfData,normVal,cyl)| normalizes the empirical cumulative distribution function only 
% for the cylinder(s) in matrix |cdfData.x| that are specified by the scalar or vector argument |cyl|.
% If |cyl| is empty |[]|, or omitted, normalization is performed for all cylinders.
%
% |normCdf(-)| with no left hand arguments, or |normCdf(-,'Fig')| with specified input |'Fig'|, 
% also plots the normalized empirical cumulative distribution function of the specified data.
%
% Examples
% theta=[-3:2]; BLindx=4;               % Specify spark angles used for the sweep, and BL knock index
% xi= loadSweep(speed,load,theta);      % Load a corresponding cell array of [numCycles x numCyl] data
% myCdf= eCdf(xi,theta);                % Compute enpirical Cdf for all cylinders and all spark conditions
% normVal= p2x(.99,myCdf(BLindx),1);    % Find the value that gives 1% knock for cyl #1 at BL
% myCdfn= normCdf(myCdf,normVal);       % Normalize all cylinders with respect to this value
% normCdf(myCdf(BLindx),normVal,[],'Fig'); % Normalize and plot normCdf for all cylinders at BL spark condition
% normCdf(myCdf,normVal,[1,3],'Fig');   % Compute and plot normCdf for cyls #1,3 at all spark conditions
%
% See also
% eCdf x2p p2x

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Check input arguments
if ~isa(cdfData,'struct'), error('cdfData should be a struct with fields x and Fx'); end;
if (nargin<3)||isempty(cyl), cyl= [1:size(cdfData(1).x,2)]; end;

% Normalize the knock intensity data
nCdf= cdfData;
for i=1:length(cdfData),
    nCdf(i).x= cdfData(i).x(:,cyl) ./ normVal;
end;

% plot if required
if (nargout==0) || ((nargin>=4) && ~isempty(fig)),
    figure
    for i= 1:length(nCdf),
        plot(nCdf(i).x(:,cyl),nCdf(i).Fx);
        if length(cyl)==1, hold all; else hold on; end;
    end;
    xlabel('Normalized intensity [-]'), 
    ylabel('CDF');
end;

