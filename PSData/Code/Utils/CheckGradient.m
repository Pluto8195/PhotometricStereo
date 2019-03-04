function [success, data] = CheckGradient(varargin)

% CheckGradient(fdf, nDims)
% CheckGradient(fdf, nDims, data)
% CheckGradient(f, df, nDims)
% CheckGradient(f, df, nDims, data)
% [success, data] = CheckGradient(...)
%
% Numerically check whether the gradient function is correct or not, or more
% specifically, whether the following quantities are close to each other
%   * f(x) - f(x0)
%   * (x-x0) \cdot f'(x0)
% We consider them to be close enough if **either one** of the following is true
%   1. the absolute difference is smaller than (m * ||x - x0||);
%   2. the relative difference is smaller than (M * ||x - x0||).
%
% INPUT:
%   fdf: a function handle with a single input (vector) and two outputs, with
%        first the function value (scalar) and second the function gradient
%        (vector), used as "[y, dy] = fdf(x);"
%   f, df: split the 'fdf' to two function handles.
%   nDims: the function's input dimension, i.e. the length of vector 'x'.
%   data: the data used for gradient test, a structure with following fields
%         x0: nDims-by-1 vector for the evaluation point, default
%             {randn(nDims, 1)}.
%         dx: nDims-by-1 unit vector for gradient direction, default
%             {randn(nDims, 1) with normalization}.
%         delta: the step size for 'dx', default {1e-4}.
%             [[ x - x0 = delta * dx. ]]
%         m, M: the thresholds specified above, default {0.01} and {10}.
%
% OUTPUT:
%   If no output is given, the function will have no effect if the check
%   succeed, but stop the program (by throwing an error) if the check
%   failed. If output is given:
%     success: a boolean, true for success and false for fail.
%     data: same as the input data (default values filled if not provided),
%           with following additional fields:
%           y0: the function value at 'x0', scalar.
%           y:  the function value at 'x = x0 + delta * dx', scalar.
%           dy0: the function gradient at 'x0', vector of same size as 'x0'.
%
%   Author: Ying Xiong.
%   Created: Feb 24, 2013.

%% Read input.
if (nargin < 2)
  error('At least two input are expected.');
end
assert(isa(varargin{1}, 'function_handle'));
if (isa(varargin{2}, 'function_handle'))
  f = varargin{1};
  df = varargin{2};
  nFnHandles = 2;
else
  fdf = varargin{1};
  nFnHandles = 1;
end
nDims = varargin{nFnHandles+1};
if (nargin > nFnHandles+1)
  data = varargin{nFnHandles+2};
else
  data = struct();
end

%% Set fields in 'data' struct.
if (~isfield(data, 'x0'))   data.x0 = randn(nDims, 1);   end
if (~isfield(data, 'dx'))   data.dx = randn(nDims, 1);   end
data.dx = data.dx / norm(data.dx);
if (~isfield(data, 'delta'))   data.delta = 1e-4;   end
if (~isfield(data, 'm'))   data.m = 0.01;   end
if (~isfield(data, 'M'))   data.M = 10;   end

%% Do the check.
if (nFnHandles == 1)
  [data.y0, data.dy0] = fdf(data.x0);
  data.y = fdf(data.x0 + data.delta * data.dx);
else
  data.y0 = f(data.x0);
  data.y = f(data.x0 + data.delta * data.dx);
  data.dy0 = df(data.x0);
end
if (~isscalar(data.y) || ~isscalar(data.y0))
  error('The first output of the function is not scalar.');
end
% Check the gradient is of the right size.
if (~isvector(data.dy0))
  error('The gradient output is not a vector.\n');
end
data.dy0 = data.dy0(:);
if (length(data.dy0) ~= nDims)
  error(['The gradient output is of %d dimensions, ', ...
         'not the same as ''nDims'' (%d).'], ...
        length(data.dy0), nDims);
end
val1 = data.y - data.y0;
val2 = data.delta * data.dx' * data.dy0;
success = CheckNearAbs(val1, val2, data.m * data.delta) || ...
          CheckNearRel(val1, val2, data.M * data.delta);

%% Throw error if necessary.
if (nargout == 0 && ~success)
  fprintf('f(x) - f(x0) = %e\n', val1);
  fprintf('(x-x0) * f''(x0) = %e\n', val2);

  fprintf('Absolute difference = %e > ', abs(val1-val2));
  fprintf('m * ||x-x0|| = %s * %s = %s\n', ...
          num2str(data.m), num2str(data.delta), num2str(data.m*data.delta));

  fprintf('Relative difference = %e > ', ...
          abs(val1 - val2) ./ max(abs(val1), abs(val2)));
  fprintf('M * ||x-x0|| = %s * %s = %s\n', ...
          num2str(data.M), num2str(data.delta), num2str(data.M*data.delta));

  error('CheckGradient failed!');
end
