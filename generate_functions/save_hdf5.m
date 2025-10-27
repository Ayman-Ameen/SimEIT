function save_hdf5(filename, field_names, dataset_current, output, ChunkSize, counter_patch, dir_dataset)
% SAVE_HDF5 Saves data to HDF5 dataset
%
% Inputs:
%   filename        - HDF5 file path
%   field_names     - Cell array of field names to save
%   dataset_current - Current dataset path within HDF5 structure
%   output          - Cell array containing data to save
%   ChunkSize       - Chunk size for HDF5 dataset creation
%   counter_patch   - Current patch counter for indexing
%   dir_dataset     - Dataset directory path

for counterField = 1:length(field_names)
    
    if isa(output{counterField}, 'struct') || iscell(output{counterField})
        dataset_current_var = [dir_dataset, dataset_current];
        mkdir(dataset_current_var);
        var = output{counterField};
        dataset_current_var = [dir_dataset, dataset_current, field_names{counterField}];
        save([dataset_current_var, '.mat'], 'var')
        
    elseif isfloat(output{counterField})
        dataset_current_var = [dataset_current, field_names{counterField}];
        sizeVar = size(output{counterField});
        try
            h5create(filename, dataset_current_var, [inf, sizeVar(2:end)], ...
                'Datatype', 'double', 'ChunkSize', [ChunkSize, sizeVar(2:end)]);
        catch
        end
        h5write(filename, dataset_current_var, output{counterField}, ...
            [double(counter_patch), ones(1, length(sizeVar)-1)], sizeVar);
    else
        error('The data type is not recognized');
    end
end