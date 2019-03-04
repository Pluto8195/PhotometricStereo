%   Author: Ying Xiong.
%   Created: Feb 08, 2014.

rng(0);

M = 10;
N = 100;

lambda = rand(M, 1);
L_hat = normc(randn(3, M));
I = rand(M, N);

fcn = @(lambda)PSEstimateLightStrengthCost(lambda, L_hat, I);

CheckJacobian(fcn, M);

fprintf('Passed.\n');
