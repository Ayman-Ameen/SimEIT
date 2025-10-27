% TRADITIONAL_METHODS Solve dataset test samples with traditional EIT reconstruction methods
%
% This script reconstructs EIT images from test samples using traditional
% inverse problem solving methods such as Total Variation, Tikhonov
% regularization, and Gauss-Newton solvers. It evaluates performance
% across different noise levels and saves reconstruction results and metrics.
%
% Configuration Parameters:
%   electrodes_num          - Number of electrodes (default: 16)
%   resolution              - Image resolution (default: 32)
%   resolution_reconstruct  - Reconstruction resolution (default: 64)
%   methods_names           - Cell array of method names to evaluate
%   noise_all               - Array of noise levels to test (default: [Inf, 10, 20, 30, 40, 50])
%
% Output:
%   - Reconstructed images saved as PNG and XLS files
%   - Correlation coefficient and relative error metrics saved as XLS files

clear;
close all;
clc;

%% Configuration parameters
electrodes_num = 16  ;
resolution     = 32 ;
resolution_reconstruct = 64 ;
options          = '_log';
do_dataset_statistics = 0;
methods_names = {'total_variation','Tikhonov_regularization_Gauss_Newton_solver'};
resolution_convert = 256  ; resolution_scale = 32;
noise_all          = [Inf, 10, 20, 30, 40, 50];
colormap_for_patch = load('plasma.mat'); colormap_for_patch = colormap_for_patch.cmap;

%% Setup paths and add dependencies
home_function = pwd;
addpath(home_function);

[home, ~, ~] = fileparts(home_function);
[dir_dataset, ~, ~] = fileparts(home);
dir_dataset = [dir_dataset, '/dataset/'];

functions_folders = {'plots','generate_functions','data_functions','combine_and_down_scale','traditional_methods'};
for counter_functions_folders = 1 : length(functions_folders)
    addpath([home,'/' , functions_folders{counter_functions_folders}]);
end
run([home,'/','eidors','/','startup.m'])

%% Load dataset details and test indices
patch_number = [];
[data,img, v_homogeneous, patch_number, dataset_id] = get_patch_details(electrodes_num,resolution,dir_dataset,patch_number,do_dataset_statistics);
testIndices = get_test_indices(dir_dataset)';
relative_error = zeros(length(methods_names),length(noise_all),length(testIndices));
correlation_coefficient = zeros(length(methods_names),length(noise_all),length(testIndices));

%% Setup dataset file paths
dataset_name = 'dataset.h5';
filename = [dir_dataset, dataset_name];
dataset_name_mat = 'datasetMAT.h5';
filename_mat = [dir_dataset, dataset_name_mat];
field_names = {['/', 'image', '/', num2str(resolution), options], ['/', 'volt', '/', num2str(electrodes_num)]};
fields_name_mat = {['/', 'img_elements', '/', num2str(electrodes_num)]};
dataset_current = '';
ChunkSize = 1;
dir_dataset_saveMat = [dir_dataset, '/MAT/', num2str(electrodes_num), '/'];
save_dir = [dir_dataset, 'traditional_methods', '_', num2str(electrodes_num), '/'];
mkdir(save_dir);

%% Process test samples and calculate reconstruction metrics
output = cell(1, length(testIndices));
outputMat = cell(1, length(testIndices));

