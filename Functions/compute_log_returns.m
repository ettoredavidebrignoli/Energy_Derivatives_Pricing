function [R, datesR] = compute_log_returns(T)
%COMPUTE_LOG_RETURNS Compute NaN-safe log returns from a data table.
%
% The function assumes T contains a datetime variable named 'date' and that
% all numeric series are stored in columns 2:end (prices/levels).
% Non-finite values and non-positive prices are converted to NaN before
% computing log-returns.
%
% Inputs:
%   T       nRows-by-k table containing all dataset fields. This function expects:
%           - T.date : nRows-by-1 datetime vector
%           - T{:,2:end} : numeric matrix of price series
%
% Outputs:
%   R       (nRows-1)-by-nSeries matrix of log returns (NaN-safe).
%   datesR  (nRows-1)-by-1 datetime vector aligned with rows of R (T.date(2:end)).

% Extract numeric series (all columns except date)
X = T{:, 2:end};

% Sanitize inputs: remove non-finite entries and non-positive prices
X(~isfinite(X)) = NaN;
X(X <= 0) = NaN;  % Avoid log(0) and log(negative)

% Compute log returns
R = diff(log(X));
R(~isfinite(R)) = NaN;

% Align return dates with the second row onward
datesR = T.date(2:end);
end