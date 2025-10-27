function [stim_patterns]= make_simulation_pattern_with_ground(current_amplitude,num_electrodes)
% MAKE_SIMULATION_PATTERN_WITH_GROUND Generate stimulation and measurement patterns
%
% This function creates stimulation and measurement patterns for adjacent
% electrode configuration in Electrical Impedance Tomography (EIT).
%
% Inputs:
%   current_amplitude - Amplitude of stimulation current
%   num_electrodes    - Number of electrodes in the system
%
% Outputs:
%   stim_patterns - Stimulation and measurement pattern structure
%                   Matrix format: [stim+, stim-, meas+, meas-] x N_patterns

Matrix_of_simulation_pattern = zeros(num_electrodes^2,4);

for counter = 1:num_electrodes
    if counter ~= num_electrodes
        first_electode = counter+1;
        secound_electorde = counter;
    else
        first_electode = 1;
        secound_electorde = counter;
    end
    
    for counter2 = 1 : num_electrodes
        first_meas  = secound_electorde;
        second_meas = counter2;
        
        Matrix_of_simulation_pattern((counter-1) * num_electrodes + counter2,:) = [first_electode,secound_electorde,first_meas,second_meas];
    end
end

gain = 1;
stim_patterns = stim_meas_list(Matrix_of_simulation_pattern, num_electrodes, current_amplitude, gain);

end