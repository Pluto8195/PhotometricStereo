function [f, J] = PSEstimateLightStrengthCost(lambda, L_hat, I)

% [f, J] = PSEstimateLightStrengthCost(lambda, L_hat, I)
%
% The cost function used for estimating light strength.
%
% INPUT:
%   lambda: Mx1 vector for lighting strength.
%   L_hat: 3xM matrix for unit lighting directions.
%   I: MxN matrix for intensity measurements.
%
% OUTPUT:
%   f: (M*N)x1 vector for intensity error.
%   J: (M*N)xM matrix for Jacobian of 'f' over 'lambda'.
%
%   Author: Ying Xiong.
%   Created: Feb 08, 2014.

[M, N] = size(I);

L = repmat(lambda', [3 1]) .* L_hat;

f = L'*(L'\I) - I;
f = f(:);

if (nargout > 1)
  J = zeros(M*N, M);
  LLinv = inv(L*L');
  for i = 1:M
    dL = zeros(3, M);
    dL(:,i) = L_hat(:,i);
    df = dL'*LLinv*L - L'*LLinv*(dL*L'+L*dL')*LLinv*L + L'*LLinv*dL;
    Ji = df * I;
    J(:,i) = Ji(:);
  end
end
