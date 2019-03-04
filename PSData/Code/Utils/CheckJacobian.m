function [success, data] = CheckJacobian(varargin)

% CheckJacobian(fcn, N)
% CheckJacobian(fcn, N, M)
% CheckJacobian(..., data)
% [success, data] = CheckJacobian(...)
%
% Numerically check whether the Jacobian matrix 'J' of a vector function 'f' is
% correct or not. We do this by defining a scalar function
%     F  = \sum_i c_i f_i,
%     dF = \sum_i c_i J(i,:)'.
% with c_i's scalar coefficients, and check the correctness of the gradient 'dF'
% of function 'F'.
% See "help CheckGradient" for more details.
%
% INPUT:
%   fcn:  a function handle with a single input and two outputs, with the form
%             [f, J] = fcn(x),
%         where 'x' is an Nx1 vector, 'f' an Mx1 vector, and 'J' an MxN matrix.
%   N:    the dimension of input vector 'x'.
%   M:    the dimension of output vector 'f', which is optional and can be
%         inferred from 'fcn'.
%   data: a structure with following fields
%     'x0', 'dx', 'delta', 'm', 'M': same as that in 'CheckGradient.m'.
%     'c': a Mx1 vector for coefficients creating 'F', default {randn(M, 1)}.
%
% OUTPUT:
%   Same as 'CheckGradient.m'.
%
%   Author: Ying Xiong.
%   Created: Jan 21, 2014.

%% Process input and set default.

% Read input arguments.
fcn = varargin{1};
N = varargin{2};
if (nargin == 2)
  data = [];
elseif (nargin == 3)
  if (isstruct(varargin{3}))    data = varargin{3};
  else                          M = varargin{3};   data = [];
  end
elseif (nargin == 4)
  M = varargin{3};
  data = varargin{4};
else
  error('Wrong input.');
end

% Set 'M' if not provided.
if (~exist('M', 'var'))
  if (isfield(data, 'c'))
    % Set from 'data.c'.
    M = length(data.c);
  else
    % Need to infer from fcn.
    if (~isfield(data, 'x0'))    data.x0 = randn(N, 1);   end
    data.y0 = fcn(data.x0);
    M = length(data.y0);
  end
end

% Set 'data.c' if not provided.
if (~isfield(data, 'c'))
  data.c = randn(M, 1);
end

%% Redirect the job to 'CheckGradient'.
if (nargout == 0)
  CheckGradient(@(x)Fcn(fcn, data.c, x), N, data);
else
  [success, data] = CheckGradient(@(x)Fcn(fcn, data.c, x), N, data);
end

end

function [F, dF] = Fcn(fcn, c, x)

% Linear combination of a vector function 'fcn' to a scalar one.
if (nargout==1)
  f = fcn(x);
  F = c' * f;
else
  [f, J] = fcn(x);
  F = c' * f;
  dF = J' * c;
end

end
