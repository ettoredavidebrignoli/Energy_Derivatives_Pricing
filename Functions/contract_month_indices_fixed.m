function idx = contract_month_indices_fixed(d)
%CONTRACT_MONTH_INDICES_FIXED Map contract buckets to a fixed 36-month grid.
%
% The 36-month grid starts at the month immediately after the observation date d.
% This function returns index mappings for:
%   - Monthly contracts Mc1..Mc4   -> first 4 months of the grid
%   - Quarterly contracts Qc1..Qc4 -> the first full not-yet-started calendar quarter
%                                   and the next three quarters
%   - Yearly contracts Yc1..Yc2    -> the first full not-yet-started calendar year
%                                   and the next year
%
% Inputs:
%   d    Observation date (datetime).
%
% Outputs:
%   idx  Struct with fields:
%        idx.M : 1-by-4 indices for Mc1..Mc4
%        idx.Q : 4-by-3 indices for Qc1..Qc4 (each row is a quarter, 3 months)
%        idx.Y : 2-by-12 indices for Yc1..Yc2 (each row is a year, 12 months)

% Build the 36-month grid: month immediately after d for 36 months
startMonth = dateshift(d, 'start', 'month') + calmonths(1);
grid36 = startMonth + calmonths(0:35);

% ---- Monthly mapping ----
idx.M = 1:4;

% ---- Quarterly mapping ----
qStarts = [1 4 7 10];               % Calendar quarter start months (Jan, Apr, Jul, Oct)
m = month(d);
y = year(d);

% First full not-yet-started quarter: choose the next quarter start month > current month
nextQ = qStarts(find(qStarts > m, 1, 'first'));
if isempty(nextQ)
    nextQ = 1;                      % If none left in the year, move to next year's Q1
    yQ = y + 1;
else
    yQ = y;
end
qStartDate = datetime(yQ, nextQ, 1);

idx.Q = zeros(4,3);
for k = 1:4
    qkStart = qStartDate + calmonths(3*(k-1));
    monthsQ = qkStart + calmonths(0:2);

    % Locate each quarter month inside the 36-month grid
    idx.Q(k,:) = arrayfun(@(dt) find(year(grid36)==year(dt) & month(grid36)==month(dt), 1), monthsQ);
end

% ---- Yearly mapping ----
% First full not-yet-started calendar year
y1 = y + 1;

idx.Y = zeros(2,12);
for k = 1:2
    yk = y1 + (k-1);
    monthsY = datetime(yk, 1, 1) + calmonths(0:11);

    % Locate each yearly month inside the 36-month grid
    idx.Y(k,:) = arrayfun(@(dt) find(year(grid36)==year(dt) & month(grid36)==month(dt), 1), monthsY);
end
end
