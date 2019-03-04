function ShowProgress(i, nAll, nIntvl, msg, mode)

% USAGE:
%   showProgress(i, nAll[, nIntvl, msg, mode])
%
% DESCRIPTION:
%   Show the progress in a loop.
%
% INPUT:
%   i: number of iteration in the loop.
%   nAll: number of total iterations in the loop.
%   nIntvl: interval of iteration reported, default {1}, or percentage
%           report interval if the mode is set that way, in which case
%           default on {1/nAll}.
%   msg: message to be shown, default {''}.
%   mode: an integer indicating the mode on which this function is run, options:
%         0: regular mode (default), a newline will be added after each
%            call of this function.
%         1: space-efficiency mode 1, all the output will be shown in the
%            same line. A newline is added at the last call of this function
%            (when i==nAll).
%         2: space-efficiency mode 2, all the output will be shown in the
%            same line. No newline is added, even after the loop exits.
%         10, 11, 12: same as 0, 1 and 2, except that we print the percentage here.
%
%   Author: Ying Xiong.
%   Created: Nov 17, 2011.
%   Updated: Feb 4, 2013.

EPS = 1e-8;

% Setup default parameters.
if (~exist('mode', 'var') || isempty(mode))
  mode = 0;
end
if (~exist('nIntvl','var') || isempty(nIntvl))
  if (mode < 10)
    nIntvl = 1;
  else
    nIntvl = 1/nAll;
  end
end
if (~exist('msg', 'var') || isempty(msg))
  msg = '';
end

% Only fire when it is on report nIntvl, skip other iterations.
if (mode < 10)
  if (~((nIntvl==1) || (mod(i, nIntvl)==1)))
    return
  end
else
  nPrint = floor(i/nAll / nIntvl + EPS);
  if ((i-1)/nAll/nIntvl+EPS >= nPrint)
    return
  end
end

% Get the printing string.
if (mode < 10)
  if (isempty(msg))
    print_msg = sprintf('Processing %d out of %d...', i, nAll);
  else
    print_msg = sprintf('%s: Processing %d out of %d...', msg, i, nAll);
  end
elseif (mode < 20)
  if (isempty(msg))
    print_msg = sprintf('Processing %.0f %% of %d...', i/nAll*100, nAll);
  else
    print_msg = sprintf('%s: Processing %.0f %% of %d...', msg, i/nAll*100, nAll);
  end
else
  error('Unknown mode!');
end
msg_len = length(print_msg);

% Do the printing.
if (mod(mode, 10) == 0)
  fprintf('%s\n', print_msg);
elseif (mod(mode, 10) == 1)
  fprintf(repmat(sprintf('\b'), [1, msg_len]));
  fprintf('%s', print_msg);
  if (i == floor((nAll-1)/nIntvl)*nIntvl + 1)
    fprintf('\n');
  end
elseif (mod(mode, 10) == 2)
  fprintf(repmat(sprintf('\b'), [1, msg_len]));
  fprintf('%s', print_msg);
else
  error('Unknown mode!');
end
