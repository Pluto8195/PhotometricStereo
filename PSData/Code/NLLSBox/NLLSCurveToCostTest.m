function NLLSCurveToCostTest()

%   Author: Ying Xiong.
%   Created: Jan 20, 2014.

rng(0);

x = randn(100, 1);
y = randn(100, 1);
CheckGradient(@(a)NLLSCurveToCostTestCost(a, @NLLSTest1DCurve, x, y), 4);

fprintf('Passed.\n');

end

function [aggC, aggDc] = NLLSCurveToCostTestCost(a, curveFcn, x, y)

[c, dc] = NLLSCurveToCost(a, curveFcn, x, y);
aggC = sum(c(:));
aggDc = sum(dc, 1);

end
