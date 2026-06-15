function discounts_interp = discount_interp(dates, discounts, dates_interp, today)
%DISCOUNT_INTERP Interpolate discount factors using linearly interpolated zero rates.
%
% The procedure is:
%   1) Convert input discount factors to continuously-compounded zero rates:
%        z(t) = -log(DF(t)) / yearfrac(today, t)
%   2) Linearly interpolate zero rates to the target dates.
%   3) Convert back to discount factors at the target dates:
%        DF_interp = exp(-z_interp * yearfrac(today, t_interp))
%
% Inputs:
%   dates          n-by-1 datetime vector of discount curve pillar dates.
%   discounts      n-by-1 vector of discount factors corresponding to 'dates'.
%   dates_interp   m-by-1 (or scalar) datetime(s) where the discount factor is needed.
%   today          Scalar datetime representing the curve reference date (valuation date).
%
% Outputs:
%   discounts_interp  m-by-1 (or scalar) interpolated discount factor(s) at dates_interp.

% Year fractions from today to pillar dates and to interpolation dates (basis 3)
yf        = yearfrac(today, dates, 3);
yf_interp = yearfrac(today, dates_interp, 3);

% Convert discount factors to continuously-compounded zero rates
zrates = -log(discounts) ./ yf;

% Interpolate zero rates (linear interpolation)
zrates_interp = interp1(dates, zrates, dates_interp, "linear");

% Convert interpolated zero rates back to discount factors
discounts_interp = exp(-zrates_interp .* yf_interp);
end