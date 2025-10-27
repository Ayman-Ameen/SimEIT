function [index_shapes] = not_intersect(cnf_matrix, number_of_objects)
% NOT_INTERSECT Find shapes that do not intersect
%
% Syntax:
%   index_shapes = not_intersect(cnf_matrix, number_of_objects)
%
% Description:
%   Searches for shapes that do not intersect by analyzing a confusion matrix.
%
% Inputs:
%   cnf_matrix       - Confusion matrix indicating shape intersections
%   number_of_objects - Number of non-intersecting objects to find
%
% Outputs:
%   index_shapes - Indices of shapes that do not intersect

index_shapes = [];

for k = 1:length(cnf_matrix) 
    if number_of_objects == 0
        break
    end 
    
    cnf_matrix_new = cnf_matrix(cnf_matrix(k,:)==1, cnf_matrix(k,:)==1); 
    if ~(sum(reshape(cnf_matrix_new, [], 1)) == 0)
        index_shapes_new = not_intersect(cnf_matrix_new, number_of_objects-1);    
        indexing_of_cnf_matrix = find(cnf_matrix(k,:)==1); 
        index_shape_new = indexing_of_cnf_matrix(index_shapes_new); 
        index_shapes = [k, index_shape_new];
        
        if (length(index_shapes) >= number_of_objects) 
            break
        end
    end
end

end