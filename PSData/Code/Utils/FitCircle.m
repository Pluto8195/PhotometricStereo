function [xc, yc, r] = FitCircle(x, y, options)

% [xc, yc, r] = FitCircle(x, y, options)
%
% Fit a circle based on given data 'x' and 'y', which are Nx1 vectors for points
% on/near the circle.
%
% The 'options' is a struct with following supported field:
%   'Visualize': whether to do the visualization of fit result or not,
%                options are 'on' or {'off'}.
%
%   Author: Ying Xiong.
%   Created: Aug 26, 2013.

% Check input.
assert(isvector(x) && isvector(y) && length(x)==length(y));
x = x(:);
y = y(:);
if (~exist('options', 'var'))   options = [];   end
  
% Initialization.
xc_0 = mean(x);
yc_0 = mean(y);
r_0 = std(x,1) + std(y,1);
theta_0 = [xc_0; yc_0; r_0];

% Do the optimization.
fcn = @(theta)FitCircleCost(theta, x, y);
theta = NonlinearLeastSquares(fcn, theta_0);
xc = theta(1);
yc = theta(2);
r = theta(3);

% Show results if requested.
if (isfield(options, 'Visualize') && strcmp(options.Visualize, 'on'));
  plot(x, y, 'r.');
  hold on;
  phi = linspace(0, 2*pi, 100);
  plot(xc + r*cos(phi), yc + r*sin(phi));
  axis equal;
end

end


function [F, J] = FitCircleCost(theta, x, y)

xc = theta(1);
yc = theta(2);
r = theta(3);

r_data = sqrt((x-xc).^2 + (y-yc).^2);

F = r_data - r;
J = [(xc-x)./r_data, ...
     (yc-y)./r_data, ...
     -ones(size(x))];

end
