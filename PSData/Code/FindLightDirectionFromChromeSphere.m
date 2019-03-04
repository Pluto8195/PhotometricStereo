function l = FindLightDirectionFromChromeSphere(I, circle, threshold, options)

% l = FindLightDirectionFromChromeSphere(I, circle, threshold)
%
% Find the light source direction from the given image of a light sphere, using
% the specular highlights. The code assumes an orthographic camera model. The
% coordinate system origins at the object sphere, with camera direction (0,0,1).
% In the camera point of view, it is looking at the sphere in (0,0,-1) direction.
% The x direction increases the column index of 'I', and y direciton increases
% the row index.
%
% INPUT:
%   I: the image of a specular chrome sphere.
%   circle: a 3x1 vector [xc; yc; r] describing the position of chrome sphere.
%   threshold: the threshold for specular highlights, e.g. 250 for a 8-bit
%              image. This is an inclusive threshold, meaning that any intensity
%              >= 'threshold' will be considered as outlier.
%   options: a struct with following supported fields:
%     'Visualize': whether to do visualization or not, options {'off'} or 'on'.
%                  If set 'on', the visualization will be on 'gca'.
%
% OUTPUT:
%   l: the estimated light source direction, 3x1 unit vector.
%
%   Author: Ying Xiong.
%   Created: Jan 24, 2014.

if (~exist('options', 'var'))   options = [];   end

% Convert to gray scale image.
if (size(I, 3) == 3)
  I = rgb2gray(I);
end

% Get the circle info.
xc = circle(1);
yc = circle(2);
r = circle(3);

% Find the specular highlight center.
[hy, hx] = ind2sub(size(I), find(I>=threshold));
hxc = median(hx);
hyc = median(hy);

% The normal vector of highlight on the sphere.
n = [hxc - xc; hyc - yc] / r;
n(3) = sqrt(1 - n(1)^2 - n(2)^2);

% Find the light source direction, which has the same angle with normal and
% with viewing direction (0,0,1).
l = 2*n(3)*n - [0; 0; 1];

if (isfield(options, 'Visualize') && strcmp(options.Visualize, 'on'))
  imshow(I); axis xy; hold on;
  t = 0:0.01:2*pi;
  plot(xc + r*cos(t), yc + r*sin(t));
  plot(hxc, hyc, 'r*');
end
