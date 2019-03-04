%   Author: Ying Xiong.
%   Created: Jan 27, 2014.

% All the depth maps to be tested.
tol = 0.05;
Zs = {peaks(63), peaks(128)};
[x, y] = meshgrid(1:63, 1:63);
Zs{end} = Zs{1} + 0.1*x - 0.05*y;   % Used for non-periodic test.

% Do the test.
for i = 1:length(Zs)
  Z = Zs{i};
  [p, q] = gradient(Z);
  Z2 = DepthFromGradient(p, q);
  CheckNear(Z-mean(Z(:)), Z2, tol);
end

% Test for periodic recovery method.
Z = Zs{1};
[p, q] = gradient(Z);
Z2 = DepthFromGradient(p, q, struct('periodic', 1));
CheckNear(Z-mean(Z(:)), Z2, tol);

fprintf('Passed.\n');
