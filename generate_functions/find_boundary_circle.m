function [boundary] = find_boundary_circle(boundary_nodes,nodes,elements)
% FIND_BOUNDARY_CIRCLE Compute boundary edges for a circular mesh.
%   boundary = FIND_BOUNDARY_CIRCLE(boundary_nodes, nodes, elements)
%   returns the list of element-edge node indices that lie entirely on the
%   provided boundary_nodes set.
%
% Inputs
%   boundary_nodes - [Kx2] coordinates of points on the circle boundary
%   nodes          - [Nx2] mesh node coordinates
%   elements       - [Mx3] triangular elements as node indices
%
% Output
%   boundary       - [Bx2] sorted node index pairs forming boundary edges

% find the boundary node index in nodes  
boundary_node_index = zeros(length(boundary_nodes),1);
for counter = 1:length(boundary_nodes)
     boundary_node_index(counter) = find(and(nodes(:,1)==boundary_nodes(counter,1),nodes(:,2)==boundary_nodes(counter,2))); 
end 


% get every edge in every simplex 
% every simplex is a-b-c 
% the edges is a-b, b-c, c-a
edge_between_two_nodes  = zeros(3*length(elements),2) ;
edge_between_two_nodes(1:length(elements),:)                      = elements(:,1:2);
edge_between_two_nodes(length(elements)+1:2*length(elements),:)   = elements(:,2:3);
edge_between_two_nodes(2*length(elements)+1:3*length(elements),:) = elements(:,[3,1]);

% find all elements that contains these the boundary nodes
boundary=[];
counter_index = 1 ; 
for counter = 1:length(edge_between_two_nodes)
    if and(any(edge_between_two_nodes(counter,1)==boundary_node_index(:)),any(edge_between_two_nodes(counter,2)==boundary_node_index(:)))
      boundary(counter_index,:) = edge_between_two_nodes(counter,:);
      counter_index = counter_index+1;
    end
    
end 

boundary = sort(boundary,2)     ; % sort each pair
boundary = sortrows(boundary,1) ; % sort by first node index



end