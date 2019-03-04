function [f, J] = PSRefineLightCost(L, I)

% [f, J] = PSRefineLightCost(L, I)
%
% The cost function used for refining lighting direction and strength.
%
% INPUT:
%   L: (3*M)x1 vector for lighting direction, which can be 'reshape'-ed to
%      the 3xM lighting matrix.
%   I: MxN matrix for intensity measurements.
%
% OUTPUT:
%   f: (M*N)x1 vector for intensity error.
%   J: (M*N)x(3*M) matrix for Jacobian of 'f' over 'L'.
%
%   Author: Ying Xiong.
%   Created: Feb 13, 2014.

[M, N] = size(I);

L = reshape(L, [3 M]);

f = L'*(L'\I) - I;
f = f(:);

if (nargout > 1)
  J = zeros(M*N, 3*M);
  LLinv = inv(L*L');
  for i = 1:M
    for k = 1:3
      dL = zeros(3, M);
      dL(k,i) = 1;
      df = dL'*LLinv*L - L'*LLinv*(dL*L'+L*dL')*LLinv*L + L'*LLinv*dL;
      Ji = df * I;
      J(:,(i-1)*3+k) = Ji(:);
    end
  end
end
