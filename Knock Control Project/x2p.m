function p=x2p(x,cdfData,cyl)

% x2p Evaluate/look-up empirical cumulative density function p=F(x)
%
% Syntax
% p= x2p(x,cdfData)
% p= x2p(x,cdfData,cyl)
%
% Description
% |p= x2p(x,cdfData)| returns a |[nExpts x nCyl x length(x)]| matrix of probability values
% corresponding to the scalar or vector of specified knock intensities, |x|. Input parameter 
% |cdfData| is a structure array of experimental cdf data with fields |cdfData.x|, |cdfData.Fx|, 
% and |cdfData.theta| - see eCdf
%
% |p= x2p(x,cdfData,cyl)| returns a |[nExpts x length(cyl) x length(x)]| matrix of probability
% values only for the cylinder(s) that are specified by the scalar or vector argument |cyl|.
%
% Examples
% theta=[-3:2]; BLindx=4;               % Specify spark angles used for the sweep, and BL knock index
% xi= loadSweep(speed,load,theta);      % Load a corresponding cell array of [numCycles x numCyl] data
% myCdf= eCdf(xi,theta);                % Compute enpirical Cdf for all cylinders and all spark conditions
% tradTx= p2x(0.99,myCdfn(BLindx));     % Compute 1% knock prob thresholds [1 x nCyl] for each cyl at BL
% knkP= 1- x2p(tradTx,myCdf);           % Compute the resulting knock probability for all spark expts and all cyl
% plot([myCdf.theta],knkP,'-o');        % Plot the measured knock probability curve points for all cylinders
% 
% See also
% eCdf normCdf p2x

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014


% Check input arguments
if ~isa(cdfData,'struct'), error('cdfData should be a struct with fields x, Fx and theta'); end;
if (nargin<3)||isempty(cyl), cyl= [1:size(cdfData(1).x,2)]; end;
if (size(x,2)==1) && (length(cyl)>1), x= repmat(x,1,length(cyl)); end;
if (size(x,2)~=length(cyl)),
    error(['x must either be a vector of intensities to be applied to all cylinders'...
           'or a matrix where the number of columns in x must match the length of cyl']);
end;

for i=1:length(cdfData),
    for j=1:length(cyl),
        x1= x(:,j); % deal with out of range values
        xmax= max(cdfData(i).x(:,cyl(j)));
        xmin= min(cdfData(i).x(:,cyl(j)));
        x1(x(:,j)>xmax)= xmax;
        x1(x(:,j)<xmin)= xmin;
        p(i,j,:)= interp1(cdfData(i).x(:,cyl(j)),cdfData(i).Fx,x1(:));
    end;
end;
