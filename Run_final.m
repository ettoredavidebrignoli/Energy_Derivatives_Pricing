clc
clear all
close all

%%
addpath("Functions");
addpath("PCA");
addpath("Pricing Chooser");
addpath("Pricing Swing");

%%
opts = struct();
opts.doPlots = true;
opts.maxLag  = 20;
opts.nMonths = 24;

%% Load + clean + base objects
warning('off','all');

DATA = load_power_futures_data("power_DE_FR.csv", opts);

% Legacy variables (used later in Exercises 3-5)
T             = DATA.T_clean;
toRemove      = DATA.toRemove;
dates         = DATA.dates;
F             = DATA.F;
legend_labels = DATA.legendLabels;
contractNames = DATA.seriesNames;

% Missing data report on the plotted matrix (F)
MISS = analyze_missing_data(F, contractNames, opts.doPlots);

% Contract log-returns (used in Exercise 1 diagnostics + PCA masking etc.)
[RET_contracts, datesR] = compute_log_returns(T);
DIAG_contracts = compute_return_diagnostics(RET_contracts, contractNames, datesR);

%% Exercise 1 - contracts analysis
E1 = struct();
E1.toRemove = toRemove;
E1.R        = RET_contracts;
E1.datesR   = datesR;
E1.stats    = DIAG_contracts.stats;
E1.adf      = DIAG_contracts.adf;
E1.jb       = DIAG_contracts.jb;
E1.C        = DIAG_contracts.C;
E1.corr_w   = DIAG_contracts.corr_w;
E1.corr_m   = DIAG_contracts.corr_m;

% Attach returns to diagnostics for plotting (normality/ACF)
DIAG_contracts.R = RET_contracts;

%% Exercise 2 - monthly forward curve reconstruction + analysis
CURVES = build_monthly_forward_curves(T, opts.nMonths);

X_DE = CURVES.X_DE;
X_FR = CURVES.X_FR;
X    = [X_DE X_FR];

% Monthly forward returns diagnostics (DE/FR separately)
R_X_DE = diff(log(X_DE)); R_X_DE(~isfinite(R_X_DE)) = NaN;
R_X_FR = diff(log(X_FR)); R_X_FR(~isfinite(R_X_FR)) = NaN;

names_DE = "DE_M" + string(1:size(R_X_DE,2));
names_FR = "FR_M" + string(1:size(R_X_FR,2));

DIAG_X_DE = compute_return_diagnostics(R_X_DE, names_DE, []);
DIAG_X_FR = compute_return_diagnostics(R_X_FR, names_FR, []);

E2 = struct();
E2.X_DE = X_DE;
E2.X_FR = X_FR;
E2.X    = X;
E2.R_X_DE = R_X_DE;
E2.R_X_FR = R_X_FR;
E2.stats_DE = DIAG_X_DE.stats;
E2.stats_FR = DIAG_X_FR.stats;

if opts.doPlots
    FIG = make_exploratory_plots(DATA, DIAG_contracts, CURVES, opts);
end

warning('on','all');
[datesDisc, discounts] = load_discount_factors("discount_factors.xlsx");

%% Exercise 3 - Principal Component Analysis

% Concatenate the two price matrices (e.g., DE and FR) into a single data matrix
X = [X_DE X_FR];

% Build log-returns suitable for PCA (filtering invalid rows and cross-month returns)
Ret = buildReturnsPCA(X, toRemove, T);

% Plot histogram of the first return series with an overlaid normal fit
plotHistWithNormalFit(Ret);

% Remove multivariate outliers using Mahalanobis distance before running PCA
Ret_pca = removeOutliersMahalanobis(Ret);

% Perform PCA on cleaned returns (centered)
[eigenvectors, score, eigenvalues, tsq, explained, mu_ret] = pca(Ret_pca, 'Centered', true);

% Choose the minimum number of components needed to reach the explained-variance threshold
threshold = 90;
[~, nComp] = plotPCAExplained(explained, eigenvalues, threshold);

%% Exercise 4 - Price chooser option

