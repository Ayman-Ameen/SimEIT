function model_fwd= create_model( resolution, dimension, z_contact, scale, shape_function, coverage_ratio, number_virtual_electrodes, electrodes_number,reinforcement_electrodes)
% CREATE_MODEL Build a 2D circular EIT forward model.
%   model_fwd = CREATE_MODEL(resolution, dimension, z_contact, scale,
%     shape_function, coverage_ratio, number_virtual_electrodes,
%     electrodes_number, reinforcement_electrodes) constructs an EIDORS
%     forward model for a unit circle domain (scaled by "scale") with the
%     requested electrode layout and contact impedance.
%
% Inputs
%   resolution                - Number of grid points along x/y for node generation
%   dimension                 - '2d' (currently supported)
%   z_contact                 - Contact impedance (Ohm)
%   scale                     - [sx, sy, sz] geometric scaling factors
%   shape_function            - 'unit_circle' or a function handle @(x,y)mask
%   coverage_ratio            - Electrode coverage ratio of the perimeter (0..0.9)
%   number_virtual_electrodes - Virtual electrode count used to define widths
%   electrodes_number         - Actual number of electrodes on the boundary
%   reinforcement_electrodes  - Refinement factor for boundary point density
%
% Output
%   model_fwd                 - EIDORS forward model struct

    % scale x, y, z
    scale_x =  scale(1) ; 
        scale_y =  scale(2) ; 
    
    % unit circle 
	x = linspace(-1,1,resolution) * scale_x  ;
    y = linspace(-1,1,resolution) * scale_y  ;
    switch dimension 
        case '2d'
           [X,Y] = meshgrid(x,y); 
               switch shape_function
                    case 'unit_circle'
                        select_function = @(x,y) ((x).^2+(y).^2<=(1)^2);
                    otherwise 
                        select_function = shape_function ;
               end 
               
               model    = select_function(X,Y);  
               
               % nodes 
               nodes_x  = X(model) ;
               nodes_y  = Y(model) ;
               nodes    = [nodes_x, nodes_y] ;
               
               % remove duplicated nodes 
               nodes = unique(nodes, 'rows');
               
             [electrodesNodes,perimeter_nodes] = electrodes_nodes(resolution, reinforcement_electrodes, shape_function, coverage_ratio,number_virtual_electrodes , electrodes_number);


                model_fwd= mk_fmdl_from_nodes( nodes, electrodesNodes, perimeter_nodes, z_contact, 'Create_model');
               
         
        otherwise 
            error('Coming Soon')
    end
     

end