function diag = compute_return_diagnostics(R, seriesNames, datesR)
%COMPUTE_RETURN_DIAGNOSTICS Compute return diagnostics and correlation matrices.
%
% This function computes:
%   - Basic moments (mean, standard deviation)
%   - Skewness and kurtosis (when enough data are available)
%   - ADF test (stationarity) and Jarque-Bera test (normality)
%   - Pairwise correlation matrix on the input return matrix
%   - Optional weekly and monthly correlation matrices (if datesR is provided)
%
% Inputs:
%   R            nObs-by-nSeries numeric matrix of returns (may contain NaNs/Infs).
%   seriesNames  Names/labels for each series (cell array of char/string or string array).
%   datesR       (Optional) nObs-by-1 datetime vector aligned with rows of R.
%               If empty or not provided, weekly/monthly correlations are skipped.
%
% Outputs:
%   diag         Struct with fields:
%                 - stats  : table with columns {Contract, Mean, Std, Skew, Kurtosis}
%                 - adf    : table with columns {Contract, h, pValue} from adftest
%                 - jb     : table with columns {Contract, h, pValue} from jbtest
%                 - C      : nSeries-by-nSeries pairwise correlation matrix on R
%                 - corr_w : weekly correlation matrix (empty if datesR not provided)
%                 - corr_m : monthly correlation matrix (empty if datesR not provided)

names = string(seriesNames);  % Ensure labels are a string array

% Basic moments (ignore NaNs)
meanR = mean(R, 1, 'omitnan');
stdR  = std(R, 0, 1, 'omitnan');

% Higher moments placeholders
nComp = size(R, 2);
skewR = NaN(1, nComp);
kurtR = NaN(1, nComp);

% Compute skewness/kurtosis per series (only if enough valid data)
for j = 1:nComp
    x = R(:, j);
    x = x(isfinite(x));
    if numel(x) > 30 && std(x) > 0
        skewR(j) = skewness(x);
        kurtR(j) = kurtosis(x);
    end
end

% Summary statistics table
stats = table(names(:), meanR(:), stdR(:), skewR(:), kurtR(:), ...
    'VariableNames', {'Contract','Mean','Std','Skew','Kurtosis'});

% Test results placeholders
h_adf = NaN(nComp, 1); p_adf = NaN(nComp, 1);
h_jb  = NaN(nComp, 1); p_jb  = NaN(nComp, 1);

% ADF and JB tests per series (only if enough valid data)
for j = 1:nComp
    x = R(:, j);
    x = x(isfinite(x));
    if numel(x) > 30 && std(x) > 0
        [h_adf(j), p_adf(j)] = adftest(x);
        [h_jb(j),  p_jb(j)]  = jbtest(x);
    end
end

% Test tables
adf = table(names(:), h_adf, p_adf, 'VariableNames', {'Contract','h','pValue'});
jb  = table(names(:), h_jb,  p_jb,  'VariableNames', {'Contract','h','pValue'});

% Pairwise correlations on the raw return matrix
C = corr(R, 'Rows', 'pairwise');

% Pack outputs
diag = struct();
diag.stats  = stats;
diag.adf    = adf;
diag.jb     = jb;
diag.C      = C;
diag.corr_w = [];
diag.corr_m = [];

% Optional: weekly/monthly correlations (requires valid datesR)
if nargin >= 3 && ~isempty(datesR)
    TT  = array2timetable(R, 'RowTimes', datesR, 'VariableNames', cellstr(names));
    R_w = retime(TT, 'weekly',  'mean');
    R_m = retime(TT, 'monthly', 'mean');

    diag.corr_w = corr(R_w.Variables, 'Rows', 'pairwise');
    diag.corr_m = corr(R_m.Variables, 'Rows', 'pairwise');
end
end
