function I = PSLoadProcessedImages(imgDir, imgSuffix, options)

% I = PSLoadProcessedImages(imgDir, imgSuffix, options)
%
% Load processed input images for photometric stereo.
%
% INPUT:
%   imgDir, imgSuffix: the directory of suffix of input image, with file names
%         "imgDir/Image_XX.imgSuffix"
%   options: a struct with following supported fields.
%     'ImageChannel': The image channel used, options {1}, 2, 3.
%     'NormalizePercentile': If provided, the images will be normalized
%         according to this percentile. This makes sense when the object is of
%         uniform albedo and has points facing at light. Suggested value is 99.
%
% OUTPUT:
%   I: an MxNxP array, with 'P' being number of images.
%
%   Author: Ying Xiong.
%   Created: Feb 07, 2014.

% Set default options.
if (~exist('options', 'var'))   options = [];   end
if (~isfield(options, 'ImageChannel'))   options.ImageChannel = 1;   end

% Get image names and dimension.
imgFiles = dir(fullfile(imgDir, ['Image_*.' imgSuffix]));
nImgs = length(imgFiles);
I = imread(fullfile(imgDir, imgFiles(1).name));
[M, N, C] = size(I);

% Load images.
I = zeros(M, N, nImgs);
for i = 1:nImgs
  Itmp = im2double(imread(fullfile(imgDir, imgFiles(i).name)));
  Itmp = Itmp(end:-1:1, :, options.ImageChannel);
  % Normalize over the a percentile.
  if (isfield(options, 'NormalizePercentile'))
    I(:,:,i) = Itmp / prctile(Itmp(:), options.NormalizePercentile);
  end
end
