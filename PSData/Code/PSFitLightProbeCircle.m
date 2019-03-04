function PSFitLightProbeCircle(topDir)

% PSFitLightProbeCircle(topDir)
%
% Fit the circle of light probe from manual data.
%
%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

dataDir = fullfile(topDir, 'ManualData');
probeBBox = textread(fullfile(dataDir, 'probes_bbox.txt'));

figure;
for iProbe = 1:2
  probeDir = fullfile(topDir, ['LightProbe-' num2str(iProbe)]);
  % Load circle points and adjust according to bounding box.
  circlePts = textread(fullfile(dataDir, ['circle' num2str(iProbe) '_pts.txt']));
  circlePts(:,1) = circlePts(:,1) - probeBBox(iProbe, 1) + 1;
  circlePts(:,2) = circlePts(:,2) - probeBBox(iProbe, 3) + 1;
  % Load the image for visualization.
  Iref = imread(fullfile(probeDir, 'ref.JPG'));
  Iref = Iref(end:-1:1, :, :);
  subplot(1,2,iProbe); imshow(Iref); hold on; axis xy;
  % Fit the circle.
  [xc, yc, r] = FitCircle(circlePts(:,1)', circlePts(:,2)', ...
                          struct('Visualize', 'on'));
  % Write the result to a text file.
  dstFile = fullfile(probeDir, 'circle_data.txt');
  dlmwrite(dstFile, [xc; yc; r], 'precision', '%10.6f');
end
