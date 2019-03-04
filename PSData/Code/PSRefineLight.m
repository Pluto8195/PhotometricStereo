function L = PSRefineLight(L0, I, mask, options)

% L = PSRefineLight(L0, I, mask, options)
%
% Refine the initial lighting calibration.
%
% The input 'options' is a struct with following supported field:
%   'nSamples': number of samples taken from input 'I' used in the optimization,
%               default {1000}.
%
%   Author: Ying Xiong.
%   Created: Feb 13, 2014.

if (~exist('options', 'var'))   options = [];   end
if (~isfield(options, 'nSamples'))   options.nSamples = 1000;   end

% Resize input.
[N1, N2, M] = size(I);
N = N1*N2;
I = reshape(I, [N, M]);

% Sample pixels that are valid in all images.
validIdx = find(all(mask, 3));
sampleIdx = validIdx(randi(length(validIdx), [options.nSamples 1]));
sampleIdx = unique(sampleIdx);

% Create MxN' intensity measurements for optimization.
I = I(sampleIdx, :)';

% Run optimization.
fcn = @(L)PSRefineLightCost(L, I);
optimOpts = struct('Jacobian', 'on');
L = NonlinearLeastSquares(fcn, L0(:), [], [], optimOpts);
L = reshape(L, size(L0));
