function patch_number = read_patch_number(dir_patch_num, patch_number)
% READ_PATCH_NUMBER Reads the patch number from the dataset directory
%
% Inputs:
%   dir_patch_num - Directory containing the patch_number.mat file
%   patch_number  - Existing patch number (if provided, function returns immediately)
%
% Output:
%   patch_number - The patch number from file, or empty if not found

if ~isempty(patch_number)
    return 
end

dir_patch_num = fullfile(dir_patch_num, 'patch_number.mat');
try
    temp = load(dir_patch_num);
    patch_number = temp.patch_number;
catch 
    patch_number = [];
end
    