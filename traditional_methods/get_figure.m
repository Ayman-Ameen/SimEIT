function [the_figure,save_properties] = get_figure()
save_properties.fem_resolution_factor = 1 ; save_properties.visible_vaule  = 'off' ; 
% GET_FIGURE Creates a figure with specific properties for saving and visualization
%   [the_figure, save_properties] = get_figure()
%   Returns a figure handle and a struct with save/display properties.
the_figure    = figure('visible',save_properties.visible_vaule, 'Position', [0, 0, save_properties.fem_resolution_factor* save_properties.figure_length , save_properties.fem_resolution_factor* save_properties.figure_length]);
save_properties.save_resolution = 150;
save_properties.magnification_factor = 2;
save_properties.number_of_subplots = 1;
save_properties.number_of_all_subplots = save_properties.number_of_subplots^2; % n*n subplots
save_properties.figure_length = save_properties.save_resolution * save_properties.number_of_subplots * save_properties.magnification_factor;
save_properties.fem_resolution_factor = 1;
save_properties.visible_value = 'off';
the_figure = figure('visible', save_properties.visible_value, 'Position', [0, 0, save_properties.fem_resolution_factor * save_properties.figure_length, save_properties.fem_resolution_factor * save_properties.figure_length]);
end