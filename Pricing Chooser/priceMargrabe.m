function price_margrabe = priceMargrabe(F1_0,F2_0,sigma1,sigma2,ttm,discPricing)
%PRICEMARGRABE Margrabe formula for an exchange-style option component
% using the effective volatility of the spread.
% Inputs:
%   F1_0         Scalar initial forward price of asset 1.
%   F2_0         Scalar initial forward price of asset 2.
%   sigma1       1-by-nComp volatility loading vector for asset 1.
%   sigma2       1-by-nComp volatility loading vector for asset 2.
%   ttm          Scalar time-to-maturity in years.
%   discPricing  Scalar discount factor to maturity.
%
% Outputs:
%   price_margrabe  Scalar discounted price computed with the Margrabe setup.

sigM = norm(sigma1 - sigma2);               % Effective volatility
tau  = ttm;                                  % Time-to-maturity

d1 = (log(F1_0/F2_0) + 0.5*sigM^2*tau) / (sigM*sqrt(tau));
d2 = d1 - sigM*sqrt(tau);

% Discounted value (as implemented in the original code)
price_margrabe = discPricing * (F1_0*normcdf(d1) + F2_0*normcdf(-d2));
end