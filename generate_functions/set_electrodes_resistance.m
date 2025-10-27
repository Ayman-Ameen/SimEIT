function img = set_electrodes_resistance(img, method, counter, experimental_bias_contact_resistance, data)
% SET_ELECTRODES_RESISTANCE Sets the contact resistance for electrodes
%
% Inputs:
%   img                                  - Image structure containing forward model
%   method                               - Structure with method parameters
%   counter                              - Current iteration counter
%   experimental_bias_contact_resistance - Bias for experimental contact resistance
%   data                                 - Data structure containing measurements
%
% Output:
%   img - Updated image structure with modified electrode contact resistance

if method.get_electrodes_resistance == 1
    if strcmp(mode, 'experimental')
        for counter_contact = 1:length(img.fwd_model.electrode)
            img.fwd_model.electrode(counter_contact).z_contact = ...
                experimental_bias_contact_resistance .* data.measurements.contact_resistance(counter, counter_contact);
        end
    else
        for counter_contact = 1:length(img.fwd_model.electrode)
            img.fwd_model.electrode(counter_contact).z_contact = ...
                electrodes_contact_resistance(counter, counter_contact);
        end
    end
end