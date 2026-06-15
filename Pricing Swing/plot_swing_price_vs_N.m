function plot_swing_price_vs_N(N_min, N_max, t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, K)
%PLOT_SWING_PRICE_VS_N Plot swing option price as a function of the max number of exercises N.
%
% The function:
%   - Prices a swing option for N = N_min,...,N_max
%   - Computes the strip (sum of daily European calls) as an upper bound
%   - Highlights N = 15 and (if within the range) N = 22
%   - Adjusts y-limits to add some headroom for readability
%
% Inputs:
%   N_min       Minimum number of exercise rights (integer >= 1).
%   N_max       Maximum number of exercise rights (integer >= N_min).
%   t0          Valuation date (datetime).
%   datesDisc   Discount curve pillar dates (datetime vector).
%   discounts   Discount factors corresponding to datesDisc (numeric vector).
%   startDate   Start of the delivery window (datetime).
%   endDate     End of the delivery window (datetime).
%   F0          Forward level used for pricing (scalar).
%   sigma_DE    Volatility loading vector (1-by-nComp).
%   K           Strike price (scalar).
%
% Outputs:
%   (none)      The function produces a figure.

% Vector of N values to evaluate
N_vec = (N_min:N_max).';
price_swing_vec = zeros(size(N_vec));

% Reference values to highlight on the curve
N15 = 15;
N22 = 22;

% Price the swing option for each N in the grid
for i = 1:numel(N_vec)
    N_i = N_vec(i);
    price_swing_vec(i) = price_swing_option( ...
        t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, N_i, K);
end

% Strip of daily European calls (upper-bound consistency check)
price_strip = price_sum_calls(t0, datesDisc, discounts, startDate, endDate, F0, sigma_DE, K);

% Indices for highlighted points
idx15 = find(N_vec == N15, 1);
idx22 = find(N_vec == N22, 1);

figure;

% Main curve: swing price vs N
plot(N_vec, price_swing_vec, 'LineWidth', 1.5);
grid on; hold on;

% Upper bound line (strip)
yline(price_strip, '--', 'Strip upper bound', 'LineWidth', 1.2);

% Vertical reference lines
xline(N15, ':', sprintf('N = %d', N15), 'LineWidth', 1.0);
if ~isempty(idx22)
    xline(N22, ':', sprintf('N = %d', N22), 'LineWidth', 1.0);
end

% Highlight points (N=15 and, if present, N=22)
if ~isempty(idx15)
    plot(N15, price_swing_vec(idx15), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
end
if ~isempty(idx22)
    plot(N22, price_swing_vec(idx22), 'ro', 'MarkerSize', 8, 'LineWidth', 2);
end

% Add headroom to make the plot look less "tight"
y_max = max([price_swing_vec; price_strip]);
y_min = min(price_swing_vec);

top_margin = 0.08;   % 8% headroom above the maximum
bot_margin = 0.05;   % 5% margin below the minimum
ylim([y_min - bot_margin*abs(y_max - y_min), y_max + top_margin*abs(y_max - y_min)]);

% Labels and title
xlabel('N (max number of exercises)');
ylabel('Swing option price');
title('Swing option price vs N');

% Legend
legend('Swing price', 'Strip upper bound', 'Highlighted N', 'Location', 'best');

% Optional export
% exportgraphics(gcf, fullfile("Images","swing_vs_N_K40.pdf"), "ContentType","vector");

hold off;
end
