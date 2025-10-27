function [data,img, v_homogeneous, patch_number, dataset_id] = get_patch_details(electrodes_num,resolution,dir_dataset,patch_number,do_dataset_statistics)
% GET_PATCH_DETAILS Retrieve patch details from existing dataset
%
% This function reads the patch number if it exists and loads the associated
% metadata including homogeneous image, voltage data, and dataset information.
%
% Inputs:
%   electrodes_num          - Number of electrodes in the system
%   resolution              - Resolution of the mesh/image
%   dir_dataset             - Directory path to the dataset
%   patch_number            - Patch number to load (if empty, reads from file)
%   do_dataset_statistics   - Flag to compute dataset statistics
%
% Outputs:
%   data           - Combined dataset from all patches
%   img            - Homogeneous image model
%   v_homogeneous  - Homogeneous voltage measurements
%   patch_number   - Current patch number
%   dataset_id     - Dataset identification information

dir_dataset_metadata = fullfile(dir_dataset, 'metadata');
dir_dataset_metadata_volt = fullfile(dir_dataset_metadata, 'volt', num2str(electrodes_num));
try
    mkdir(dir_dataset_metadata_volt);
end

patch_number = read_patch_number(dir_dataset_metadata_volt, patch_number);

if isempty(patch_number)
    error('Please, run the dataset first')
else
    image_homogenous = load(fullfile(dir_dataset_metadata_volt,'image_homogenous.mat'),'img','v_homogeneous');
    img = image_homogenous.img;
    v_homogeneous = image_homogenous.v_homogeneous;
end

dataset_id_name = 'dataset_id';
if isempty(patch_number)
    error('Please, run the dataset first')
else 
    dataset_id = load(fullfile(dir_dataset_metadata_volt,[dataset_id_name,'.mat']));
    dataset_id = dataset_id.dataset_id;
    dataset_id.total_number_to_start_after = dataset_id.number_start_after*patch_number;
end

path_csv_dataset = fullfile(dir_dataset_metadata,'csv_dataset');
try
    mkdir(path_csv_dataset);
end

for counter = 0:1:patch_number
    save_data_name = num2str(counter);
    data_temp = load(fullfile(path_csv_dataset,[save_data_name,'.mat'])); 
    if counter == 0
        data = data_temp.data;
    else
        data = [data;data_temp.data];
    end
end

if do_dataset_statistics 
    dataset_statistics(data,dir_dataset_metadata);
end

end