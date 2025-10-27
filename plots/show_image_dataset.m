function h = show_image_dataset(h, number_of_subplots, counter_subplot, img, mask)
% SHOW_IMAGE_DATASET Display a 2D image with a transparency mask.
%   h = SHOW_IMAGE_DATASET(h, number_of_subplots, counter_subplot, img, mask)
%   Inputs:
%     h                 - Figure handle to plot into
%     number_of_subplots- Subplots per row/column (n creates n-by-n grid)
%     counter_subplot   - Subplot index (position in the grid)
%     img               - 2D image (or squeezable array)
%     mask              - Alpha mask (same size as img)
%   Output:
%     h                 - The same figure handle (for chaining)

    set(0, 'CurrentFigure', h);
    set(gca, 'FontSize', 30);
    set(gca, 'visible', 'off');
    % Create axes and show image
    subplot(number_of_subplots, number_of_subplots, counter_subplot, ...
            'Parent', h, 'NextPlot', 'add');
    imagesc(squeeze(img), 'AlphaData', mask);
    axis equal; axis tight;
    caxis([min(squeeze(img(:))), max(squeeze(img(:)))]);
    colormap('turbo');
end