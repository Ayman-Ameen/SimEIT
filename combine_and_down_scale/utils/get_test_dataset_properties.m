% GET_TEST_DATASET_PROPERTIES Test dataset and determine incomplete patches
%
% Description:
%   This script tests the dataset to identify incomplete patches and
%   combines all data into an HDF5 file.
%
% Configuration Parameters:
%   electrodes_num - Number of electrodes (default: 16)
%   resolution     - Image resolution (default: 256)

clear;
close all;
clc;

electrodes_num = 16;
resolution = 256;

% Change to the function directory
try
    dir_function = mfilename('fullpath');
    [dir_function, ~, ~] = fileparts(dir_function);
    cd(dir_function);
catch
    % If mfilename fails, use current directory
end

home_function = pwd;
addpath(home_function);

[home, ~, ~] = fileparts(home_function);
[dir_dataset, ~, ~] = fileparts(home);
dir_dataset = [dir_dataset, '/dataset/'];

functions_folders = {'plots', 'generate_functions', 'data_functions', 'combine_and_down_scale'};

for counter_functions_folders = 1:length(functions_folders)
    addpath([home, '/', functions_folders{counter_functions_folders}]);
end

%% Load patch data
patch_number = 21;
do_dataset_statistics = 0;
local_patch_size = 100;

[data, img, v_homogeneous, patch_number, dataset_id] = get_patch_details(electrodes_num, resolution, dir_dataset, patch_number, do_dataset_statistics);

%% Getting test parameters
[dataset_home_dir, ~, ~] = fileparts(home);
filename_mode = 'test.txt';
filepath_mode = [dataset_home_dir, '/', 'dataset/parameters/', filename_mode];
mode_indices = importdata(filepath_mode);
mode_indices = mode_indices + 1; % MATLAB indexing starts at 1, Python starts at 0
sorted_mode_indices = sort(mode_indices);

number_of_objects.values = data.number_of_objects(sorted_mode_indices, :);
coverage_area.values = data.coverage_area(sorted_mode_indices, :);
conductivity.values = data.conductivity(sorted_mode_indices, :);
type.values = data.type(sorted_mode_indices, :);
features.values = data.features(sorted_mode_indices, :);
index.values = data.index1(sorted_mode_indices, :);

%% Data analysis
[coverage_area.sorted, coverage_area.index_sorted] = sort(coverage_area.values);
mode_data = table((1:length(index.values))', number_of_objects.values, coverage_area.values, type.values, features.values, conductivity.values, 'VariableNames', {'index', 'numberOfObjects', 'coverageArea', 'type', 'features', 'conductivity'});