function PSRenameInputImages(topDir, filePatterns, fileIndices, refIndex)

% PSRenameInputImages(topDir, filePatterns, fileIndices, refIndex)
%
% Rename the input images in 'Original' folder to 'OriginalRenamed/Image_NN'.
%
%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

srcDir = fullfile(topDir, 'Original');
dstDir = fullfile(topDir, 'OriginalRenamed');
if (~exist(dstDir, 'dir'))   mkdir(dstDir);   end
suffixList = {'JPG', 'CR2'};

for iFile = 1:length(fileIndices)
  filename = sprintf(filePatterns, fileIndices(iFile));
  for iSuffix = 1:length(suffixList)
    suffix = suffixList{iSuffix};
    copyfile(fullfile(srcDir, [filename '.' suffix]), ...
             fullfile(dstDir, sprintf('Image_%02d.%s', iFile, suffix)));
  end
end

refFilename = sprintf(filePatterns, refIndex);
for iSuffix = 1:length(suffixList)
  suffix = suffixList{iSuffix};
  copyfile(fullfile(srcDir, [refFilename '.' suffix]), ...
           fullfile(dstDir, ['ref.' suffix]));
end
