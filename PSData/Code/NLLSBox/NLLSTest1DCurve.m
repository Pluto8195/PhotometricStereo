function [y, dy] = NLLSTest1DCurve(x, a)

% [y, dy] = NLLSTest1DCurve(x, a)
%
% A 1D curve function for test.
%   y(x; a) = a(3) * exp(a(1)*x) + a(4)*exp(a(2)*x).
%
% The second output 'dy' is the gradient of 'y' over 'a', which is a Nx4 matrix.
%
%   Author: Ying Xiong.
%   Created: Jan 20, 2014.

y = a(3) * exp(a(1)*x) + a(4)*exp(a(2)*x);
if (nargout > 1)
  dy = [x.*a(3).*exp(a(1)*x), ...
        x.*a(4).*exp(a(2)*x), ...
        exp(a(1)*x), ...
        exp(a(2)*x)];
end
