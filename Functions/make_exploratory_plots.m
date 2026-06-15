function FIG = make_exploratory_plots(DATA, DIAG_contracts, CURVES, opts)
%MAKE_EXPLORATORY_PLOTS Generate exploratory figures for contracts and monthly forward curves.
%
% This function centralizes the plotting logic used across Exercises 1-2:
%   1) Raw DE/FR contract price series (10 + 10) with color gradients
%   2) Normality examples (histogram + fitted normal) for selected contract returns
%   3) ACF grids for contract returns (split into first 10 and remaining 10)
%   4) Samuelson-style volatility barplot and correlation heatmap for contract returns
%   5) Same diagnostics for reconstructed monthly forward returns (DE and FR)
%   6) Snapshots of monthly forward curves for selected observation dates
%
% Inputs:
%   DATA            Struct containing at least:
%                     - dates        : nObs-by-1 datetime vector
%                     - F            : nObs-by-20 numeric matrix of contract prices
%                     - legendLabels : 1-by-20 labels for plotting
%                     - seriesNames  : 1-by-20 names (cell or string)
%   DIAG_contracts  Struct containing at least:
%                     - R    : nRet-by-20 return matrix (contract returns)
%                     - stats: table with field/variable Std for volatility plotting
%                     - C    : 20-by-20 correlation matrix
%   CURVES          Struct containing at least:
%                     - X_DE : nObs-by-nMonths monthly forward curve matrix (Germany)
%                     - X_FR : nObs-by-nMonths monthly forward curve matrix (France)
%   opts            Struct with optional fields:
%                     - maxLag  : maximum lag used for ACF plots (default: 20)
%                     - nMonths : number of months used for curve objects (default: 24)
%                     - doPlots : not used inside this function (plots are always created here)
%
% Outputs:
%   FIG             Struct of figure handles, one field per produced figure.

if ~isfield(opts, "maxLag"),  opts.maxLag  = 20; end
if ~isfield(opts, "nMonths"), opts.nMonths = 24; end

FIG = struct();

dates         = DATA.dates;
F             = DATA.F;
legend_labels = DATA.legendLabels;
contractNames = string(DATA.seriesNames);

X_DE = CURVES.X_DE;
X_FR = CURVES.X_FR;

% -------------------------
% 1) Separate DE/FR price series (color gradients)
% -------------------------
colors_de = [linspace(0.5, 1, 10)', linspace(0, 0.4, 10)', linspace(0, 0.4, 10)'];
colors_fr = [linspace(0, 0.3, 10)', linspace(0, 0.3, 10)', linspace(0.5, 1, 10)'];

FIG.de_prices = figure('WindowStyle','normal'); hold on; grid on;
for i = 1:10
    plot(dates, F(:,i), 'Color', colors_de(i,:), 'LineWidth', 1.5);
end
title('German Power Prices (DE) - Red Gradient');
xlabel('Date'); ylabel('Price (€/MWh)');
legend(legend_labels(1:10), 'Location', 'bestoutside', 'NumColumns', 1);

FIG.fr_prices = figure('WindowStyle','normal'); hold on; grid on;
for i = 1:10
    plot(dates, F(:,10+i), 'Color', colors_fr(i,:), 'LineWidth', 1.5);
end
title('French Power Prices (FR) - Blue Gradient');
xlabel('Date'); ylabel('Price (€/MWh)');
legend(legend_labels(11:20), 'Location', 'bestoutside', 'NumColumns', 1);

% -------------------------
% 2) Normality examples (contracts)
% -------------------------
R_contracts = DIAG_contracts.R;

% Indices used in the original script; clip to available columns
idx = [3, 5, 9, 13, 15, 19];
idx = idx(idx <= size(R_contracts, 2));

FIG.norm_contracts = local_plot_normality_examples( ...
    R_contracts, contractNames, idx, 'Normality examples - Contract returns');

% -------------------------
% 3) ACF (contracts), split 10 + 10
% -------------------------
FIG.acf_contracts_1 = local_plot_acf_grid( ...
    R_contracts, contractNames, opts.maxLag, 1, min(10, size(R_contracts,2)), ...
    'Autocorrelation of Returns - First 10 Contracts');

