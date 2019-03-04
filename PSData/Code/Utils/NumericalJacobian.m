function [J, f0] = NumericalJacobian(fcn, x0, options)

% [J, f0] = NumericalJacobian(fcn, x0, options)
%
% Compute numerical Jacobian of function 'fcn' at point 'x0'. The function 'fcn'
% takes an Nx1 vector as input, and output an Mx1 vector. The input 'x0' should
% be an Nx1 vector, and the output 'J' is an MxN matrix, which is the Jacobian
% of function 'fcn'. The second output 'f0' is the function value at 'x0'.
%
% The input 'options' is a struct with following supported fields:
%   'dx': a scalar for small change in x0, can be either a scalar or an
%         Nx1 vector, default {1e-6}.
%   'method': a string of following options:
%       {'forward'}: compute the Jacobian as f(x0+dx)-f(x0).
%       'central': compute the Jacobian as f(x0+dx)-f(x0-dx).
%
%   Author: Ying Xiong.
%   Created: Feb 05, 2014.

%% Read or set default options.
if (~exist('options', 'var'))     options = [];             end

% Set 'dx'.
if (~isfield(options, 'dx'))      dx = 1e-6;
else                              dx = options.dx;          end
N = length(x0);
if (isscalar(dx))                 dx = ones(size(x0))*dx;   end

% Set method.
%   0: forward difference.
%   1: central difference.
if (~isfield(options, 'method'))               method = 0;
elseif (strcmp(options.method, 'forward'))     method = 0;
elseif (strcmp(options.method, 'central'))     method = 1;
else      error('Unknown option.method ''%s''.', options.method);   end

%% Do the job.
if (method == 0)
  % Forward difference.
  f0 = fcn(x0);
  M = length(f0);
  J = zeros(M, N);
  for j = 1:N
    xj = x0;
    xj(j) = x0(j) + dx(j);
    fj = fcn(xj);
    J(:,j) = (fj - f0) / dx(j);
  end
elseif (method == 1)
  % Central difference.
  for j = 1:N
    xj1 = x0;
    xj2 = x0;
    xj1(j) = x0(j) - dx(j);
    xj2(j) = x0(j) + dx(j);
    fj1 = fcn(xj1);
    fj2 = fcn(xj2);
    if (j==1)
      M = length(fj1);
      J = zeros(M, N);
    end
    J(:,j) = (fj2 - fj1) / 2 / dx(j);
  end
  if (nargout > 1)
    f0 = fcn(x0);
  end
else
  error('Internal error: unknown method.\n');
end
