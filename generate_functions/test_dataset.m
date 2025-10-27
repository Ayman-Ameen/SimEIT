% TEST_DATASET Tests the dataset and determines which patches are incomplete
%
% This script validates the completeness of HDF5 dataset patches by checking
% for missing or zero-valued data in image, voltage, and element arrays.

clear;
close all;
clc;

electrodes_num = 16;
resolution = 256;
local_patch_size = 2500;

patch_number_all = [19];

patch_number_all_complete = zeros(size(patch_number_all));
datasetMat_num_elements = 102926;

try
    dir_function = mfilename('fullpath');
    [dir_function, ~, ~] = fileparts(dir_function);
    cd(dir_function);
catch
end

home_function = pwd;
addpath(home_function);

[home, ~, ~] = fileparts(home_function);
[dir_dataset, ~, ~] = fileparts(home);
dir_dataset = [dir_dataset, '/dataset/'];

functions_folders = {'plots', 'generate_functions', 'data_functions'};

for counter_functions_folders = 1:length(functions_folders)
    addpath([home, '/', functions_folders{counter_functions_folders}]);
end

dir_dataset_metadata = fullfile(dir_dataset, 'metadata');
dir_dataset_metadata_volt = fullfile(dir_dataset_metadata, 'volt', num2str(electrodes_num));
dataset_id_name = 'dataset_id';
dataset_id = load(fullfile(dir_dataset_metadata_volt, [dataset_id_name, '.mat']));
dataset_id = dataset_id.dataset_id;

dataset_name = 'dataset.h5';
filename = [dir_dataset, dataset_name];
dataset_name_mat = 'datasetMAT.h5';
filename_mat = [dir_dataset, dataset_name_mat];
field_names = {['/', 'image', '/', num2str(resolution)], ['/', 'volt', '/', num2str(electrodes_num)]};
fields_name_mat = {['/', 'img_elements', '/', num2str(electrodes_num)]};

local_patch_complete_matrix = ones(length(patch_number_all), int64(dataset_id.number_start_after / local_patch_size));

for patch_number = patch_number_all
    total_number_to_start_after = dataset_id.number_start_after * patch_number;
    counter_local = 1;
    
    for counter_patch = 1:local_patch_size:dataset_id.number_start_after
        try
            image = h5read(filename, field_names{1}, ...
                [total_number_to_start_after + counter_patch, 1, 1], ...
                [total_number_to_start_after + counter_patch + local_patch_size - 1, resolution, resolution], ...
                [1, 1, 1]);
            volt = h5read(filename, field_names{2}, ...
                [total_number_to_start_after + counter_patch, 1], ...
                [total_number_to_start_after + counter_patch + local_patch_size - 1, electrodes_num^2], ...
                [1, 1]);
            elements = h5read(filename_mat, fields_name_mat{1}, ...
                [total_number_to_start_after + counter_patch, 1], ...
                [total_number_to_start_after + counter_patch + local_patch_size - 1, datasetMat_num_elements], ...
                [1, 1]);
            
            image_patch = any(all(all(image == 0, 3), 2));
            volt_patch = any(all((volt) == 0, 2));
            elements_patch = any(all((elements) == 0, 2));
            
            local_patch_complete_matrix(patch_number + 1, counter_local) = ...
                any([image_patch, volt_patch, elements_patch]);
        catch
        end
        
        disp([num2str(patch_number), ',', num2str(counter_local), ' => ', ...
            num2str(local_patch_complete_matrix(patch_number + 1, counter_local))])
        counter_local = counter_local + 1;
    end
end

not_complete_patches = find(any(~local_patch_complete_matrix == 0, 2));
not_complete_patches = not_complete_patches - 1;