% Closed-form pricing 
gamma = diag(eigenvalues(1:nComp));          % Diagonal matrix of the principal eigenvalues
C = eigenvectors(:,1:nComp);                % Matrix of the principal eigenvectors

dt = 1/252;                                  % Daily time step in year fractions (business days)
sigma_sim = C*sqrt(gamma)*dt^(-0.5);        % Volatility loading matrix scaled to annualized units

F1_0 = X_DE(end,17);                         % Initial forward price for DE contract 
F2_0 = X_FR(end,17);                         % Initial forward price for FR contract 

sigma1 = sigma_sim(17,:);                    % Volatility vector for DE contract
sigma2 = sigma_sim(17+24,:);                 % Volatility vector for FR contract

t0 = datetime(2025,11,4);                    % Valuation date
T1 = datetime(2027,2,5);                     % Option maturity date
ttm = yearfrac(t0, T1, 3);                   % Time-to-maturity in year fractions (ACT/365)

discPricing = discount_interp(datesDisc,discounts,datetime(2027,2,5),t0); % Discount factor to maturity

price_closedform = priceClosedForm(F1_0,F2_0,sigma1,sigma2,ttm,discPricing); % Closed-form chooser price

% Monte Carlo pricing 
rng(42);                                     % Fix seed for reproducibility
nSim = 100000;                               % Number of Monte Carlo simulations
[price_MC, F1_end, F2_end] = priceMC(F1_0,F2_0,sigma1,sigma2,ttm,discPricing,nSim,nComp); % MC estimate

% Margrabe option pricing (price of max(F1,F2))
price_margrabe = priceMargrabe(F1_0, F2_0, sigma1, sigma2, ttm, discPricing); % Margrabe formula

% Lower & upper bounds (estimated from MC terminal samples) 
[lower_bound, upper_bound] = boundsLowerUpper(F1_end, F2_end, discPricing);  

% Print results
fprintf('\nClosed form  : %.10f\n', price_closedform);
fprintf('Monte Carlo  : %.10f\n', price_MC);
fprintf('Margrabe     : %.10f\n', price_margrabe);
fprintf('Lower bound  : %.10f\n', lower_bound);
fprintf('Upper bound  : %.10f\n', upper_bound);

%% Exercise 5 - Pricing Swing Option

% Define the delivery window for the swing option (calendar dates)
startDate = datetime(2027,11,1);
endDate   = datetime(2027,11,30);

% Build the set of business days within the delivery window
datesVec = (startDate:endDate).';
datesVec = businessdayoffset(datesVec);   % Roll dates to business days (according to MATLAB calendar rules)
n_days = length(datesVec);                % Number of (adjusted) business days in the window

% Strike and underlying inputs 
K  = 40;                                   % Strike price
F0 = X_DE(end, 24);                        % Forward level used for pricing
sigma_DE = sigma_sim(24,:);                % Volatility loading vector for that forward (1-by-nComp)

% Swing option with N = 15 exercise rights (assignment setting)
N15 = 15;
price_swing_15 = price_swing_option(t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, N15, K);

% Swing option with N equal to the number of business days (upper bound / maximal flexibility)
Nmax = n_days;
price_swing_Nmax = price_swing_option(t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, Nmax, K);

% Strip of daily European calls (upper-bound consistency check)
price_strip = price_sum_calls(t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, K);

% Print results
fprintf('\nSwing price (N = %d): %.10f\n', N15, price_swing_15);
fprintf('Swing price (N = %d): %.10f\n', Nmax, price_swing_Nmax);
fprintf('Sum of daily European calls (strip): %.10f\n\n', price_strip);

%% Plot swing price as a function of N (highlight key N values)

N_min = 1;                                 % Minimum number of exercise rights
N_max = 50;                                % Maximum number of exercise rights (for plotting)

% Plot for different strike levels
K40 = 40;
plot_swing_price_vs_N(N_min, N_max, t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, K40)

K90 = 90;
plot_swing_price_vs_N(N_min, N_max, t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, K90)

K100 = 100;
plot_swing_price_vs_N(N_min, N_max, t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, K100)
