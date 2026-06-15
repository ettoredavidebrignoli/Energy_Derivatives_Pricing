function mu = build_mu_fixed_columns(d, b)
%BUILD_MU_FIXED_COLUMNS Build a monthly forward curve on a fixed 36-month grid.
%
% The curve is constructed using the following rules:
%   1) Monthly contracts have absolute priority (Mc1..Mc4).
%   2) For each quarterly contract (Qc1..Qc4): if some months within the quarter
%      are missing but the quarterly price is available, fill missing months by
%      enforcing the quarterly simple average.
%   3) For each yearly contract (Yc1..Yc2): if some months within the year are
%      missing but the yearly price is available, fill missing months by
%      enforcing the yearly simple average.
%   4) Fallback: if any month is still NaN, fill remaining NaNs with the mean of
%      available months (or 0 if everything is NaN).
%
% Inputs:
%   d   Observation date (datetime).
%   b   1-by-10 double vector:
%         [Mc1 Mc2 Mc3 Mc4 Qc1 Qc2 Qc3 Qc4 Yc1 Yc2]
%       where entries may be NaN if not available.
%
% Outputs:
%   mu  36-by-1 double vector containing the monthly curve from the month
%       immediately after d, for 36 consecutive months.

idx = contract_month_indices_fixed(d);
mu  = NaN(36,1);

% 1) Monthly contracts (absolute priority)
for k = 1:4
    if ~isnan(b(k))
        mu(idx.M(k)) = b(k);
    end
end

% 2) Quarterly contracts: enforce simple average across the 3 months
for k = 1:4
    Q = b(4+k);                     % Qc(k)
    if isnan(Q), continue; end

    mIdx  = idx.Q(k,:);             % 1-by-3 indices on the 1..36 grid
    known = ~isnan(mu(mIdx));
    miss  = isnan(mu(mIdx));

    if all(known), continue; end

    % Sum of missing months implied by the quarterly average:
    % 3*Q = sum(known) + sum(missing)
    rhs = 3*Q - sum(mu(mIdx(known)));
    mu(mIdx(miss)) = rhs / sum(miss);  % Spread equally across missing months
end

% 3) Yearly contracts: enforce simple average across the 12 months
for k = 1:2
    Y = b(8+k);                     % Yc(k)
    if isnan(Y), continue; end

    mIdx  = idx.Y(k,:);             % 1-by-12 indices on the 1..36 grid
    known = ~isnan(mu(mIdx));
    miss  = isnan(mu(mIdx));

    if all(known), continue; end

    % 12*Y = sum(known) + sum(missing)
    rhs = 12*Y - sum(mu(mIdx(known)));
    mu(mIdx(miss)) = rhs / sum(miss);
end

% 4) Local fallback (if still NaN)
if any(isnan(mu))
    if any(~isnan(mu))
        mu(isnan(mu)) = mean(mu(~isnan(mu)));
    else
        mu(:) = 0;
    end
end
end
