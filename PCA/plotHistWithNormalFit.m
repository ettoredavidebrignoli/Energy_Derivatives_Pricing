function plotHistWithNormalFit(Ret)
%PLOTHISTWITHNORMALFIT Plot histogram of a return series with fitted normal pdf.
%
% Inputs:
%   Ret   nObs-by-nAssets matrix of returns.
%
% Outputs:
%   (none) The function produces a figure.

isto = Ret(:,1);                 % Select the first return series
isto = isto(~isnan(isto));       % Remove NaNs

mu = mean(isto);                 % Sample mean
sigma = std(isto);               % Sample standard deviation

figure;
histogram(isto, 'Normalization', 'pdf', 'NumBins', 40);
hold on;

% Fitted normal density
xx = linspace(min(isto), max(isto), 500);
yy = normpdf(xx, mu, sigma);
plot(xx, yy, 'LineWidth', 2);

grid on;
xlabel('Return');
ylabel('Density');
title('Histogram of returns with fitted normal');
legend('Empirical histogram', 'Normal(\mu,\sigma^2)');
end