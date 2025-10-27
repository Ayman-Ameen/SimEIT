function [data] = create_csv_dataset(dir_dataset, number_of_samples, number_start_after, patch_number, number_of_features, save_data_name)
%CREATE_CSV_DATASET Generate randomized shape metadata and write CSV/MAT files.
%   data = CREATE_CSV_DATASET(dir_dataset, number_of_samples, number_start_after, ...
%       patch_number, number_of_features, save_data_name)
%
%   Inputs:
%     dir_dataset         - Directory path where outputs will be saved.
%     number_of_samples   - Number of samples (rows) to generate.
%     number_start_after  - Index offset multiplied by patch_number.
%     patch_number        - Seed (for RNG) and index multiplier (batch id).
%     number_of_features  - Number of features per object.
%     save_data_name      - Base filename (without extension) for outputs.
%
%   Output:
%     data - Table with columns: index1, number_of_objects, type, conductivity,
%            features, coverage_area.
%
%   Notes:
%     - All shapes' centers must lie inside the unit circle.
%     - Conductivities are sampled log-uniformly per sample with limited variation.

warning('off')
dimension = '2d';

rng(patch_number)

 max_number_of_objects = 4;

index1 = (1:number_of_samples)' + (patch_number * number_start_after);

type_all_init = {'circle', 'ellipse', 'rectangle', 'triangle'};

number_of_objects = randi([1, max_number_of_objects], [number_of_samples, 1]);

%%%%%%%%%%%%%%% Conductivity %%%%%%%%%%%%%%%%%%
% Conductivity sampled log-uniformly per sample (same base range per sample)
% with limited per-object variation around the sample's base value.
maximum_variation = 0.5;
maximum_conductivity = 10^6; log_maximum_conductivity = log10(maximum_conductivity) / (maximum_variation * 3);
minimum_conductivity = 10^-7; log_minimum_conductivity = log10(minimum_conductivity) / (maximum_variation * 3);
conductivity_log_one_sample = log_minimum_conductivity + ((log_maximum_conductivity - log_minimum_conductivity) * rand([number_of_samples, 1]));
conductivity_log_one_sample = repmat(conductivity_log_one_sample, 1, max_number_of_objects);
conductivity_log = conductivity_log_one_sample + ((conductivity_log_one_sample - maximum_variation * conductivity_log_one_sample) .* rand([number_of_samples, max_number_of_objects]));
conductivity = 10.^(conductivity_log);

type          = type_all_init((randi([1, length(type_all_init)], [number_of_samples, max_number_of_objects])));
features      = zeros(number_of_samples, number_of_features * max_number_of_objects);
time_cell     = cell(number_of_samples,1);
coverage_area = zeros(number_of_samples,1);

parfor counter = 1 : number_of_samples

    t1 = clock;

    features_once = zeros(1, number_of_objects(counter) * number_of_features);
    type_once     = type_all_init((randi([1, length(type_all_init)], [1, max_number_of_objects])));

    [features_once, type_once, coverage_area(counter)] = features_parameters( ...
        number_of_objects(counter), type_once, features_once, dimension, ...
        number_of_features, dir_dataset, index1(counter), conductivity(counter, :));

    features_once = [features_once, zeros(1, (max_number_of_objects - number_of_objects(counter)) * number_of_features)];
    features(counter, :) = features_once;

    for k = (length(type_once) + 1) : max_number_of_objects; type_once{k} = ''; end
    type(counter, :) = type_once;

    t2 = clock;
    time_cell{counter} = t2 - t1;
    disp(counter / number_of_samples * 100)
end

 
format long
data = table(index1,number_of_objects,type,conductivity,features,coverage_area);
writetable(data,fullfile(dir_dataset,[save_data_name,'.csv']));
save(fullfile(dir_dataset,[save_data_name,'.mat']), 'data');
time = time_cell; %#ok<NASGU> % saved below
save(fullfile(dir_dataset,[save_data_name,'time.mat']), 'time')
end