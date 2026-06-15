function miss = analyze_missing_data(F, seriesNames, doPlot)
%ANALYZE_MISSING_DATA Count missing values (NaNs) per series and optionally plot a NaN map.
%
% Inputs:
%   F            nRows-by-nSeries numeric matrix containing the time series (may include NaNs).
%   seriesNames  Names/labels for each series (cell array of char/string, or string array).
%   doPlot       (Optional) Logical flag. If true, plots a NaN map. Default: false.
%
% Outputs:
%   miss         Struct with fields:
%                  - nanCount : 1-by-nSeries number of NaNs in each column of F
%                  - nanRatio : 1-by-nSeries fraction of NaNs in each column of F

if nargin < 3
    doPlot = false;  % Default: do not plot
end

nCols = size(F, 2);                 % Number of series (columns)
nanCount = zeros(1, nCols);         % Preallocate NaN counts

fprintf('=== Missing Data Analysis ===\n');
for j = 1:nCols
    nanCount(j) = sum(isnan(F(:, j)));  % Count NaNs in series j

    % Print per-series NaN count (supports seriesNames as cell or string array)
    if iscell(seriesNames)
        label = string(seriesNames{j});
    else
        label = string(seriesNames(j));
    end
    fprintf('%-15s | NaN: %4d |\n', label, nanCount(j));
end

% Pack outputs in a struct
miss = struct();
miss.nanCount = nanCount;
miss.nanRatio = nanCount ./ size(F, 1);

% Optional visualization of missingness pattern
if doPlot
    figure;
    spy(isnan(F));                  % Visualize NaN locations
    xlabel('Series');
    ylabel('Time');
    title('NaN map');
    pbaspect([1 1 1]);
end
end
