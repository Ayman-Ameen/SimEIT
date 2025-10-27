% Visualize dataset samples: FEM mesh, voltages, and image data.

% Parameters to configure
clear;            % Clear workspace
close all;        % Close all figures
clc;              % Clear command window

electrodes_num     = 16;
resolution         = 256;
new_resolutions    = [32, 64, 128];
options            = '_log';
local_patch_size   = 100;
patch_number       = 22; 
do_dataset_statistics = 1; % Set to 0 to skip dataset stats

% Change to the script directory
dir_function = mfilename('fullpath');
if ~isempty(dir_function)
    [dir_function, ~, ~] = fileparts(dir_function);
    cd(dir_function);
end

home_function = pwd; addpath(home_function);

[home, ~, ~]   = fileparts(home_function);
[dir_dataset, ~, ~] = fileparts(home);
dir_dataset = [dir_dataset, '/dataset/'];

functions_folders = {'plots', 'generate_functions', 'data_functions', 'combine_and_down_scale'}; 
for counter_functions_folders = 1:length(functions_folders)
    addpath([home, '/', functions_folders{counter_functions_folders}]);
end
run([home, '/', 'eidors', '/', 'startup.m'])

%% Dataset details
[~, ~, ~, patch_number, dataset_id] = get_patch_details(electrodes_num, resolution, dir_dataset, patch_number, do_dataset_statistics);
patch_number_all = 0:1:patch_number; %#ok<NASGU>

%% HDF5 dataset paths
dataset_name      = 'dataset.h5';     filename     = [dir_dataset, dataset_name];
dataset_name_mat  = 'datasetMAT.h5';  filename_mat = [dir_dataset, dataset_name_mat]; 
field_names       = {['/','image','/', num2str(resolution)], ['/','volt','/', num2str(electrodes_num)]}; 
fields_name_mat   = {['/','img_elements','/', num2str(electrodes_num)]}; 
field_names_new   = {};
for counter = 1:length(new_resolutions)
    field_names_new{counter} = ['/', 'image', '/', num2str(new_resolutions(counter)), options];
end
field_names       = [field_names, field_names_new]; % Combine all field names
dataset_current   = ''; 
ChunkSize         = 1; %#ok<NASGU>
dir_dataset_saveMat = [dir_dataset, '/MAT/', num2str(electrodes_num), '/']; %#ok<NASGU>

%% Figure parameters
save_resolution       = 300; 
magnification_factor  = 2; 
number_of_subplots    = 1; 
number_of_all_subplots = number_of_subplots^2; % n x n grid (e.g., 5x5)
figure_length         = save_resolution * number_of_subplots * magnification_factor;
fem_resolution_factor = 3;

visible_value = 'off'; 

%% Visualization: homogeneous sample
plot_dir         = [dir_dataset, 'plots', '_', num2str(electrodes_num)]; 
if ~exist(plot_dir, 'dir'); mkdir(plot_dir); end
plot_dir_current = [plot_dir, dataset_current];
if ~exist(plot_dir_current, 'dir'); mkdir(plot_dir_current); end
typeOutput = 'mat'; %#ok<NASGU>

dir_dataset_metadata      = fullfile(dir_dataset, 'metadata');  
dir_dataset_metadata_volt = fullfile(dir_dataset_metadata, 'volt', num2str(electrodes_num));
% Load homogeneous image/voltages
image_homogenous = load(fullfile(dir_dataset_metadata_volt,'image_homogenous.mat'), 'img', 'v_homogeneous');
img = image_homogenous.img;    
v_homogeneous = image_homogenous.v_homogeneous;

h          = figure('visible', visible_value, 'Position', [0, 0, fem_resolution_factor * figure_length, fem_resolution_factor * figure_length]); counter_subplot = 1; %#ok<NASGU>
h_volt     = figure('visible', visible_value, 'Position', [0, 0, figure_length, figure_length]); 
h_volt_img = figure('visible', visible_value, 'Position', [0, 0, figure_length, figure_length]); 

