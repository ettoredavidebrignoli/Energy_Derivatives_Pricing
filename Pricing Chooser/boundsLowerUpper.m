function [lower_bound,upper_bound] = boundsLowerUpper(F1_end,F2_end,discPricing)
%BOUNDSLOWERUPPER Computes lower/upper bounds for E[max(F1,F2)]
%
% Inputs:
%   F1_end        vector of simulated terminal values of F1.
%   F2_end        vector of simulated terminal values of F2.
%   discPricing   Scalar discount factor to maturity.
%
% Outputs:
% Lower bound: discount * max(E[F1], E[F2])
% Upper bound: discount * E[F1 + F2] (since max(F1,F2) <= F1+F2)

lower_bound = discPricing * max(mean(F1_end),mean(F2_end));
upper_bound = discPricing * mean(F1_end+F2_end);
end
