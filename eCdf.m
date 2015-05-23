function cdfData= eCdf(xi,theta,cyl,fig)

% eCdf Empirical cumulative distribution function for a cell array of spark sweep experiments
%
% Syntax
% cdfData= eCdf(xi,theta)
% cdfData= eCdf(xi,theta,cyl)
% cdfData= eCdf(xi,theta,cyl,'Fig')
%
% Description
% |cdfData= eCdf(xi,theta)| returns the empirical cumulative distribution function |cdfData.Fx|, 
% evaluated at the points in |cdfData.x|, using the data in |xi| obtained from an experiment 
% performed at relative spark angle |cdfData.theta= theta|.
%
% Input parameter |xi| may be a single |[numCycles x numCylinders]| matrix of data obtained from
% an experiment at spark advance |theta|, or a cell array of such matrices recorded across a 
% spark sweep defined by the vector of spark angles |theta|.
%
% The output |cdfData| is a struture array of length equal to |length(theta)|, the number of
% distinct experiments, (and hence also equal to the number of data matrices in cell arrray |xi|).
% |cdfData.Fx| is a vector of length equal to the |numCycles| length of recorded data in |xi|
% and is common for all cylinders.  |cdfData.x| is a |[numCycles x numCylinders]| matrix of
% |x| ordinand points corresponding to the |cdfData.Fx| values.
% 
% |cdfData= eCdf(xi,theta,cyl)| computes the empirical cumulative distribution function only 
% for the cylinder(s) in matrix |xi| that are specified by the scalar or vector argument |cyl|.
% If |cyl| is empty |[]|, or omitted, eCdf is computed for all cylinders.
%
% |eCdf(-)| with no left hand arguments, or |eCdf(-,'Fig')| with specified input |'Fig'|, 
% also plots the empirical cumulative distribution function of the specified data.

%
% Examples
% theta=[-3:2]; BLindx=4;               % Specify spark angles used for the sweep, and BL knock index
% xi= loadSweep(speed,load,theta);      % Load a corresponding cell array of [numCycles x numCyl] data
% eCdf(xi{4},theta(BLindx),[],'Fig');   % Compute and plot eCdf for all cylinders at BL spark conditions
% c1cdf= eCdf(xi,theta,[1,3],'Fig');    % Compute and plot eCdf for cyls #1,3 at all spark conditions
%
% See also
% normCdf x2p p2x

% Version 1.0 by J.C. Peyton Jones
% copyright Villanova University 5/29/2014

% Check input arguments
if isa(xi,'numeric'), xi={xi}; end;
if (nargin<3)||isempty(cyl), cyl= [1:size(xi{1},2)]; end;

for i= 1:length(xi),
    
    % compute the basic cdf
    Fx= [0; [1:length(xi{i})]' / length(xi{i})];
    x= [zeros(1,length(cyl)); sort(xi{i}(:,cyl))];
    
    % deal with repeated values in the data
    dx= diff(x,1,1)==0;
    for n=1:length(dx)
        x(n+1,dx(n,:))= x(n,dx(n,:)) + x(end,dx(n,:))/1e10;
    end;
    
    % output results
    cdfData(i).Fx= Fx;
    cdfData(i).x= x;
    cdfData(i).theta= theta(i);
               
end;

% plot if required
if (nargout==0) || ((nargin>=4) && ~isempty(fig)),
    figure
    for i= 1:length(cdfData),
        plot(cdfData(i).x(:,cyl),cdfData(i).Fx);
        if length(cyl)==1, hold all; else hold on; end;
    end;
    xlabel('Intensity');
    ylabel('CDF');
end;

    
