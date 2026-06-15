function [cumExplained, nComp] = plotPCAExplained(explained, eigenvalues, threshold)
%PLOTPCAEXPLAINED Plot PCA diagnostics and select number of components.
%
% Produces:
%   - Bar plot of explained variance per component (%)
%   - Cumulative explained variance curve
%   - Elbow plot of eigenvalues
%   - Cumulative explained variance with a chosen threshold and the selected nComp
%
% Inputs:
%   explained    nCompTot-by-1 vector of explained variance percentages.
%   eigenvalues  nCompTot-by-1 vector of PCA eigenvalues.
%   threshold    Scalar percentage threshold (e.g., 90) for cumulative explained variance.
%
% Outputs:
%   cumExplained nCompTot-by-1 cumulative explained variance (%).
%   nComp        Minimum number of components such that cumExplained >= threshold.

% Explained variance per principal component
figure;
bar(explained);
xlabel('Principal Component');
ylabel('Explained variance (%)');
title('Explained variance per principal component');
grid on;

% Cumulative explained variance
cumExplained = cumsum(explained);

figure;
plot(cumExplained, '-o', 'LineWidth', 2);
hold on;
yline(90, '--', '90%', 'LineWidth', 1.5);
yline(95, '--', '95%', 'LineWidth', 1.5);
xlabel('Number of principal components');
ylabel('Cumulative explained variance (%)');
title('Cumulative explained variance');
grid on;

% Elbow plot (eigenvalues)
figure;
plot(eigenvalues, '-o', 'LineWidth', 2);
xlabel('Principal Component');
ylabel('Eigenvalue');
title('Elbow plot (PCA eigenvalues)');
grid on;

% Minimum number of components to reach the threshold
nComp = find(cumExplained >= threshold, 1);
fprintf('Number of components explaining %.0f%% variance: %d\n', threshold, nComp);

% Highlight the chosen threshold and component index
figure;
plot(cumExplained, '-o', 'LineWidth', 2);
hold on;
yline(threshold, '--', sprintf('%.0f%%', threshold), 'LineWidth', 1.5);
xline(nComp, '--', sprintf('PC = %d', nComp), 'LineWidth', 1.5);
xlabel('Number of principal components');
ylabel('Cumulative explained variance (%)');
title(sprintf('Cumulative explained variance (%.0f%% threshold)', threshold));
grid on;
end