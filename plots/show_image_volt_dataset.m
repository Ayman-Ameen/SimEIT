function h = show_image_volt_dataset(h, number_of_subplots, counter_subplot, v)
% SHOW_IMAGE_VOLT_DATASET Visualize voltage vector reshaped as an image.
%   h = SHOW_IMAGE_VOLT_DATASET(h, number_of_subplots, counter_subplot, v)
%   Inputs:
%     h                 - Figure handle to plot into
%     number_of_subplots- Subplots per row/column (n creates n-by-n grid)
%     counter_subplot   - Subplot index (position in the grid)
%     v                 - Voltage vector, reshaped to a square image
%   Output:
%     h                 - The same figure handle (for chaining)

set(0, 'CurrentFigure', h);
subplot(number_of_subplots, number_of_subplots, counter_subplot, 'Parent', h, 'NextPlot', 'add');
set(gca, 'FontSize', 30)
imagesc(reshape(v, sqrt(length(v)), []));
colorbar;
axis equal; axis tight;
caxis([min(v(:)), max(v(:))]);

end