function output = load_hdf5(filename, field_names, dataset_current, typeOutput, dir_dataset, start)
% LOAD_HDF5 Load fields from MAT or HDF5 datasets.
%
% Inputs:
%   filename         - Full path to the HDF5 file (used when typeOutput='float').
%   field_names      - Cell array of field names to load.
%   dataset_current  - Base dataset path/prefix. For HDF5, this is the group
%                      path; for MAT, it's the relative path under dir_dataset.
%   typeOutput       - 'mat' to load from .mat files, 'float' to load from HDF5.
%   dir_dataset      - Base directory for MAT files (used when typeOutput='mat').
%   start            - Optional starting index for reading along the first
%                      dimension in HDF5 ([] to read all).
%
% Output:
%   output           - 1-by-N cell array with loaded variables per field name.

   output = cell(1, length(field_names));
   for counterField = 1:length(field_names)
       switch typeOutput
           case 'mat'
                dataset_current_var = [dir_dataset, dataset_current, field_names{counterField}];
                var = load([dataset_current_var, '.mat']);
                output{counterField} = var(:);
           case 'float'
                dataset_current_var = [dataset_current, field_names{counterField}];
                if ~isempty(start)
                    info_of_h5 = h5info(filename, [dataset_current, field_names{counterField}]);
                    size_of_dataset = info_of_h5.Dataspace.Size;
                    output{counterField} = h5read(filename, dataset_current_var, [start, ones(1, length(size_of_dataset)-1)], [1, size_of_dataset(2:end)]);
                else
                    output{counterField} = h5read(filename, dataset_current_var);
                end
           otherwise
               error('The data type is not recognized');
       end
   end
end