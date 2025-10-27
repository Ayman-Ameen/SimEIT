function h = show_fem_dataset(h, number_of_subplots, counter_subplot, img)
% SHOW_FEM_DATASET Display FEM mesh using EIDORS.
%   h = SHOW_FEM_DATASET(h, number_of_subplots, counter_subplot, img)
%   Inputs:
%     h                 - Figure handle to plot into
%     number_of_subplots- Subplots per row/column (n creates n-by-n grid)
%     counter_subplot   - Subplot index (position in the grid)
%     img               - EIDORS image object to display
%   Output:
%     h                 - The same figure handle (for chaining)

    set(0, 'CurrentFigure', h);
    set(gca, 'FontSize', 30);
    set(gca, 'visible', 'off');
    % Create axes and show mesh
    subplot(number_of_subplots, number_of_subplots, counter_subplot, ...
            'Parent', h, 'NextPlot', 'add');
    show_fem(img);
    axis equal; axis tight;
end