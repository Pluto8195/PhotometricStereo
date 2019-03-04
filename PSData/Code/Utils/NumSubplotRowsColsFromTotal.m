function [nRows, nCols] = NumSubplotRowsColsFromTotal(nTotal)

% [nRows, nCols] = NumSubplotRowsColsFromTotal(nTotal)
%
% Find the best number of rows and columns for a subplot, given total number of
% plots. The result will be such that
%     nRows <= nCols < nRows+1,
% which means either square or a slightly fat figure.
%
%   Author: Ying Xiong
%   Created: Oct 27, 2012

nCols = ceil(sqrt(nTotal));
nRows = ceil(nTotal / nCols);
