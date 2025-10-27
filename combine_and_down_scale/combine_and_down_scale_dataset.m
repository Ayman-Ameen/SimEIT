% combine_and_down_scale_dataset
% 
% This script combines dataset patches and downscales them to multiple resolutions,
% saving the results to HDF5 files. It processes images and voltage measurements,
% creates downscaled versions, and generates graph representations.
%
% Parameters to configure:
%   electrodes_num   - Number of electrodes (default: 16)
%   resolution       - Original image resolution (default: 256)
%   new_resolutions  - Target resolutions for downscaling (default: [32,64,128])
%   options          - Scaling option, '_log' for logarithmic (default: '_log')
%   graph            - Enable graph generation (default: 1)

clear;
close all;
clc; 

electrodes_num = 16;
resolution     = 256;
new_resolutions  = [32,64,128];
options          = '_log';
graph            = 1;

% Set up directory paths
try
    dir_function = mfilename('fullpath');
    [dir_function,~,~] = fileparts(dir_function);
    cd(dir_function);
catch
    error('Failed to change to function directory');
end

home_function = pwd;
addpath(home_function);

[home, ~, ~] = fileparts(home_function);
[dir_dataset, ~, ~] = fileparts(home);
dir_dataset = [dir_dataset, '/dataset/'];

functions_folders = {'plots','generate_functions','data_functions','combine_and_down_scale'};

for counter_functions_folders = 1:length(functions_folders)
    addpath([home,'/', functions_folders{counter_functions_folders}]);
end

%% Load patch details
patch_number = 21;
do_dataset_statistics = 0;
local_patch_size = 100;

[data, img, v_homogeneous, patch_number, dataset_id] = get_patch_details(electrodes_num, resolution, dir_dataset, patch_number, do_dataset_statistics);
patch_number_all = 0:1:patch_number;

%% Create the dataset files
dataset_name = 'dataset.h5';
filename = [dir_dataset, dataset_name];
try
    h5create(filename, '/description', 1, 'Datatype', 'string');
    h5write(filename, '/description', description, 1, 1);
catch
    % File or dataset may already exist
end

dataset_name_mat = 'datasetMAT.h5';
filename_mat = [dir_dataset, dataset_name_mat];
try
    h5create(filename_mat, '/description', 1, 'Datatype', 'string');
    h5write(filename_mat, '/description', description, 1, 1);
catch
    % File or dataset may already exist
end

field_names = {['/', 'image', '/', num2str(resolution)], ['/', 'volt', '/', num2str(electrodes_num)]};
fields_name_mat = {['/', 'img_elements', '/', num2str(electrodes_num)]};

field_names_new = {};
for counter = 1:length(new_resolutions)
    field_names_new{counter} = ['/', 'image', '/', num2str(new_resolutions(counter)), options];
end

field_names_graph = {};
for counter = 1:length(new_resolutions)
    field_names_graph{counter} = ['/', 'graph', '/', num2str(new_resolutions(counter)), options];
end

% Combine all field names
field_names = [field_names, field_names_new, field_names_graph];
dataset_current = '';
ChunkSize = 1;
dir_dataset_saveMat = [dir_dataset, '/MAT/', num2str(electrodes_num), '/'];

%% Process each patch
for patch_number = patch_number_all
    
    total_number_to_start_after = dataset_id.number_start_after * patch_number;
    counter_local_patch = 0;
    
    for counter_patch = 1:local_patch_size:dataset_id.number_start_after
        
        output = load([dir_dataset_saveMat, num2str(patch_number), '_', num2str(counter_local_patch), '.mat']);
        output = output.output;
        output_mat = output(3);
        output = {output{1}, output{2}};
        
        [output_downscale, output_graph] = downscale_patch(output{1}, new_resolutions, options);
        output = [output, output_downscale, output_graph];
        
        save_hdf5(filename, field_names, dataset_current, output, ChunkSize, total_number_to_start_after + counter_patch, dir_dataset);
        save_hdf5(filename_mat, fields_name_mat, dataset_current, output_mat, ChunkSize, total_number_to_start_after + counter_patch, dir_dataset);
        
        for counter_test = 1:length(output)
            if length(size(output{counter_test})) > 2
                test = any(all(all(output{counter_test} == 0, 3), 2));
            else
                test = any(all(output{counter_test} == 0, 2));
            end
            disp([field_names{counter_test}, ' --> ', num2str(patch_number), ' => ', num2str(test)]);
        end
        
        counter_local_patch = counter_local_patch + 1;
        
    end
    disp(['**********', num2str(patch_number), '**************']);
end

save_nodes_binary_mask(dir_dataset, new_resolutions)

%% save_nodes_binary_mask
% Helper function to save binary masks and node coordinates for each resolution
function save_nodes_binary_mask(dir_dataset, new_resolutions)
    folder_name = [dir_dataset, '/', 'Masks_and_nodes', '/'];
    mkdir(folder_name);
    
    for resolution = new_resolutions
        unit_circle_fcn = @(x, y) (x).^2 + (y).^2 < (1)^2;
        x = linspace(-1, 1, resolution);
        y = linspace(-1, 1, resolution);
        [X, Y] = meshgrid(x, y);
        binary_mask = unit_circle_fcn(X, Y);
        x_nodes = X(binary_mask);
        y_nodes = Y(binary_mask);
        save([folder_name, num2str(resolution), '.mat'], 'binary_mask', 'x_nodes', 'y_nodes')
    end
end