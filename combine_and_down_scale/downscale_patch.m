function [output, output_graph] = downscale_patch(image, new_resolutions, options)
% downscale_patch - Downscale images to multiple resolutions
%
% Syntax: [output, output_graph] = downscale_patch(image, new_resolutions, options)
%
% Inputs:
%   image           - Original image array (l x width x height)
%   new_resolutions - Array of target resolutions (e.g., [32, 64, 128])
%   options         - Scaling option: '_log' for logarithmic scaling
%
% Outputs:
%   output          - Cell array of downscaled images for each resolution
%   output_graph    - Cell array of flattened graph representations within circle mask
%
% Description:
%   This function downscales images to multiple target resolutions using
%   bilinear interpolation. If log scaling is enabled, it applies log10
%   transformation. The function also creates graph representations by
%   flattening the images within a circular binary mask.

output = {};
output_graph = {};

if strcmp(options, '_log')
    image = log10(image);
end

[l, ~, ~] = size(image);

for counter = 1:length(new_resolutions)
    single_resolution = new_resolutions(counter);
    binary_mask = get_binary_mask(single_resolution);
    output_once = zeros(l, single_resolution, single_resolution);
    output_graph_once = zeros(l, sum(binary_mask(:)));
    
    for counter_single_image = 1:l
        output_image = imresize(squeeze(image(counter_single_image, :, :)), [single_resolution, single_resolution], 'bilinear');
        output_once(counter_single_image, :, :) = output_image;
        output_graph_once(counter_single_image, :) = output_image(binary_mask);
    end
    
    output{counter} = output_once;
    output_graph{counter} = output_graph_once;
end

end

%% get_binary_mask
% Helper function to create a circular binary mask
function binary_mask = get_binary_mask(resolution)
    unit_circle_fcn = @(x, y) (x).^2 + (y).^2 < (1)^2;
    x = linspace(-1, 1, resolution);
    y = linspace(-1, 1, resolution);
    [X, Y] = meshgrid(x, y);
    binary_mask = unit_circle_fcn(X, Y);
end