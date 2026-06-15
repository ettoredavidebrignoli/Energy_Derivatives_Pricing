function CURVES = build_monthly_forward_curves(T, nMonths)
%BUILD_MONTHLY_FORWARD_CURVES Build monthly forward curves for DE and FR.
%
% The function extracts two blocks of contract quotes from the input table T:
%   - DE block: columns 1:11 (date + 10 DE contracts)
%   - FR block: column 1 (date) + columns 12:end (FR contracts)
% Then, for each observation date, it reconstructs a monthly forward curve
% using build_mu_fixed_columns and stores the first nMonths points.
%
% Inputs:
%   T        nRows-by-k table containing all dataset fields. This function expects:
%            - a datetime variable named 'date' in column 1
%            - DE contract quotes in columns 2:11
%            - FR contract quotes in columns 12:end
%   nMonths  Number of monthly points to store in the output curves.
%            Default: 24.
%
% Outputs:
%   CURVES   Struct with fields:
%              - T_DE : subtable used for DE (date + DE contract columns)
%              - T_FR : subtable used for FR (date + FR contract columns)
%              - X_DE : nRows-by-nMonths matrix of reconstructed DE monthly curves
%              - X_FR : nRows-by-nMonths matrix of reconstructed FR monthly curves

if nargin < 2
    nMonths = 24;  % Default number of monthly points to store
end

% Split the table into DE and FR blocks (keeping 'date' as the first column)
T_DE = T(:, 1:11);
T_FR = [T(:, 1), T(:, 12:end)];

nRows = height(T_DE);

% Preallocate output matrices (one curve per row/date)
X_DE = NaN(nRows, nMonths);
X_FR = NaN(nRows, nMonths);

for i = 1:nRows
    % ---- DE curve reconstruction ----
    d = T_DE.date(i);          % Observation date
    b = T_DE{i, 2:end};        % Contract quotes for DE (1-by-10)
    mu = build_mu_fixed_columns(d, b);  % 36-by-1 monthly curve
    m = min(nMonths, numel(mu));
    X_DE(i, 1:m) = mu(1:m).';

    % ---- FR curve reconstruction ----
    d = T_FR.date(i);          % Observation date
    b = T_FR{i, 2:end};        % Contract quotes for FR (1-by-10)
    mu = build_mu_fixed_columns(d, b);  % 36-by-1 monthly curve
    m = min(nMonths, numel(mu));
    X_FR(i, 1:m) = mu(1:m).';
end

% Pack outputs
CURVES = struct();
CURVES.T_DE = T_DE;
CURVES.T_FR = T_FR;
CURVES.X_DE = X_DE;
CURVES.X_FR = X_FR;
end
