function x=p2x(p,cdfData,cyl)

% p2x Evaluate/look-up inverse empirical cumulative density function F^-1(p)
%
% Syntax
% x= p2x(x,cdfData)
% x= p2x(x,cdfData,cyl)
%
% Description
% |x= p2x(p,cdfData)| returns a |[nExpts x nCyl x length(p)]| matrix of knock intensity values
% corresponding to the scalar or vector of specified cdf probabilities, |p|. Input parameter 
% |cdfData| is a structure array of experimental cdf data with fields |cdfData.x|, |cdfData.Fx|, 
% and |cdfData.theta| - see eCdf
%
% |x= p2x(x,cdfData,cyl)| returns a |[nExpts x length(cyl) x length(p)]| matrix of knock intensity
% values only for the cylinder(s) that are specified by the scalar or vector argument |cyl|.
%
% Examples
% theta=[-3:2]; BLindx=4;               % Specify spark angles used for the sweep, and BL knock index
% xi= loadSweep(speed,load,theta);      % Load a corresponding cell array of [numCycles x numCyl] data
% myCdf= eCdf(xi,theta);                % Compute enpirical Cdf for all cylinders and all spark conditions
% normVal= p2x(.99,myCdf(BLindx),1);    % Find the value that gives 1% knock for cyl #1 at BL
% myCdfn= normCdf(myCdf,normVal);       % Normalize all cylinders with respect to this value
% tradTx= p2x(0.99,myCdfn(BLindx));     % Compute 1% knock prob thresholds [1 x nCyl] for each cyl at BL
% MxVals= p2x([0.99 0.8],myCdfn);       % Compute a [nExpts x nCyl x 2] matrix of intensity values...
%                                       % ...for the two prob values [0.99 0.8] applied to all data in myCdfn
% 
% See also
% eCdf normCdf x2p

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Check input arguments
if ~isa(cdfData,'struct'), error('cdfData should be a struct with fields x and Fx'); end;
if sum((p>1)|(p<0)), error(['Vector p must have values in the range 0..1']); end;
if (nargin<3)||isempty(cyl), cyl= [1:size(cdfData(1).x,2)]; end;

for i=1:length(cdfData),
    for j=1:length(cyl),
        x(i,j,:)= interp1(cdfData(i).Fx,cdfData(i).x(:,j),p(:));
    end;
end;

