function [x, F, f, exitflag] = NonlinearLeastSquares(fcn, x0, lb, ub, options)

% x = NonlinearLeastSquares(fcn, x0)
% x = NonlinearLeastSquares(fcn, x0, lb, ub)
% x = NonlinearLeastSquares(fcn, x0, lb, ub, options)
% [x, F, f] = NonlinearLeastSquares(...)
% [x, F, f, exitflag] = NonlinearLeastSquares(...)
%
% Perform nonlinear least squares optimization to minimize the cost function
%   F(x) = sum(fcn(x).^2).
%
% INPUT:
%   fcn: a vector fection to be minimized, with the form
%            [f, J] = fcn(x)
%        with 'x' an input Nx1 vector, 'f' an Mx1 vector for function values and
%        'J' a MxN matrix for the Jacobian matrix.
%        One does not have to compute the Jacobian of the function, by simply
%        providing
%            f = fcn(x)
%        and set 'options.Jacobian=off'.
%   x0:  initial guess, Nx1 vector.
%   lb, ub: the lower and upper bound of the variable 'x'. Can be [] or 'Inf'
%           if not bound needs to be enforced.
%   options: a struct with following supported fields.
%     'DerivativeCheck': compare the user-supplied derivatives with to
%                finite-differencing ones, options {'off'} or 'on'. The gradient
%                will only be checked at 'x0' and therefore not impose a big
%                performance penality.
%     'Display': Level of display, options {'off'/'none'}, 'final',
%                'final-detailed', 'iter', 'iter-detailed'.
%                NOTE: the default is different from 'lsqnonlin'.
%                [TODO] The 'final-detailed' option is not properly supported yet.
%     'Jacobian':Whether to use the Jacobian given by 'fcn' or perform finite
%                difference. Options are {'on'} (use 'fcn') or 'off' (use finite
%                difference).
%                NOTE: the default is different from 'lsqnonlin'.
%     'MaxIter': Maximum number of iterations allowed, default {400}.
%     'TolFun':  Termination tolerance on 'f', default {1e-6}.
%     'TolX':    Termination tolerance on 'x', default {1e-6}.
%     ---- NOTE: The following options are not in 'lsqnonlin'. ----
%     ---- For Levenberg-Marquardt algorithm only. ----
%     'LMtau': the 'tau' parameter, default {1e-3}.
%     'LMDampMatx': the damping matrix, options {'eye'} or 'JJ'. Use the latter
%                   if the problem is poorly scaled.
%
% OUTPUT:
%   x: the output local minimum.
%   F: the cost at 'x', i.e. sum(fcn(x).^2).
%   f: the vector function value at 'x', i.e. fcn(x).
%   exitflag: an integer describing the exit condition, with following values
%     0: number of iterations exceeded 'options.MaxIter'.
%     1: function converges to a solution 'x'.
%     2: change in 'x' less than 'TolX'.
%     3: change in 'f' less than 'TolFun'.
%     4: mangitude of search direction smaller than 'eps'.
%
%   Author: Ying Xiong.
%   Created: Jan 20, 2014.

%% Check input and setup parameters.
if (~exist('lb', 'var'))        lb = [];        end
if (~exist('ub', 'var'))        ub = [];        end
if (~exist('options', 'var'))   options = [];   end
% Get options from the struct.
[DerivativeCheck, Display, MaxIter, Jacobian, TolFun, TolX] = GetOptions(options);
[tau, JJDamp] = GetLMOptions(options);

%% Remove the bounded constraint.
N = length(x0);
if ((~isempty(lb) && any(isfinite(lb))) || ...
    (~isempty(ub) && any(isfinite(ub))))
  BoundedConstraint = 1;
  if (isempty(lb))    lb = -Inf(N,1);   end
  if (isempty(ub))    ub =  Inf(N,1);   end
  lb = lb(:);
  ub = ub(:);
  assert(all(lb<=x0) && all(x0<=ub));
  fcn = BoundedFcnToUnconstrainedFcn(fcn, lb, ub);
  mapfcn = MapBoundedToUnconstrained(lb, ub);
  x0 = mapfcn(x0);
else
  BoundedConstraint = 0;
end

%% Initialization.
x = x0;
[f, J] = EvalFcnAndGetJacobian(fcn, x, Jacobian);
F = sum(f.^2);
JJ = J' * J;
Jf = J' * f;
mu = tau * max(diag(JJ));
if (mu == 0)
  % J is an zero matrix.
  fprintf('Terminate: local minimum reached.\n');
  exit = 1;
  return;
end
mu_min = 1e-12;
nu = 2;

% The followings might be needed for the first iteration's stop criternion, in
% case one starts at a local minimum.
x_old = x;
f_old = f;

if (DerivativeCheck)
  CheckJacobian(fcn, N, length(f), struct('x0', x0));
end

if (Display >= 3)
  fprintf('  Iter       F(x)\n');
  fprintf('%6d    %.4e\n', 0, F);
end

