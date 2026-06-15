function [price_MC,F1_end,F2_end] = priceMC(F1_0,F2_0,sigma1,sigma2,ttm,discPricing,nSim,nComp)
%PRICEMC Monte Carlo pricing of payoff max(F1_T, F2_T)
% under joint lognormal dynamics driven by nComp Gaussian factors.
% Inputs:
%   F1_0         Scalar initial forward price of asset 1.
%   F2_0         Scalar initial forward price of asset 2.
%   sigma1       1-by-nComp volatility loading vector for asset 1.
%   sigma2       1-by-nComp volatility loading vector for asset 2.
%   ttm          Scalar time-to-maturity in years.
%   discPricing  Scalar discount factor to maturity.
%   nSim         Scalar number of Monte Carlo simulations.
%   nComp        Scalar number of principal components by PCA.
%
% Outputs:
%   price_MC     Scalar discounted price via Monte Carlo of max(F1_T,F2_T).
%   F1_end       1-by-nSim vector of simulated terminal values of F1.
%   F2_end       1-by-nSim vector of simulated terminal values of F2.

Z = randn(nSim, nComp);                      % Independent standard normals (factor shocks)

% Terminal forwards under lognormal dynamics
F1_end = F1_0*exp(-0.5*norm(sigma1)^2*ttm + sqrt(ttm)*sigma1*Z');
F2_end = F2_0*exp(-0.5*norm(sigma2)^2*ttm + sqrt(ttm)*sigma2*Z');

% Payoff and discounted expectation
payoff = max(F2_end,F1_end);
price_MC = discPricing * mean(payoff);
end