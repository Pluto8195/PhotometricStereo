function fcn = MapBoundedToUnconstrained(lb, ub)

% fcn = MapBoundedToUnconstrained(lb, ub)
%
% Create a function that maps from bounded space to unconstrained space, which
% is one possible inverse of 'MapUnconstrainedToBounded' function.
%
%   Author: Ying Xiong.
%   Created: Jan 30, 2014.

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

fcn = @(x)MapBoundedToUnconstrainedSub(x, lb, ub, idx1, idx2, idx3);

end

function y = MapBoundedToUnconstrainedSub(x, l, u, idx1, idx2, idx3)

N = length(l);
y = x;

y(idx1) = real(sqrt((u(idx1)+1-x(idx1)).^2 - 1));

y(idx2) = real(sqrt((l(idx2)-1-x(idx2)).^2 - 1));

d3 = u(idx3)-l(idx3);
y(idx3) = d3/2 .* real(asin((2*x(idx3)-u(idx3)-l(idx3))./d3));

end
