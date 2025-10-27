function patch_number = get_patch_number(dir_patch_num, patch_number)
% GET_PATCH_NUMBER Retrieve or initialize patch number from dataset directory
%
% This function manages the patch numbering system for dataset generation.
% If patch_number is provided (not empty), returns it unchanged. Otherwise,
% loads the current patch number from file and increments it, or initializes
% to 0 if the file doesn't exist.
%
% Inputs:
%   dir_patch_num - Directory path where patch_number.mat is stored
%   patch_number  - Existing patch number (if empty, loads from file)
%
% Outputs:
%   patch_number - Current or incremented patch number

if not(isempty(patch_number))
    return 
else
    dir_patch_num = fullfile(dir_patch_num,'patch_number.mat');
    try
        temp = load(dir_patch_num);
        patch_number = temp.patch_number;
        patch_number = patch_number + 1;
        save(dir_patch_num,'patch_number');
        return 
    catch 
        patch_number = 0;
        save(dir_patch_num,'patch_number');
    end 
end

end
    