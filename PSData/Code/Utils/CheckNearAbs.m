function success = CheckNearAbs(v1, v2, tol)

% CheckNearAbs(v1, v2, tol)
% success = CheckNearAbs(v1, v2, tol)
%
% Check whether matrix 'v1' and 'v2' are close to each other under tolerance
% 'tol' in the absolute sense:
%   ||v1 - v2|| <= tol,
% where ||.|| is the Frobenius norm.
%
% Return true if the check succeeded. If no output is assumed, the function will
% produce an error message.
%
%   Author: Ying Xiong.
%   Created: Jul 04, 2013.

err = norm(v1-v2, 'fro');
success = (err <= tol);
if (nargout==0 && ~success)
  fprintf('v1 = \n');
  disp(v1);
  fprintf('v2 = \n');
  disp(v2);
  fprintf('v1 - v2 = \n');
  disp(v1 - v2);
  fprintf('||v1 - v2|| = %f\n', err);
  fprintf('Tolerance = %f\n', tol);
  error('CheckNear failed.');
end
