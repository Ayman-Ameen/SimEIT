function elem_data = select_grid_elements(elements, X, Y, x_space, y_space, binary_mask, round_value, nodes_round)
% SELECT_GRID_ELEMENTS Selects elements based on a binary mask
%
% Inputs:
%   elements     - Array of element definitions
%   X            - X-coordinates grid
%   Y            - Y-coordinates grid
%   x_space      - Spacing in X direction
%   y_space      - Spacing in Y direction
%   binary_mask  - Binary mask for element selection
%   round_value  - Number of decimal places for rounding
%   nodes_round  - Rounded node coordinates
%
% Output:
%   elem_data - Binary array indicating selected elements

X_values = X(binary_mask);
Y_values = Y(binary_mask);

X_values_square_around_node = [X_values, X_values, X_values+x_space, X_values+x_space];
X_values_square_around_node = round(X_values_square_around_node, round_value);
Y_values_square_around_node = [Y_values, Y_values+y_space, Y_values, Y_values+y_space];
Y_values_square_around_node = round(Y_values_square_around_node, round_value);

nodes_index = zeros(size(X_values_square_around_node));
for counter_nodes_index = 1:length(nodes_index)
    try
        nodes_index(counter_nodes_index, 1) = find(nodes_round(:,1) == X_values_square_around_node(counter_nodes_index, 1) & ...
                                                    nodes_round(:,2) == Y_values_square_around_node(counter_nodes_index, 1));
    catch
    end
    try
        nodes_index(counter_nodes_index, 2) = find(nodes_round(:,1) == X_values_square_around_node(counter_nodes_index, 2) & ...
                                                    nodes_round(:,2) == Y_values_square_around_node(counter_nodes_index, 2));
    catch
    end
    try
        nodes_index(counter_nodes_index, 3) = find(nodes_round(:,1) == X_values_square_around_node(counter_nodes_index, 3) & ...
                                                    nodes_round(:,2) == Y_values_square_around_node(counter_nodes_index, 3));
    catch
    end
    try
        nodes_index(counter_nodes_index, 4) = find(nodes_round(:,1) == X_values_square_around_node(counter_nodes_index, 4) & ...
                                                    nodes_round(:,2) == Y_values_square_around_node(counter_nodes_index, 4));
    catch
    end
end

elem_data = zeros(size(elements, 1), 1);

for counter_nodes_index = 1:length(nodes_index)
    elements_logic = zeros(size(elem_data));
    for counter_node_number = 1:size(nodes_index, 2)
        elements_logic = elements_logic + double((elements(:,1) == nodes_index(counter_nodes_index, counter_node_number)) | ...
                                                  (elements(:,2) == nodes_index(counter_nodes_index, counter_node_number)) | ...
                                                  (elements(:,3) == nodes_index(counter_nodes_index, counter_node_number)));
    end
    
    elem_data(elements_logic >= 3) = 1;
end