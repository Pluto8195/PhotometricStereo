function Ierr = PSEvalNEstimateByIError(rho, n, I, mask, L, options)

% Ierr = PSEvalNEstimateByIError(rho, n, I, mask, L, options)
%
% Evaluate scaled normal estimation by intensity error.
%
% The input 'options' is a struct with following supported fields:
%   'Display': indicate whether to print error statistics or not, default {0}.
%
% The output 'Ierr' is a matrix of the image size (N1xN2), with each pixel being
% the root-mean-square of error across different images at the same pixel
% location. Pixels that are masked out are not considered, and places with no
% data will have an NaN output.
%
%
%   Author: Ying Xiong.
%   Created: Feb 08, 2014.

% Set default 'options'.
if (~exist('options', 'var'))   options = [];   end
if (~isfield(options, 'Display'))   options.Display = 0;   end

% Resize (vectorize) the input.
[N1, N2, M] = size(I);
N = N1*N2;

I = reshape(I, [N, M]);
mask = reshape(mask, [N, M]);

n = reshape(n, [N, 3]);
b = repmat(rho(:), [1, 3]) .* n;

% Compute error map.
Ierr = zeros(N, 1);
for i = 1:M
  Ierr_i = I(:,i) - b * L(:,i);
  Ierr_i(~mask(:,i)) = 0;
  Ierr = Ierr + Ierr_i.^2;
end
Ierr = sqrt(Ierr ./ sum(mask, 2));
Ierr = reshape(Ierr, [N1, N2]);

% Print error statistics.
if (options.Display)
  IerrValid = Ierr(isfinite(Ierr));
  fprintf('Evaluate scaled normal estimation by intensity error:\n');
  fprintf('  RMS = %.4f\n', sqrt(mean( IerrValid.^2 )));
  fprintf('  Mean = %.4f\n', mean(IerrValid));
  fprintf('  Median = %.4f\n', median(IerrValid));
  fprintf('  90 percentile = %.4f\n', prctile(IerrValid, 90));
  fprintf('  Max = %.4f\n', max(IerrValid));
end