%% Main loop.
for iter = 1:MaxIter
  % Compute direction 'h'.
  if (JJDamp)    h = -(JJ + mu*diag(diag(JJ))) \ Jf;
  else           h = -(JJ + mu*eye(N)) \ Jf;        end
  % Compute gain ratio 'rho'.
  x_new = x + h;
  [f_new, J_new] = EvalFcnAndGetJacobian(fcn, x_new, Jacobian);
  F_new = sum(f_new.^2);
  if (JJDamp)    rho_denom = h' * (mu*diag(diag(JJ))*h - Jf);
  else           rho_denom = h' * (mu*h - Jf);                   end
  rho = (F - F_new) / rho_denom;
  % Update the variable if step is accepted.
  if (rho > 0)
    % Step accepted.
    x_old = x;   x = x_new;
    f_old = f;   f = f_new;
    F = F_new;
    J = J_new;
    JJ = J' * J;
    Jf = J' * f;
    mu = max(mu_min, mu * max(1/3, 1-(2*rho-1)^3));
    nu = 2;
  else
    % Step not accepted.
    mu = mu*nu;
    nu = 2*nu;
  end
  % Display information.
  if (Display >= 3)
    fprintf('%6d    %.4e\n', iter, F);
    if (Display >= 4)
      fprintf('rho=%.3f, mu=%8.4e, nu=%d\n', rho, mu, nu);
    end
  end
  % Check the stop criterion.
  exitflag = StopCriterion(rho_denom, rho, x_old, x, TolX, f_old, f, TolFun);
  if (exitflag)    break;    end
end

if (BoundedConstraint)
  mapfcn = MapUnconstrainedToBounded(lb, ub);
  x = mapfcn(x);
end

if (Display >= 1)
  fprintf('Terminate: ');
  if (exitflag == 0)
    fprintf('maximum number of iterations (%d) reached.\n', MaxIter);
  elseif (exitflag == 1)
    fprintf('local minimum reached.\n');
  elseif (exitflag == 2)
    fprintf('change in ''x'' less than ''TolX'' (%g).\n', TolX);
  elseif (exitflag == 3)
    fprintf('change in ''f'' less than ''TolFun'' (%g).\n', TolFun);
  elseif (exitflag == 4);
    fprintf('magnitude of search direction less than ''eps''.\n');
  else
    error('Unknown ''exitflag'' %d.', exitflag);
  end
end

end

function s = StopCriterion(rho_denom, rho, x_old, x, TolX, f_old, f, TolFun)

if (rho_denom < eps)
  % When this happens, the step size is usually very small and the calculation of
  % 'rho' is below numerical accuracy. We claim to find a local minimum.
  s = 1;
  return;
end

if (rho > 0)
  % If a step has been made.
  if (norm(x-x_old) < TolX)                   s = 2;
  elseif (norm(f-f_old) < TolFun)             s = 3;
  else                                        s = 0;
  end
else
  s = 0;
end

end

function [DerivativeCheck, Display, MaxIter, Jacobian, TolFun, TolX] = ...
      GetOptions(options)

if (~isfield(options, 'DerivativeCheck'))     DerivativeCheck = 0;
else
  if (strcmp(options.DerivativeCheck, 'off')) DerivativeCheck = 0;
  elseif (strcmp(options.DerivativeCheck, 'on'))   DerivativeCheck = 1;
  end
end

if (~isfield(options, 'Display'))             Display = 0;
elseif (strcmp(options.Display, 'none'))      Display = 0;
elseif (strcmp(options.Display, 'off'))       Display = 0;
elseif (strcmp(options.Display, 'final'))     Display = 1;
elseif (strcmp(options.Display, 'final-detailed'))   Display = 2;
elseif (strcmp(options.Display, 'iter'))      Display = 3;
elseif (strcmp(options.Display, 'iter-detailed'))    Display = 4;
else   error('Unknown options.Display ''%s''.', options.Display);
end

if (~isfield(options, 'MaxIter'))             MaxIter = 400;
else   MaxIter = options.MaxIter;   end

if (~isfield(options, 'Jacobian'))            Jacobian = 1;
elseif (strcmp(options.Jacobian, 'on'))       Jacobian = 1;
elseif (strcmp(options.Jacobian, 'off'))      Jacobian = 0;
end

if (~isfield(options, 'TolFun'))              TolFun = 1e-6;
else   TolFun = options.TolFun;     end

if (~isfield(options, 'TolX'))                TolX = 1e-6;
else   TolX = options.TolX;         end

end

function [tau, JJDamp] = GetLMOptions(options)

% Get Levenberg-Marquardt specific options.
if (~isfield(options, 'LMtau'))               tau = 1e-3;
else   tau = options.tau;   end

if (~isfield(options, 'LMDampMatx'))          JJDamp = 0;
elseif (strcmp(options.LMDampMatx, 'eye'))    JJDamp = 0;
elseif (strcmp(options.LMDampMatx, 'JJ'))     JJDamp = 1;
else   error('Unknown ''options.LMDampMatx''.');
end

end

function [f, J] = EvalFcnAndGetJacobian(fcn, x, Jacobian)

if (Jacobian)
  [f, J] = fcn(x);
else
  [J, f] = NumericalJacobian(fcn, x);
end
end
