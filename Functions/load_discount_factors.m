function [datesDisc, discounts] = load_discount_factors(discountFile)
%LOAD_DISCOUNT_FACTORS Load discount factors from an Excel file.
%
% The function expects an Excel sheet structured as:
%   - Row 1: Excel serial dates (one per column)
%   - Row 2: Discount factors (one per column, matching the dates)
%
% Inputs:
%   discountFile  String/char path to the Excel file containing discount data.
%
% Outputs:
%   datesDisc     n-by-1 datetime vector of curve pillar dates (converted from Excel serial).
%   discounts     n-by-1 double vector of discount factors aligned with datesDisc.

% Read the Excel file into a table
discTable = readtable(discountFile);

% Extract first row as Excel serial dates and convert to datetime
excelDates = table2array(discTable(1, :));
datesDisc  = datetime(excelDates, 'ConvertFrom', 'excel');

% Extract second row as discount factors
discounts = table2array(discTable(2, :));

% Ensure column vectors
datesDisc  = datesDisc(:);
discounts  = discounts(:);
end