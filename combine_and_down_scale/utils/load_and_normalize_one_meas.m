% LOAD_AND_NORMALIZE_ONE_MEAS Load and normalize measurement data
%
% Description:
%   This script loads measurement data from a MAT file, displays images,
%   and normalizes measurements using a mask to remove invalid electrode pairs.
%
% Configuration:
%   File_loc - Path to the MAT file containing measurement data
%   number_of_electrodes - Number of electrodes in the system

File_loc = '/disk/Test_super_res/dataset/MAT/32/0_0.mat';
output = load(File_loc).output;

% Display all image samples
max_counter = size(output{1}, 1) - 1;
number_of_electrodes = 32;

for counter = 1:max_counter
    image = squeeze(output{1}(counter, :, :));
    figure;
    imagesc(image);
end

% Create mask for valid measurements
Mask = remove_meas_mask_with_scale(number_of_electrodes);

% Normalize and plot measurements
for counter = 1:max_counter
    meas = squeeze(output{2}(counter, :));
    meas = reshape(meas, number_of_electrodes, number_of_electrodes);
    meas = norm_x(meas(Mask));
    figure;
    plot(meas);
end

function x = norm_x(x)
% NORM_X Normalize data to zero mean and unit standard deviation
%
% Input:
%   x - Input data vector or matrix
%
% Output:
%   x - Normalized data

    x = (x - mean(x(:))) / std(x(:));
end