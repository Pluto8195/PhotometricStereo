function [c, dc] = NLLSCurveToCost(a, curveFcn, x, y)

% [c, dc] = NLLSCurveToCost(a, curveFcn, x, y)
%
% Turn a curve model function to a least squares cost that can be minimized
% by 'NonlinearLeastSquares.m' function.
%
% NOTE: in curve fit, the cost does not need to be squared. Doing the square is
% equivalent to penalize the fourth-order error, which we do here to signify the
% difference between our method as opposed to 'lsqnonlin'.
%
%   Author: Ying Xiong.
%   Created: Jan 20, 2014.

if (nargout==1)
  ya = curveFcn(x, a);
  c = (ya - y).^2;
else
  [ya, dya] = curveFcn(x, a);
  ydiff = ya - y;
  c = ydiff.^2;
  dc = 2 * dya .* repmat(ydiff, [1, length(a)]);
end
