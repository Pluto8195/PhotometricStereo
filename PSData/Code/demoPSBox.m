%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

rng(0);

%% Setup parameters.
% Change the 'topDir' to your local data directory.
topDir = fullfile(fileparts(mfilename('fullpath')), '../cat/');
% The format of output (decoded) RAW images.
dcrawSuffix = 'tiff';
croppedRawSuffix = 'png';
% The image channel used to perform photometric stereo.
imgChannel = 1;
% The intensity threshold for shadow, in [0, 1].
shadowThresh = 0.1;

%% Rename the input images.
% Copy the input images from 'Original' to 'OriginalRenamed', so that one can
% keep the 'Original' folder intact.
% Uncomment following block to rename input images.
%{
fprintf('Rename input images...\n');
originalFilePattern = 'IMG_%04d';
originalFileIndices = [7518:7521, 7523:7524, 7526:7531];
originalRefIndex = 7532;
PSRenameInputImages(topDir, originalFilePattern, originalFileIndices, ...
                    originalRefIndex);
%}

%% Derender the RAW images.
% Go to the 'OriginalRenamed' folder and run the following command
%   'dcraw -v -4 -h -o 0 -r 1 1 1 1 -T *.CR2'
% You can also change the output *.tiff files to other format you prefer, say
% *.png, and change the 'dcrawSuffix' accordingly.

%% Create bounding boxes.
% Create a 'ManualData' folder, and create following files
%   obj_bbox.txt: the bounding box for the object, 4x1 vector, referenced
%                 from the 'Image_NN.tiff' images. A bbox is specified as
%                     x_min x_max y_min y_max
%   probes_bbox.txt: the bounding box for two light probes, 4x2 matrix,
%                    referenced from the 'ref.JPG' image.
%   circle{1,2}_pts.txt: the points on the circle of each light probe, Nx2
%                        matrix, referenced from the 'ref.JPG' image
%                            x1  y1
%                            x2  y2
%                            ......
% Note that the y-direction of the coordinate system should be reverted when
% collecting these data. See README.txt for more information.

%% Crop the object and light probe.
% Uncomment following block to crop images.
%{
fprintf('Cropping images...\n');
PSCropImages(topDir, dcrawSuffix);
%}

%% Fit the light probe circle.
fprintf('Fitting light probe circles...\n');
PSFitLightProbeCircle(topDir);

%% Find the lighting directions.
fprintf('Finding light directions...\n');
PSFindLightDirection(topDir);

%% Load data and prepare to do photometric stereo.

fprintf('Loading data...\n');
% Load lighting directions.
L = textread(fullfile(topDir, 'light_directions.txt'));
% Load images.
loadOpts = struct('ImageChannel', imgChannel, ...
                  'NormalizePercentile', 99);
I = PSLoadProcessedImages(fullfile(topDir, 'Objects'), croppedRawSuffix, loadOpts);
nImgs = size(I, 3);
% Create a shadow mask.
shadow_mask = (I > shadowThresh);
se = strel('disk', 5);
for i = 1:nImgs
  % Erode the shadow map to handle de-mosaiking artifact near shadow boundary.
  shadow_mask(:,:,i) = imerode(shadow_mask(:,:,i), se);
end

%% Estimate the normal vectors.
% Without using light strength estimation.
fprintf(['Estimating normal vectors and albedo (without light strength ' ...
         'estimation) ...\n']);
[rho, n] = PhotometricStereo(I, shadow_mask, L);
% Evaluate normal estimate by intensity error.
evalOpts = struct('Display', 1);
Ierr = PSEvalNEstimateByIError(rho, n, I, shadow_mask, L, evalOpts);

%% Estimate lighting strength.
fprintf('Estimating lighting strength...\n');
lsOpts = struct('nSamples', 1000);
lambda = PSEstimateLightStrength(I, shadow_mask, L, lsOpts);
L2 = repmat(lambda', [3 1]) .* L;

[rho, n] = PhotometricStereo(I, shadow_mask, L2);
Ierr = PSEvalNEstimateByIError(rho, n, I, shadow_mask, L2, evalOpts);

%% Refine the lighting matrix.
fprintf('Refine lighting direction and strength...\n');
rlOpts = struct('nSamples', 1000);
L = PSRefineLight(L, I, shadow_mask, rlOpts);
dlmwrite(fullfile(topDir, 'refined_light.txt'), L, 'precision', '%20.16f');

[rho, n] = PhotometricStereo(I, shadow_mask, L);
Ierr = PSEvalNEstimateByIError(rho, n, I, shadow_mask, L, evalOpts);

%% Visualize the normal map.
figure; imshow(n); axis xy;

%% Estimate depth map from the normal vectors.
fprintf('Estimating depth map from normal vectors...\n');
p = -n(:,:,1) ./ n(:,:,3);
q = -n(:,:,2) ./ n(:,:,3);
p(isnan(p)) = 0;
q(isnan(q)) = 0;
Z = DepthFromGradient(p, q);
% Visualize depth map.
figure;
Z(isnan(n(:,:,1)) | isnan(n(:,:,2)) | isnan(n(:,:,3))) = NaN;
surf(Z, 'EdgeColor', 'None', 'FaceColor', [0.5 0.5 0.5]);
axis equal; camlight;
view(-75, 30);
