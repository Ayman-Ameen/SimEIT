function [electrodesNodes,perimeter_nodes,electrodesNodesSupport] = electrodes_nodes(resolution,reinforcement_electrodes, shape,coverage_ratio, number_virtual_electrodes , electrodes_number, min_value_to_electrodes)
% ELECTRODES_NODES Generate boundary nodes for electrodes and perimeter.
%   [electrodesNodes, perimeter_nodes, electrodesNodesSupport] = ...
%     ELECTRODES_NODES(resolution, reinforcement_electrodes, shape,
%     coverage_ratio, number_virtual_electrodes, electrodes_number,
%     min_value_to_electrodes) computes arc samples along a unit-circle
%     boundary to represent electrode segments and non-electrode perimeter
%     segments.
%
% Inputs
%   resolution                - Grid resolution used to scale point counts
%   reinforcement_electrodes  - Multiplier for boundary sampling density
%   shape                     - 'unit_circle' supported
%   coverage_ratio            - Fraction of perimeter covered by electrodes
%   number_virtual_electrodes - Virtual electrodes used to size widths
%   electrodes_number         - Actual number of electrodes around boundary
%   min_value_to_electrodes   - Reserved (unused), kept for API compatibility
%
% Outputs
%   electrodesNodes           - Cell array of [x,y] points for each electrode
%   perimeter_nodes           - Cell array of [x,y] points for gaps between electrodes
%   electrodesNodesSupport    - Cell array of [x,y] points spanning each sector
maxium_coverage_ratio = 0.9 ;
if and(coverage_ratio<=0 ,  coverage_ratio>maxium_coverage_ratio)
    error(['Coverage_ratio should be greater than zero and less that', num2str(maxium_coverage_ratio)  ])
end

% reinforcement_elecodes = 50  ; 

switch shape 
    case 'unit_circle'
        shift_electordes = 0.005 ; 
         r = 1 ; r = r + shift_electordes;
        perimeter = 2*pi; perimeter_in_resolution = perimeter * (resolution/2);

        electrodes_width                =  perimeter * coverage_ratio/ number_virtual_electrodes ; 
        number_of_points_electrodes     = ceil((electrodes_width/perimeter) * perimeter_in_resolution * 4 * reinforcement_electrodes) ;
        
        
        electrodes_width_plus_its_space =  perimeter / electrodes_number ; % the circle boundary is 2 * pi 
        electrodes_space_only           =  electrodes_width_plus_its_space-electrodes_width ; 
        number_of_points_perimeter      =  ceil((electrodes_space_only/perimeter) * perimeter_in_resolution*2 * reinforcement_electrodes) ;
        
        for counter = 1:electrodes_number  
            electrodesNodes{counter} = r .*[cos(linspace((counter-1) * electrodes_width_plus_its_space, ( (counter-1) * electrodes_width_plus_its_space + electrodes_width ),number_of_points_electrodes)') ...  x position
                sin(linspace( (counter-1) * electrodes_width_plus_its_space ,  ( (counter-1) * electrodes_width_plus_its_space + electrodes_width ),number_of_points_electrodes )')  ]; % y position
        end
            
        for counter = 1:electrodes_number  
            perimeter_nodes{counter} = r .*[cos(linspace((counter-1) * electrodes_width_plus_its_space + electrodes_width, (counter * electrodes_width_plus_its_space),number_of_points_perimeter)') ...  x position
                sin(linspace( (counter-1) * electrodes_width_plus_its_space + electrodes_width, (counter* electrodes_width_plus_its_space),number_of_points_perimeter )')  ]; % y position
        end 

        perimeter = 2*pi ; perimeter_in_resolution = perimeter * (resolution/2); 
%         electrodes_center_width         =  (1/2) * perimeter * (coverage_ratio)/ number_virtual_electrodes ; 
        electrodes_width_plus_its_space =  perimeter / electrodes_number ; % the circle boundary is 2 * pi 
        number_of_points     =  ceil((electrodes_width_plus_its_space/perimeter) * perimeter_in_resolution*2*reinforcement_electrodes) ;

        
%         r = 1 ; r = (r-min_value_to_electrodes/2);
        r = 1 ; 
%         r = r -shift_electordes;
        for counter = 1:electrodes_number  
            electrodesNodesSupport{counter} = r .* [cos(linspace((counter-1) * electrodes_width_plus_its_space - electrodes_width_plus_its_space/2 , ( (counter) * electrodes_width_plus_its_space - electrodes_width_plus_its_space/2 ),number_of_points)') ...  x position
                sin(linspace((counter-1) * electrodes_width_plus_its_space - electrodes_width_plus_its_space/2 , ( (counter) * electrodes_width_plus_its_space - electrodes_width_plus_its_space/2 ),number_of_points )')  ]; % y position
        end        
        
        
        
        
        
        
        
    otherwise 
        error('Please make it as unit circle then change the electrodes positions, shape and width of elecodes nodes as you prefere')
        
end

end
 