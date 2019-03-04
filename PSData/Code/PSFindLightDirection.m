function PSFindLightDirection(topDir)

% PSFindLightDirection(topDir)
%
% Find light source directions from the light probe images.
%
%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

nProbes = 2;

%% Analyze light probe images.
for iProbe = 1:nProbes
  % Find all light probe images.
  probeDir = fullfile(topDir, ['LightProbe-' num2str(iProbe)]);
  imgFiles = dir(fullfile(probeDir, 'Image_*.JPG'));
  % Load circle data.
  circle = textread(fullfile(probeDir, 'circle_data.txt'));
  threshold = 250;
  % Process each image.
  nImgs = length(imgFiles);
  L = zeros(3, nImgs);
  figure;
  [nRows, nCols] = NumSubplotRowsColsFromTotal(nImgs);
  for iImg = 1:nImgs
    I = imread(fullfile(probeDir, imgFiles(iImg).name));
    I = I(end:-1:1, :, :);
    opts = struct('Visualize', 'on');
    subplot(nRows, nCols, iImg);
    L(:,iImg) = FindLightDirectionFromChromeSphere(I, circle, threshold, opts);
  end
  drawnow;
  % Write result to output.
  dlmwrite(fullfile(probeDir, 'light_directions.txt'), L, ...
           'delimiter', ' ', 'precision', '%20.16f');
end

%% Take average of direction by each probe.
L = zeros(3, nImgs);
for iProbe = 1:nProbes
  probeDir = fullfile(topDir, ['LightProbe-' num2str(iProbe)]);
  Li = textread(fullfile(probeDir, 'light_directions.txt'));
  L = L + Li;
end
L = normc(L);
dlmwrite(fullfile(topDir, 'light_directions.txt'), L, ...
         'delimiter', ' ', 'precision', '%20.16f');
