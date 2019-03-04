%   Author: Ying Xiong.
%   Created: Jan 30, 2014.

rng(0);
nTest = 100;

lb = [-Inf -Inf -0.5 -0.8 -0.5 -0.4 -Inf -0.1]';
ub = [ Inf  0.3  Inf  0.1  Inf  0.3  0.2  0.9]';
nDims = length(lb);
tol = 1e-10;

fcn1 = MapBoundedToUnconstrained(lb, ub);
fcn2 = MapUnconstrainedToBounded(lb, ub);

for i = 1:nTest
  x = randn(nDims, 1);
  x(x<lb) = lb(x<lb);
  x(x>ub) = ub(x>ub);
  y = fcn1(x);
  x2 = fcn2(y);
  CheckNear(x, x2, tol);
end

fprintf('Passed.\n');
