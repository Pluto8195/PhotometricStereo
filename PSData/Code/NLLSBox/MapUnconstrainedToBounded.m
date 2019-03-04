function fcn = MapUnconstrainedToBounded(lb, ub)

% fcn = MapUnconstrainedToBounded(lb, ub)
%
% Create a function that maps from unconstrained space 'y' to bounded space
% 'x', such that for any 'y', we have 'x=fcn(y)' satisfying lb <= x <= ub. The
% function also returns the derivative as
%     [x, dx] = fcn(y)
% with 'x', 'y', 'dx' all Nx1 vectors.
%
%   Author: Ying Xiong.
%   Created: Jan 29, 2014.

assert(isvector(lb) && isvector(ub) && length(lb)==length(ub));
lb = lb(:);
ub = ub(:);
N = length(lb);

lb_finite = isfinite(lb);
ub_finite = isfinite(ub);

idx1 = find(~lb_finite &  ub_finite);
idx2 = find( lb_finite & ~ub_finite);
idx3 = find( lb_finite &  ub_finite);

assert(all(lb(idx3) < ub(idx3)));

fcn = @(y)MapUnconstrainedToBoundedSub(y, lb, ub, idx1, idx2, idx3);

end

function [x,dx] = MapUnconstrainedToBoundedSub(y, l, u, idx1, idx2, idx3)

N = length(l);

x = y;

xtmp1 = sqrt(y(idx1).^2 + 1);
x(idx1) = u(idx1) + 1 - xtmp1;

xtmp2 = sqrt(y(idx2).^2 + 1);
x(idx2) = l(idx2) - 1 + xtmp2;

d3 = u(idx3) - l(idx3);
xtmp3 = 2 * y(idx3) ./ d3;
x(idx3) = (l(idx3)+u(idx3))/2 + d3/2 .* sin(xtmp3);

if (nargout > 1)
  dx = ones(N, 1);
  dx(idx1) = -y(idx1) ./ xtmp1;
  dx(idx2) =  y(idx2) ./ xtmp2;
  dx(idx3) = cos(xtmp3);
end

end
