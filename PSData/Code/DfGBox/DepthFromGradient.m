function Z = DepthFromGradient(p, q, options)

% Z = DepthFromGradient(p, q, options)
%
% Estimate a depth map 'Z' from the given gradient field ('p', 'q'), such that
%     dZ/dx = p,    dZ/dy = q.
%
% The input 'options' is a struct with following supported fields:
%   'periodic': a boolean indicating whether the output 'Z' should be
%               periodic or not, options {0} or 1.
%
%   Author: Ying Xiong.
%   Created: Jan 27, 2014.

% Parse options.
if (~exist('options', 'var'))   options = [];   end

if (isfield(options, 'periodic'))   periodic = options.periodic;
else                                periodic = 0;                   end

% Check input size.
assert(ismatrix(p) && all(size(p) == size(q)));
[M, N] = size(p);

% Perform copy-flip for non-periodic depth.
if (~periodic)
  p = [p, -p(:,end:-1:1); p(end:-1:1, :), -p(end:-1:1, end:-1:1)];
  q = [q, q(:,end:-1:1); -q(end:-1:1, :), -q(end:-1:1, end:-1:1)];
  M = M*2;
  N = N*2;
end

% Frequency indices.
halfM = (M-1)/2;
halfN = (N-1)/2;
[u, v] = meshgrid(-ceil(halfN):floor(halfN), -ceil(halfM):floor(halfM));
u = ifftshift(u);
v = ifftshift(v);

% Compute the Fourier transform of 'p' and 'q'.
Fp = fft2(p);
Fq = fft2(q);

% Compute the Fourier transform of 'Z'.
Fz = -1j/(2*pi) * (u.*Fp./N + v.*Fq./M) ./ ((u./N).^2 + (v./M).^2);

% Set DC component.
Fz(1) = 0;

% Recover depth 'Z'.
Z = real(ifft2(Fz));

% Recover the non-periodic depth.
if (~periodic)   Z = Z(1:M/2, 1:N/2);   end
