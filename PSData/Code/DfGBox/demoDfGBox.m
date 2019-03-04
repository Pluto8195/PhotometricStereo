%   Author: Ying Xiong.
%   Created: Jan 27, 2014.

% Ground truth depth map.
sz = 128;
Z = peaks(sz);
[p, q] = gradient(Z);

% Recovered depth map by our algorithm.
Z2 = DepthFromGradient(p, q);

% Visualization.
[x, y] = meshgrid(1:sz, 1:sz);
Z0 = zeros(size(x));

nSamples = 5;
xs = x(1:nSamples:end, 1:nSamples:end);
ys = y(1:nSamples:end, 1:nSamples:end);
Z0s = Z0(1:nSamples:end, 1:nSamples:end);
ps = p(1:nSamples:end, 1:nSamples:end);
qs = q(1:nSamples:end, 1:nSamples:end);

figure;
mesh(x, y, Z2); hold on;
h = quiver3(xs, ys, Z0s-10, ps, qs, Z0s, 2);
set(h, 'LineWidth', 2);
set(gca, 'XLim', [0 sz], 'YLim', [0 sz]);