if size(R_contracts,2) > 10
    FIG.acf_contracts_2 = local_plot_acf_grid( ...
        R_contracts, contractNames, opts.maxLag, 11, min(20, size(R_contracts,2)), ...
        'Autocorrelation of Returns - Remaining 10 Contracts');
end

% -------------------------
% 4) Samuelson-style volatility + correlation heatmap (contracts)
% -------------------------
FIG.samuelson_contracts = figure;
bar(DIAG_contracts.stats.Std);
set(gca, 'XTickLabel', contractNames, 'XTickLabelRotation', 45);
ylabel('Volatility');
title('Samuelson effect: Vol goes down with delivery');
grid on;

FIG.corr_contracts = figure;
imagesc(DIAG_contracts.C); colorbar;
xticks(1:length(contractNames)); yticks(1:length(contractNames));
xticklabels(contractNames); yticklabels(contractNames);
xtickangle(45);
title('Correlation surface between contract log-returns');

% -------------------------
% 5) Monthly forward returns DE/FR (normality + ACF + vol + corr)
% -------------------------
R_X_DE = diff(log(X_DE)); R_X_DE(~isfinite(R_X_DE)) = NaN;
R_X_FR = diff(log(X_FR)); R_X_FR(~isfinite(R_X_FR)) = NaN;

names_DE = "DE_M" + string(1:size(R_X_DE,2));
names_FR = "FR_M" + string(1:size(R_X_FR,2));

% Choose up to 6 evenly spaced maturities for normality examples
idx_DE = unique(round(linspace(1, size(R_X_DE,2), min(6, size(R_X_DE,2)))));
idx_FR = unique(round(linspace(1, size(R_X_FR,2), min(6, size(R_X_FR,2)))));

FIG.norm_X_DE = local_plot_normality_examples( ...
    R_X_DE, names_DE, idx_DE, 'Normality examples - Monthly forward returns (Germany)');

FIG.norm_X_FR = local_plot_normality_examples( ...
    R_X_FR, names_FR, idx_FR, 'Normality examples - Monthly forward returns (France)');

% ACF for monthly forwards (split into halves)
FIG.acf_X_DE_1 = local_plot_acf_grid( ...
    R_X_DE, names_DE, opts.maxLag, 1, ceil(size(R_X_DE,2)/2), ...
    'Autocorrelation - Monthly Forward Returns (Germany, First Half)');

FIG.acf_X_DE_2 = local_plot_acf_grid( ...
    R_X_DE, names_DE, opts.maxLag, ceil(size(R_X_DE,2)/2)+1, size(R_X_DE,2), ...
    'Autocorrelation - Monthly Forward Returns (Germany, Second Half)');

FIG.acf_X_FR_1 = local_plot_acf_grid( ...
    R_X_FR, names_FR, opts.maxLag, 1, ceil(size(R_X_FR,2)/2), ...
    'Autocorrelation - Monthly Forward Returns (France, First Half)');

FIG.acf_X_FR_2 = local_plot_acf_grid( ...
    R_X_FR, names_FR, opts.maxLag, ceil(size(R_X_FR,2)/2)+1, size(R_X_FR,2), ...
    'Autocorrelation - Monthly Forward Returns (France, Second Half)');

% Volatility term structure (monthly forwards)
FIG.samuelson_X_DE = figure;
bar(std(R_X_DE, 0, 1, 'omitnan'));
xlabel('Delivery month'); ylabel('Volatility');
title('Volatility term structure - Monthly forwards (Germany)');
grid on;

FIG.samuelson_X_FR = figure;
bar(std(R_X_FR, 0, 1, 'omitnan'));
xlabel('Delivery month'); ylabel('Volatility');
title('Volatility term structure - Monthly forwards (France)');
grid on;

% Correlation surfaces (monthly forward returns)
FIG.corr_X_DE = figure;
imagesc(corr(R_X_DE, 'Rows', 'pairwise')); colorbar;
xlabel('Delivery month'); ylabel('Delivery month');
title('Correlation surface of monthly forward returns - Germany');

