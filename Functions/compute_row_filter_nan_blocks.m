function toRemove = compute_row_filter_nan_blocks(X)
%COMPUTE_ROW_FILTER_NAN_BLOCKS Build a row filter based on NaN counts in column blocks.
%
% This function flags rows to be removed according to a block-wise missingness rule.
% The rule replicates the original logic based on fixed column blocks (up to 21 columns):
%   - Block 1: columns  1:5   -> remove if NaNs > 2
%   - Block 2: columns  6:9   -> remove if NaNs > 2
%   - Block 3: columns 10:11  -> remove if NaNs > 1
%   - Block 4: columns 12:15  -> remove if NaNs > 2
%   - Block 5: columns 16:19  -> remove if NaNs > 2
%   - Block 6: columns 20:21  -> remove if NaNs > 1
%
% If X has fewer columns than expected, the function safely clips each block
% to the available range without throwing an indexing error.
%
% Inputs:
%   X         nRows-by-nCols numeric matrix of original series (may contain NaNs).
%
% Outputs:
%   toRemove  nRows-by-1 logical vector. True indicates the row should be removed.

% Number of available columns
n = size(X, 2);

% Helper to safely slice column ranges within [1, n]
getRange = @(a,b) X(:, max(1, a) : min(n, b));

% Block-wise missingness conditions
cond1 = sum(isnan(getRange( 1,  5)), 2) > 2;
cond2 = sum(isnan(getRange( 6,  9)), 2) > 2;
cond3 = sum(isnan(getRange(10, 11)), 2) > 1;
cond4 = sum(isnan(getRange(12, 15)), 2) > 2;
cond5 = sum(isnan(getRange(16, 19)), 2) > 2;
cond6 = sum(isnan(getRange(20, 21)), 2) > 1;

% Final row-removal mask
toRemove = cond1 | cond2 | cond3 | cond4 | cond5 | cond6;
end
