function [v_homo,img_elements,v_diff,image,image_electric_volt] = forward_solver_for_one_sample(jacobian,img,elem_data_all,single_image,method,background_conductivity)
% FORWARD_SOLVER_FOR_ONE_SAMPLE Compute EIT forward response for one sample.
%   [v_homo, img_elements, v_diff, image, image_electric_volt] = ...
%     FORWARD_SOLVER_FOR_ONE_SAMPLE(jacobian, img, elem_data_all,
%     single_image, method, background_conductivity) computes the
%     homogeneous and target measurements and their difference either via
%     a Jacobian-based linearization or the full forward solver.
%
% Inputs
%   jacobian               - System Jacobian (used when method.name == 'jacobian')
%   img                    - EIDORS image struct (contains fwd_model)
%   elem_data_all          - Element-wise conductivity deltas
%   single_image           - Image grid of conductivity deltas
%   method                 - Struct with fields: name, reverse_simulation_pattern,
%                            get_volt_nodes
%   background_conductivity- Background conductivity scalar
%
% Outputs
%   v_homo                 - Homogeneous measurements (vector)
%   img_elements           - Element-wise conductivities for target image
%   v_diff                 - Difference measurements (target - homo)
%   image                  - Background + single_image
%   image_electric_volt    - 4D (mode x stim x Ny x Nx) voltage images, or 'N/A'
%                            when not requested. Voltage images require nodes, X, Y
%                            to be available in scope when method.get_volt_nodes == 1.

% Solve for homogeneous image 
if strcmp(  method.name, 'jacobian' ) 
    
    sign_pattern = method.reverse_simulation_pattern ; 

    v_homo       = sign_pattern *  jacobian *  (background_conductivity * ones(size(elem_data_all)));
    img_elements = background_conductivity + elem_data_all;
    v_diff       = sign_pattern * (jacobian * img_elements) - v_homo ;
    image        = single_image + background_conductivity;
    image_electric_volt = 'N/A';

else

    img.elem_data      = background_conductivity * ones(size(elem_data_all));
    v_homogeneous      = fwd_solve(img);

    % image with objects 
    img.elem_data = background_conductivity + elem_data_all;
    v_traget     = fwd_solve(img);
    single_image = single_image + background_conductivity ;

    v_diff    = (v_traget.meas-v_homogeneous.meas) ;  
    image     =  single_image ; 
    v_homo    = v_homogeneous.meas;
    img_elements = img.elem_data(:);
    
    
    % get voltage nodes if requested
    image_electric_volt = [];
    if method.get_volt_nodes == 1 
        for counter_image_volt = 1 :  size(v_homogeneous.volt,2)
            % 1 -> target ; 2 -> diff ; 3 -> homo ;  
            image_electric_volt(1,counter_image_volt,:,:) = griddata(nodes(:,1),nodes(:,2),v_traget.volt(:,counter_image_volt),X,Y);
            image_electric_volt(2,counter_image_volt,:,:) = griddata(nodes(:,1),nodes(:,2),v_traget.volt(:,counter_image_volt)-v_homogeneous.volt(:,counter_image_volt),X,Y);
            image_electric_volt(3,counter_image_volt,:,:) = griddata(nodes(:,1),nodes(:,2),v_homogeneous.volt(:,counter_image_volt),X,Y);
        end
    else
           image_electric_volt = 'N/A';

    end

end