FIG.corr_X_FR = figure;
imagesc(corr(R_X_FR, 'Rows', 'pairwise')); colorbar;
xlabel('Delivery month'); ylabel('Delivery month');
title('Correlation surface of monthly forward returns - France');

% -------------------------
% 6) Monthly forward curves snapshots (selected observation dates)
% -------------------------
FIG.curves_FR = figure; hold on; grid on;
idxDates = unique(round(linspace(1, size(X_FR,1), 6)));
for i = idxDates
    plot(1:size(X_FR,2), X_FR(i,:), 'LineWidth', 1.5);
end
xlabel('Delivery Month'); ylabel('Price (€/MWh)');
title('Monthly Forward Curves - France (Selected Dates)');

FIG.curves_DE = figure; hold on; grid on;
idxDates = unique(round(linspace(1, size(X_DE,1), 6)));
for i = idxDates
    plot(1:size(X_DE,2), X_DE(i,:), 'LineWidth', 1.5);
end
xlabel('Delivery Month'); ylabel('Price (€/MWh)');
title('Monthly Forward Curves - Germany (Selected Dates)');
end

% =========================
% Local helpers
% =========================
function fig = local_plot_normality_examples(R, names, idx, figTitle)
%LOCAL_PLOT_NORMALITY_EXAMPLES Plot histogram + fitted normal pdf for selected series.
%
% Inputs:
%   R         nObs-by-nSeries return matrix.
%   names     1-by-nSeries string array of series names.
%   idx       Vector of series indices to plot (up to 6 will be shown).
%   figTitle  Figure title (string/char).
%
% Outputs:
%   fig       Figure handle.

fig = figure;
tiledlayout(2, 3, 'TileSpacing', 'compact', 'Padding', 'compact');

for k = 1:min(6, numel(idx))
    j = idx(k);
    x = R(:, j);
    x = x(isfinite(x));
    if numel(x) < 30 || std(x) == 0
        continue;
    end

    mu = mean(x);
    sigma = std(x);

    nexttile;
    histogram(x, 'Normalization', 'pdf'); hold on;

    xx = linspace(min(x), max(x), 200);
    plot(xx, normpdf(xx, mu, sigma), 'r', 'LineWidth', 2);

    grid on;
    title(names(j), 'Interpreter', 'none');
end

sgtitle(figTitle);
end

function fig = local_plot_acf_grid(R, names, maxLag, jStart, jEnd, figTitle)
%LOCAL_PLOT_ACF_GRID Plot an ACF grid for a range of series indices.
%
% Inputs:
%   R         nObs-by-nSeries return matrix.
%   names     1-by-nSeries string array of series names.
%   maxLag    Maximum lag (non-negative integer).
%   jStart    First series index to plot (1-based).
%   jEnd      Last series index to plot (1-based).
%   figTitle  Figure title (string/char).
%
% Outputs:
%   fig       Figure handle.

nCols  = 3;
nPlots = max(0, jEnd - jStart + 1);
nRows  = max(1, ceil(nPlots / nCols));

fig = figure;
tiledlayout(nRows, nCols, 'TileSpacing', 'compact', 'Padding', 'compact');

for j = jStart:jEnd
    x = R(:, j);
    x = x(isfinite(x));
    if numel(x) < 30 || std(x) == 0
        continue;
    end

    % Sample autocorrelation via normalized cross-correlation
    [acf, lags] = xcorr(x - mean(x), maxLag, 'coeff');

    % Approximate 95% confidence bounds for white noise
    conf = 1.96 / sqrt(length(x));

    nexttile;
    idxPos = lags >= 0;
    stem(lags(idxPos), acf(idxPos), 'filled'); hold on;

    yline(conf,  'r--', 'LineWidth', 1);
    yline(-conf, 'r--', 'LineWidth', 1);
    yline(0,     'k-',  'LineWidth', 0.8);

    grid on;
    title(names(j), 'Interpreter', 'none');
    xlabel('Lag'); ylabel('ACF');
end

sgtitle(figTitle);
end
