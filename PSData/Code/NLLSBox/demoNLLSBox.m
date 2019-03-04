%   Author: Ying Xiong.
%   Created: Jan 20, 2014.

rng(0);

%% Fitting a 1D curve.
% Set up model parameters.
a_gt = [1; -0.5; 2; 3];
a0 = randn(4, 1);
nData = 31;
xLims = [-4; 3];
noiseStd = 2;

% Generate data.
x = xLims(1) + (xLims(2)-xLims(1)) * rand(nData, 1) ;
y = NLLSTest1DCurve(x, a_gt) + randn(nData, 1) * noiseStd;

% Find the optimal parameters by nonlinear least squares.
fcn = @(a)NLLSCurveToCost(a, @NLLSTest1DCurve, x, y);
options = struct('Display', 'off', 'DerivativeCheck', 'on');
a_lsqnonlin = lsqnonlin(fcn, a0, [], [], options);
a_ours = NonlinearLeastSquares(fcn, a0, [], [], options);

% Do visualization.
figure; hold on; box on;
plot(x, y, '+', 'MarkerSize', 10);
nSamples = 31;
xx = linspace(xLims(1), xLims(2), nSamples);
y_gt = NLLSTest1DCurve(xx, a_gt);
y_lsqnonlin = NLLSTest1DCurve(xx, a_lsqnonlin);
y_ours = NLLSTest1DCurve(xx, a_ours);
plot(xx, y_gt, 'k', 'LineWidth', 2);
plot(xx, y_lsqnonlin, 'r-.', 'LineWidth', 2);
plot(xx, y_ours, '--', 'LineWidth', 2, 'Color', [0; 0.6; 0]);
legend('Data', 'Ground truth', 'lsqnonlin result', 'our result', ...
       'Location', 'NorthWest');
set(gca, 'FontSize', 15);
