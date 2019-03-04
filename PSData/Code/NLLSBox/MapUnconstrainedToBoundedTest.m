function MapUnconstrainedToBoundedTest()

%   Author: Ying Xiong.
%   Created: Jan 29, 2014.

rng(0);
nTest = 100;

lb = [-Inf -Inf -0.5 -0.8 -0.5 -0.4 -Inf -0.1]';
ub = [ Inf  0.3  Inf  0.1  Inf  0.3  0.2  0.9]';
nDims = length(lb);

fcn = MapUnconstrainedToBounded(lb, ub);
for i = 1:nTest
  x = randn(nDims, 1);
  y = fcn(x);
  assert(all(lb<=y) && all(y<=ub));
  CheckJacobian(@(x)MapUnconstrainedToBoundedTestCost(fcn, x), nDims);
end

fprintf('Passed.\n');

end

function [f, J] = MapUnconstrainedToBoundedTestCost(fcn, x)

[f, df] = fcn(x);
J = diag(df);

end
