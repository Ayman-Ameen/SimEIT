function [electrodes_contact_resistance, patch_size] = get_electrodes_resistance(data, length_of_meas, electrodes_num, mode, method)
% GET_ELECTRODES_RESISTANCE Calculate electrode contact resistance values
%
% Inputs:
%   data          - Dataset containing images or measurements
%   length_of_meas - Length of measurement vector
%   electrodes_num - Number of electrodes
%   mode          - 'experimental' or 'simulation' mode
%   method        - Structure with get_electrodes_resistance flag
%
% Outputs:
%   electrodes_contact_resistance - Matrix of resistance values or empty
%   patch_size                    - Size of the patch dataset

if strcmp(mode,'experimental')
    patch_size = size(data.images,1);
    
    if method.get_electrodes_resistance == 0
        electrodes_contact_resistance = [];
    else
        electrodes_contact_resistance = zeros(patch_size,length_of_meas);
    end
else
    patch_size = size(data,1);
    
    if method.get_electrodes_resistance == 0 
        electrodes_contact_resistance = [];
    else
        maximum_variation = 0.5;
        maximum_conductivity = 0.1;
        minimum_conductivity = 0.001;
        electrodes_contact_resistance = get_random_values_within_range(patch_size, electrodes_num, maximum_conductivity, minimum_conductivity, maximum_variation);
    end
end

end