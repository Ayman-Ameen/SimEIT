function testIndices = get_test_indices(dir_dataset)
% GET_TEST_INDICES Retrieves dataset test indices from parameters file
%
% Syntax:
%   testIndices = get_test_indices(dir_dataset)
%
% Input:
%   dir_dataset - Path to the dataset directory containing parameters folder
%
% Output:
%   testIndices - Array of test indices (1-indexed for MATLAB)
%
% Description:
%   This function reads the test.txt file from the parameters subdirectory
%   and converts the indices from Python format (0-indexed) to MATLAB
%   format (1-indexed).
%
% See also: readtable

dir_dataset_parameters = fullfile(dir_dataset, 'parameters');
testFileName = fullfile(dir_dataset_parameters, 'test.txt');
testTable = readtable(testFileName);
testIndices = table2array(testTable);
testIndices = sort(testIndices') + 1;  % Convert from Python (0-indexed) to MATLAB (1-indexed)

end