h          = show_fem_dataset(h, 1, 1, img); 
v_homo     = (v_homogeneous.meas - mean(v_homogeneous.meas(:))) / std(v_homogeneous.meas(:));
h_volt     = plot_volt_dataset(h_volt, 1, 1, v_homo); 
if ~exist([plot_dir_current, '/0/'], 'dir'); mkdir([plot_dir_current, '/0/']); end
h_volt_img = show_image_volt_dataset(h_volt_img, 1, 1, v_homo); 

exportgraphics(h,         [plot_dir_current, '/0/0.png'],              'Resolution', save_resolution * number_of_subplots); 
exportgraphics(h_volt,    [plot_dir_current, '/0/0_volt.png'],         'Resolution', save_resolution * number_of_subplots); 
exportgraphics(h_volt_img,[plot_dir_current, '/0/0_volt_image.png'],   'Resolution', save_resolution * number_of_subplots); 

close all; 

%% Load all masks 
dir_mask = [dir_dataset_metadata, '/', 'Masks', '/']; 
mask_all = {};

Masks_all_files = {'mask_256.mat', '', 'mask_32.mat', 'mask_64.mat', 'mask_128.mat'};
for counter = 1:length(Masks_all_files)
    if counter == 2 
        mask_all{counter} = '';
    else
        temp_mask = load([dir_mask, Masks_all_files{counter}]); 
        mask_all{counter} = temp_mask.mask;
    end
end 

%% Other samples 
% info_of_h5 = h5info(filename,[dataset_current,field_names{1}]); length_of_dataset = info_of_h5.Dataspace.Size(1);
compare_samples  = 1:10 * local_patch_size:patch_number * local_patch_size; % compare different electrodes
length_of_dataset = patch_number * dataset_id.number_of_samples; 
num_random        = 200; 
all_samples       = randi([1, length_of_dataset], [1, num_random]); % random few indices 
all_samples       = [compare_samples, all_samples]; 
% all_samples = [1,2,100,300]; 

for counter = all_samples

    output    = load_hdf5(filename,     field_names,     dataset_current, 'float', [], counter); % image = output{1}; v_diff = output{2};
    outputMat = load_hdf5(filename_mat, fields_name_mat, dataset_current, 'float', [], counter); 
    img.elem_data = outputMat{1}; %#ok<AGROW>
    save_plot_folder = [plot_dir_current, '/', num2str(counter), '/']; 
    if ~exist(save_plot_folder, 'dir'); mkdir(save_plot_folder); end
        
    for counter_plot = 1:length(output)
        h = figure('visible', visible_value, 'Position', [0, 0, figure_length, figure_length]);
        
        if counter_plot == 2  % v_diff
            var_plot = (output{counter_plot} - mean(output{counter_plot}(:))) / std(output{counter_plot}(:));
            h = plot_volt_dataset(h, number_of_subplots, counter_subplot, var_plot);
            exportgraphics(h, [save_plot_folder, num2str(counter), replace(field_names{counter_plot}, '/', '_'), '.jpg'], 'Resolution', save_resolution * number_of_subplots); 
            
            h = figure('visible', visible_value, 'Position', [0, 0, figure_length, figure_length]);
            h = show_image_volt_dataset(h, number_of_subplots, counter_subplot, output{counter_plot});
            exportgraphics(h, [save_plot_folder, num2str(counter), replace(field_names{counter_plot}, '/', '_'), '_image', '.jpg'], 'Resolution', save_resolution * number_of_subplots); 
        else
            var_plot = output{counter_plot};
            if counter_plot == 1 
                var_plot = log(var_plot);
            end
            var_plot = (var_plot - mean(var_plot(:))) / std(var_plot(:));

            h = show_image_dataset(h, number_of_subplots, counter_subplot, var_plot, mask_all{counter_plot});
            exportgraphics(h, [save_plot_folder, num2str(counter), replace(field_names{counter_plot}, '/', '_'), '.jpg'], 'Resolution', save_resolution * number_of_subplots); 
        end
    end
       
    h = figure('visible', visible_value, 'Position', [0, 0, fem_resolution_factor * figure_length, fem_resolution_factor * figure_length]);
    h = show_fem_dataset(h, number_of_subplots, counter_subplot, img); 
    exportgraphics(h, [save_plot_folder, num2str(counter), '_fem_', '.jpg'], 'Resolution', save_resolution * number_of_subplots); 

    close all; 
end