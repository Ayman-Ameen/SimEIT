%%%%%%%%%%%%%%%%%%%%% Initialization %%%%%%%%%%%%%%%%
clear;     % clear workspace 
% close all; % close all figures 
warning('off');  

%%%%%%%%%%%%%% Load Configuration %%%%%%%%%%%%%%% 
% Load configuration from config.yaml
try 
    dir_function = mfilename('fullpath'); 
    [dir_function, ~, ~] = fileparts(dir_function); 
    cd(dir_function); 
catch
    % If mfilename is unavailable (e.g., deployed), stay in current directory
end

home = pwd; 
addpath(home);
functions_folders = {'plots', 'generate_functions', 'data_functions', 'experiemental'};

for counter_functions_folders = 1 : length(functions_folders)
    addpath(home, '/', functions_folders{counter_functions_folders});
end

run([home, '/', 'eidors', '/', 'startup.m'])

[dir_dataset, ~, ~] = fileparts(home);   
dir_dataset = [dir_dataset, '/dataset/']; 
mkdir(dir_dataset);

% Load configuration
config = load_config(fullfile(home, 'config.yaml'));
description = config.general.description;

% rmdir(dir_dataset,'s'); % this only for test
%%%%%%%%%%%%% Initialization %%%%%%%%%%%
mode = config.general.mode;  % Options: 'experimental', 'simulation_test', 'simulation'
method.name = config.solver.method_name;   
method.reverse_simulation_pattern = config.solver.reverse_simulation_pattern; 
method.rotation_angle = config.solver.rotation_angle; 
method.get_electrodes_resistance = config.solver.get_electrodes_resistance; 
method.get_volt_nodes = config.solver.get_volt_nodes; 

electrodes_num = config.model.electrodes_num;
resolution     = config.model.resolution;

% Mode-specific settings
if strcmp(mode, 'simulation')
    number_of_samples  = config.dataset.number_of_samples; 
    local_patch_size   = config.dataset.local_patch_size; 
    patch_number       = config.dataset.patch_number;
end

if strcmp(mode, 'simulation_test')
    number_of_samples  = 10; 
    local_patch_size   = 5; 
    patch_number       = [];
end

if strcmp(mode, 'experimental')
    number_of_samples  = 10; 
    local_patch_size   = 10; 
    patch_number       = 0;
end

[data, img, v_homogeneous, jacobian, patch_number, dataset_id] = get_patch_init(electrodes_num, resolution, dir_dataset, patch_number, number_of_samples);  
dir_dataset_saveMat = [dir_dataset, '/MAT/', num2str(electrodes_num), '/']; 
mkdir(dir_dataset_saveMat);

%%%%%%%%%% Experimental %%%%%%%%%%
if strcmp(mode, 'experimental') 
    folder_experimental = config.experimental.folder_experimental; 
    list_of_data = config.experimental.list_of_data; 
    clear data; % Please put the data in pairs [without objects, with objects]
    [data.measurements, data.images] = get_experimental_data(folder_experimental, resolution, electrodes_num, list_of_data);      
    data.number_of_objects = ones(1, length(list_of_data)/2);   
    [output{1}, output{2}, output{3}, output{4}, output{5}] = generate_patch(data, img, jacobian, dataset_id.number_of_features, v_homogeneous, resolution, mode, method);
    
    %% simulation and measurement 
    counter = 1;
    meas_diff = (squeeze(data.measurements(counter, 1, :))' - squeeze(data.measurements(counter, 2, :))');
    angle_rotation_finder(meas_diff, data, img, jacobian, dataset_id.number_of_features, v_homogeneous, resolution, mode, method)
    diff_sim_meas_homo = plot_sim_exp(squeeze(output{4}), squeeze(data.measurements(counter, 1, :))', 'sim-homo', 'meas-homo');
    diff_sim_meas_diff = plot_sim_exp(squeeze(output{2}), meas_diff, 'sim-diff', 'meas-diff');
end

%%%%%%%%%% Simulation %%%%%%%%%%
if or(strcmp(mode, 'simulation_test'), strcmp(mode, 'simulation'))
    % Configurable parameters from config file
    % [16,  32,  64,  128  ]; 
    % [128, 256, 512, 1024 ];

    % create the dataset 
    counter_local_patch = 0; 
    if rem(size(data, 1), local_patch_size) ~= 0
        error('patch size should be multiple of dataset');
    end
    
    for counter_patch = 1 : local_patch_size : size(data, 1)
        [output{1}, output{2}, output{3}, output{4}, output{5}] = generate_patch(data(counter_patch:(counter_patch+local_patch_size-1), :), img, jacobian, dataset_id.number_of_features, v_homogeneous, resolution, mode, method);

        %%% save data %%%
        save([dir_dataset_saveMat, num2str(patch_number), '_', num2str(counter_local_patch)], 'output'); 
        counter_local_patch = counter_local_patch + 1;
        disp('*******************************'); 
        disp(counter_patch); 
        disp('*******************************'); 
    end
end