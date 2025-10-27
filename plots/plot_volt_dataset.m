function h = plot_volt_dataset(h, number_of_subplots, counter_subplot, v)
% PLOT_VOLT_DATASET Plot a voltage vector within a tiled subplot grid.
%
% Inputs:
%   h                  - Figure handle to plot into.
%   number_of_subplots - Number of rows/cols (square grid).
%   counter_subplot    - Linear index of the subplot to use.
%   v                  - Voltage vector to plot.
%
% Output:
%   h                  - Same figure handle for chaining.

set(0, 'CurrentFigure', h);
subplot(number_of_subplots, number_of_subplots, counter_subplot, 'Parent', h, 'NextPlot', 'add');
set(gca,'FontSize',30)
plot(v, 'LineWidth', 3, 'Color', 'b');
ylabel('Voltage (V)', 'FontSize', 30);
xlabel('Measurements', 'FontSize', 30);
end