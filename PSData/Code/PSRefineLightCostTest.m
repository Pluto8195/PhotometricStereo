%   Author: Ying Xiong.
%   Created: Feb 13, 2014.

rng(0);

M = 10;
N = 100;

L = normc(randn(3, M));
I = rand(M, N);

fcn = @(L)PSRefineLightCost(L, I);

CheckJacobian(fcn, 3*M);

fprintf('Passed.\n');
