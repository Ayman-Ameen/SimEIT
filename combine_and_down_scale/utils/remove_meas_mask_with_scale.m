function Mask = remove_meas_mask_with_scale(number_of_electrodes)
% REMOVE_MEAS_MASK_WITH_SCALE Creates a mask for electrode measurements
%
% Syntax:
%   Mask = remove_meas_mask_with_scale(number_of_electrodes)
%
% Input:
%   number_of_electrodes - Number of electrodes in the system
%
% Output:
%   Mask - Logical matrix mask for valid measurements
%
% Description:
%   Creates a mask that removes measurements from adjacent electrodes.
%   The mask removes 3 measurements around each electrode position.

    number_of_remove_meas = 3;
    offset_for_the_first = 1;
    
    Mask = zeros(number_of_electrodes, number_of_electrodes);
    
    for counter = 1:number_of_electrodes
        if counter <= offset_for_the_first
            Mask(counter, 1:number_of_remove_meas - offset_for_the_first) = 1;
            Mask(counter, number_of_electrodes - offset_for_the_first + 1:number_of_electrodes) = 1;
        elseif number_of_electrodes - offset_for_the_first < counter
            Mask(counter, 1:number_of_electrodes - counter + number_of_remove_meas - offset_for_the_first - 1) = 1;
            Mask(counter, counter - offset_for_the_first:number_of_electrodes) = 1;
        else
            Mask(counter, counter - offset_for_the_first:counter + number_of_remove_meas - offset_for_the_first - 1) = 1;
        end
    end
    
    Mask = not(logical(Mask));
end