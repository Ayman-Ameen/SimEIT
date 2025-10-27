function show_volt_image_dataset(h, plot_folder, number_of_subplots, image_electric_volt, save_resolution, number_of_all_subplots)
% SHOW_VOLT_IMAGE_DATASET Save a paginated grid of voltage images to disk.
%   SHOW_VOLT_IMAGE_DATASET(h, plot_folder, number_of_subplots, image_electric_volt,
%                           save_resolution, number_of_all_subplots)
%   Inputs:
%     h                     - Figure handle to plot into
%     plot_folder           - Output directory for saved images
%     number_of_subplots    - Subplots per row/column (n creates n-by-n grid)
%     image_electric_volt   - 4D array [batch x image_idx x H x W]
%     save_resolution       - Base resolution multiplier for exportgraphics
%     number_of_all_subplots- Total subplots per figure (n^2)

set(0, 'CurrentFigure', h);

[number_of_volt_images, ~, ~] = size(squeeze(image_electric_volt));
counter_subplot = 1; counter_figure_internal = 1;

for counter = 1:number_of_volt_images
    % Create axes and show one voltage image
    subplot(number_of_subplots, number_of_subplots, counter_subplot, 'Parent', h, 'NextPlot', 'add');
    imagesc(squeeze(image_electric_volt(1, counter, :, :)));
    colorbar; axis equal; axis tight; title(num2str(counter));
    caxis([min(reshape(image_electric_volt(1, counter, :, :), 1, [])), ...
           max(reshape(image_electric_volt(1, counter, :, :), 1, []))]);

    counter_subplot = counter_subplot + 1;
    if or(counter_subplot > number_of_all_subplots, number_of_volt_images == counter)
        if ~exist(plot_folder, 'dir'); mkdir(plot_folder); end
        exportgraphics(h, [plot_folder, num2str(counter_figure_internal), '.jpg'], ...
                       'Resolution', save_resolution * number_of_subplots);
        counter_subplot = 1;
        counter_figure_internal = counter_figure_internal + 1;
    end
end