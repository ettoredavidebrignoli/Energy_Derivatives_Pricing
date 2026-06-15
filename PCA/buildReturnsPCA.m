function Ret = buildReturnsPCA(X, toRemove, T)
%BUILDRETURNSPCA Compute log-returns and filter them for PCA consistency.
%
% This function:
%   1) Computes log-returns from price levels.
%   2) Keeps only returns where both adjacent price rows are valid.
%   3) Keeps only returns whose endpoints lie within the same calendar month
%      (i.e., removes returns spanning month boundaries).
%
% Inputs:
%   X         matrix of monthly price levels.
%   toRemove  nRows-by-1 logical vector; true indicates an invalid price row.
%   T         table containing all dataset fields (dates, instrument
%             metadata, prices, etc.).
%
% Outputs:
%   Ret       nRet-by-nAssets matrix of filtered log-returns.

% Compute log-returns
Ret = diff(log(X));

% A return is valid only if both adjacent price rows are valid
keepRet = ~toRemove(1:end-1) & ~toRemove(2:end);
Ret = Ret(keepRet, :);

% Use dates aligned with X to remove returns that cross month boundaries
dates = T.date;  % datetime vector, same length as X (nRows)

sameMonth = (year(dates(2:end))  == year(dates(1:end-1))) & ...
            (month(dates(2:end)) == month(dates(1:end-1)));

% Keep only intra-month returns
Ret = Ret(sameMonth(1:size(Ret,1)), :);
end