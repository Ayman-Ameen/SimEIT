function [data,img, v_homogeneous, jacobian, patch_number, dataset_id] = get_patch_init(electrodes_num,resolution,dir_dataset,patch_number,number_of_samples)
% GET_PATCH_INIT Initialize or retrieve patch data for dataset generation
%
% This function initializes a new dataset patch or retrieves an existing one.
% If patch_number is 0, creates a new homogeneous image, calculates jacobian,
% and initializes dataset metadata. Otherwise, loads existing data.
%
% Inputs:
%   electrodes_num    - Number of electrodes in the system
%   resolution        - Resolution of the mesh/image
%   dir_dataset       - Directory path to the dataset
%   patch_number      - Current patch number (0 for new initialization)
%   number_of_samples - Number of samples to generate per patch
%
% Outputs:
%   data           - Dataset table for current patch
%   img            - Homogeneous image model
%   v_homogeneous  - Homogeneous voltage measurements
%   jacobian       - Jacobian matrix for the model
%   patch_number   - Current or incremented patch number
%   dataset_id     - Dataset identification information

dir_dataset_metadata = fullfile(dir_dataset, 'metadata');
dir_dataset_metadata_volt = fullfile(dir_dataset_metadata, 'volt', num2str(electrodes_num));
try
    mkdir(dir_dataset_metadata_volt);
end

patch_number = get_patch_number(dir_dataset_metadata_volt, patch_number);

if patch_number == 0
    [img,v_homogeneous] = generate_homogenous_image(resolution,electrodes_num);
    jacobian = calc_jacobian(img);
    save(fullfile(dir_dataset_metadata_volt,'image_homogenous.mat'),'img','v_homogeneous','jacobian')
else
    image_homogenous = load(fullfile(dir_dataset_metadata_volt,'image_homogenous.mat'),'img','v_homogeneous','jacobian');
    img = image_homogenous.img;
    v_homogeneous = image_homogenous.v_homogeneous;
    jacobian = image_homogenous.jacobian;
end

dataset_id_name = 'dataset_id';
if patch_number == 0
    number_start_after = number_of_samples;
    number_of_features = 7;
    total_number_to_start_after = number_start_after*patch_number;
    
    dataset_id = table(electrodes_num, resolution, number_of_samples, number_start_after, number_of_features,total_number_to_start_after);
    writetable(dataset_id,fullfile(dir_dataset_metadata_volt,dataset_id_name));
    save(fullfile(dir_dataset_metadata_volt,[dataset_id_name,'.mat']),'dataset_id');
else 
    dataset_id = load(fullfile(dir_dataset_metadata_volt,[dataset_id_name,'.mat']));
    dataset_id = dataset_id.dataset_id;
    dataset_id.total_number_to_start_after = dataset_id.number_start_after*patch_number;
end

path_csv_dataset = fullfile(dir_dataset_metadata,'csv_dataset');
try
    mkdir(path_csv_dataset);
end
save_data_name = num2str(patch_number);
try
    data = load(fullfile(path_csv_dataset,[save_data_name,'.mat']));
    data = data.data;
catch
    data = create_csv_dataset(path_csv_dataset,dataset_id.number_of_samples,dataset_id.number_start_after,patch_number,dataset_id.number_of_features,save_data_name);
end

end