function [img,v_homogeneous]= generate_homogenous_image(resolution,electrodes_num)
% GENERATE_HOMOGENOUS_IMAGE Create a homogeneous EIT image and solve v_homo.
%   [img, v_homogeneous] = GENERATE_HOMOGENOUS_IMAGE(resolution, electrodes_num)
%   builds a circular forward model with the given number of electrodes and
%   returns the EIDORS image struct and its homogeneous forward solution.
%
% Inputs
%   resolution     - Grid resolution used to build the model
%   electrodes_num - Number of boundary electrodes
%
% Outputs
%   img            - EIDORS image struct with stimulation set
%   v_homogeneous  - Result of fwd_solve(img)

 scale = [1,1,1];    z_contact = 0.01; dimension = '2d'; shape_function = 'unit_circle'; effective_area = 0.1963 ; coverage_ratio = 0.21952*effective_area  ; number_virtual_electrodes = 16  ; reinforcement_elecodes = 2 ; 

 model_fwd = create_model( resolution, dimension, z_contact, scale, shape_function, coverage_ratio, number_virtual_electrodes, electrodes_num, reinforcement_elecodes); 
img = mk_image(model_fwd,1);

current_amplitude      = 0.001 ; %A 
img.fwd_model.stimulation = make_simulation_pattern_with_ground(current_amplitude,electrodes_num);

img.fwd_solve.get_all_meas = 1;

% forward solver
v_homogeneous  = fwd_solve(img);

end