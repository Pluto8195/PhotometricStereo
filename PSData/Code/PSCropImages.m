function PSCropImages(topDir, rawInSuffix, rawOutSuffix)

% PSCropImages(topDir, rawInSuffix, rawOutSuffix)
%
% Crop the objects and light probes from the input image.
%
% The 'rawInSuffix' is the suffix for input RAW files (output by dcraw), and the
% 'rawOutSuffix' is the suffix for output (cropped) RAW files. The typical
% choice for 'rawInSuffix' is 'tiff' and for 'rawOutSuffix' is 'png'.
%
%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

% Set paths.
srcDir = fullfile(topDir, 'OriginalRenamed');
dataDir = fullfile(topDir, 'ManualData');

objDir = fullfile(topDir, 'Objects');
if (~exist(objDir, 'dir'))   mkdir(objDir);   end

probeDir = cell(2,1);
for i=1:2
  probeDir{i} = fullfile(topDir, ['LightProbe-' num2str(i)]);
  if (~exist(probeDir{i}, 'dir'))   mkdir(probeDir{i});   end
end

% Crop objects from RAW images.
imgFiles = dir(fullfile(srcDir, ['Image_*.' rawInSuffix]));
obj_bbox = textread(fullfile(dataDir, 'obj_bbox.txt'));
for iFile = 1:length(imgFiles)
  filename = imgFiles(iFile).name;
  I = imread(fullfile(srcDir, filename));
  I = I(end:-1:1, :, :);
  J = I(obj_bbox(3):obj_bbox(4), obj_bbox(1):obj_bbox(2), :);
  imwrite(J(end:-1:1, :, :), ...
          fullfile(objDir, strrep(filename, rawInSuffix, rawOutSuffix)));
end

% Crop light light probes from JPG images.
imgFiles = dir(fullfile(srcDir, '*.JPG'));
probes_bbox = textread(fullfile(dataDir, 'probes_bbox.txt'));
for iFile = 1:length(imgFiles)
  filename = imgFiles(iFile).name;
  I = imread(fullfile(srcDir, filename));
  I = I(end:-1:1, :, :);
  for i = 1:2
    J = I(probes_bbox(i,3):probes_bbox(i,4), ...
          probes_bbox(i,1):probes_bbox(i,2), :);
    imwrite(J(end:-1:1, :, :), fullfile(probeDir{i}, filename));
  end
end