for counter = 1:length(testIndices)
    output{counter} = load_hdf5(filename, field_names, dataset_current, 'float', [], testIndices(counter));
    outputMat{counter} = load_hdf5(filename_mat, fields_name_mat, dataset_current, 'float', [], testIndices(counter));
    
    for counter_noise = 1:length(noise_all)
        noise = noise_all(counter_noise);
        v_homogeneous_reconstruct = rmfield(v_homogeneous, 'volt');
        volt_output = output{counter}{2}';
        img_with_objects = img;
        img_with_objects.elem_data = outputMat{counter}{1}';
        noise_volt = add_noise(volt_output, noise);
        v_img_with_objects = v_homogeneous_reconstruct;
        v_img_with_objects.meas = v_homogeneous_reconstruct.meas + volt_output + noise_volt;
        
        for counter_method = 1:length(methods_names)
            method_name = methods_names{counter_method};
            [inverse_model, metadata] = get_solver(method_name, resolution_reconstruct, electrodes_num);
            inverse_image = inv_solve(inverse_model, v_homogeneous_reconstruct, v_img_with_objects);
            
            % Convert mesh to image and save real image (only once per sample)
            if and(counter_method == 1, counter_noise == 1)
                [image_real, the_figure, save_properties] = convert_mesh_to_image_and_norm_and_scale([], [], outputMat{counter}{1}', img, resolution_convert, resolution_scale, colormap_for_patch);
                exportgraphics(the_figure, [save_dir, num2str(testIndices(counter)), '.png'], 'Resolution', save_properties.save_resolution * save_properties.number_of_subplots);
                writetable(table(image_real), [save_dir, num2str(testIndices(counter)), '.xls'], 'WriteVariableNames', false);
            end
            
            % Convert reconstructed mesh to image and calculate metrics
            [image_reconst, the_figure, save_properties] = convert_mesh_to_image_and_norm_and_scale([], [], inverse_image.elem_data, inverse_image, resolution_convert, resolution_scale, colormap_for_patch);
            [relative_error(counter_method, counter_noise, counter), correlation_coefficient(counter_method, counter_noise, counter)] = error_and_similarity(image_real, image_reconst);
            exportgraphics(the_figure, [save_dir, num2str(testIndices(counter)), '_', num2str(noise), '_', method_name, '.png'], 'Resolution', save_properties.save_resolution * save_properties.number_of_subplots);
            writetable(table(image_reconst), [save_dir, num2str(testIndices(counter)), '_', num2str(noise), '_', method_name, '.xls'], 'WriteVariableNames', false);
            close all
        end
    end
end

%% Save evaluation metrics
for counter_method = 1:length(methods_names)
    method_name = methods_names{counter_method};
    writetable(table(squeeze(correlation_coefficient(counter_method, :, :))'), [save_dir, 'Correlation_coefficient_', method_name, '.xls'], 'WriteVariableNames', false);
    writetable(table(squeeze(relative_error(counter_method, :, :))'), [save_dir, 'Relative_error_', method_name, '.xls'], 'WriteVariableNames', false);
end

%% Figure parameters for visualization
save_resolution = 300;
magnification_factor = 2;
number_of_subplots = 1;
number_of_all_subplots = number_of_subplots^2;
figure_length = save_resolution * number_of_subplots * magnification_factor;
fem_resolution_factor = 3;
visible_value = 'off';
h = figure('visible', visible_value, 'Position', [0, 0, fem_resolution_factor * figure_length, fem_resolution_factor * figure_length]);
counter_subplot = 1;

%% Visualization: Homogeneous image
plot_dir = [dir_dataset, 'plots', '_', num2str(electrodes_num)];
mkdir(plot_dir);
plot_dir_current = [plot_dir, dataset_current];
mkdir(plot_dir_current);
typeOutput = 'mat';

dir_dataset_metadata = fullfile(dir_dataset, 'metadata');
dir_dataset_metadata_volt = fullfile(dir_dataset_metadata, 'volt', num2str(electrodes_num));
image_homogeneous = load(fullfile(dir_dataset_metadata_volt, 'image_homogenous.mat'), 'img', 'v_homogeneous');
img = image_homogeneous.img;
v_homogeneous = image_homogeneous.v_homogeneous;

h = figure('visible', visible_value, 'Position', [0, 0, fem_resolution_factor * figure_length, fem_resolution_factor * figure_length]);
counter_subplot = 1;
h_volt = figure('visible', visible_value, 'Position', [0, 0, figure_length, figure_length]);
h_volt_img = figure('visible', visible_value, 'Position', [0, 0, figure_length, figure_length]);

h = show_fem_dataset(h, 1, 1, img);
v_homo = (v_homogeneous.meas - mean(v_homogeneous.meas(:))) / std(v_homogeneous.meas(:));
h_volt = plot_volt_dataset(h_volt, 1, 1, v_homo);
mkdir([plot_dir_current, '/0/']);
h_volt_img = show_image_volt_dataset(h_volt_img, 1, 1, v_homo);

exportgraphics(h, [plot_dir_current, '/0/0.png'], 'Resolution', save_resolution * number_of_subplots);
exportgraphics(h_volt, [plot_dir_current, '/0/0_volt.png'], 'Resolution', save_resolution * number_of_subplots);
exportgraphics(h_volt_img, [plot_dir_current, '/0/0_volt_image.png'], 'Resolution', save_resolution * number_of_subplots);

close all;

%% Load all masks
dir_mask = [dataset_metadata, '/', 'Masks', '/'];
mask_all = {};

Masks_all_files = {'mask_256.mat','','mask_32.mat','mask_64.mat','mask_128.mat'};
for counter = 1:length(Masks_all_files)
    if counter == 2
        mask_all{counter} = '';
    else
        temp_mask = load([dir_mask, Masks_all_files{counter}]);
        mask_all{counter} = temp_mask.mask;
    end
end

%% Visualization: Additional samples
compare_samples = 1:10 * local_patch_size:patch_number * local_patch_size;
length_of_dataset = patch_number * dataset_id.number_of_samples;
num_random = 200;
all_samples = randi([1, length_of_dataset], [1, num_random]);
all_samples = [compare_samples, all_samples];

for counter = all_samples
    
    output = load_hdf5(filename, field_names, dataset_current, 'float', [], counter);
    outputMat = load_hdf5(filename_mat, fields_name_mat, dataset_current, 'float', [], counter);
    img.elem_data = outputMat{1};
    save_plot_folder = [plot_dir_current, '/', num2str(counter), '/'];
    mkdir(save_plot_folder);
    
    for counter_plot = 1:length(output)
        
        h = figure('visible', visible_value, 'Position', [0, 0, figure_length, figure_length]);
        
        if counter_plot == 2  % Voltage difference
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
