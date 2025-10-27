function [image, v_diff, img_elements, v_homo, electrodes_contact_resistance]= generate_patch(data, img, jacobian, number_of_features, v_homogeneous, resolution, mode, method)
% GENERATE_PATCH Generate synthetic/experimental patches and forward data.
%   [image, v_diff, img_elements, v_homo, electrodes_contact_resistance] =
%     GENERATE_PATCH(data, img, jacobian, number_of_features,
%     v_homogeneous, resolution, mode, method) constructs per-sample
%     element conductivity maps from object descriptors or experimental
%     masks, solves forward responses, and returns image grids and
%     measurement vectors.
%
% Inputs
%   data               - Structure or array holding features/masks
%   img                - EIDORS image struct with fwd_model
%   jacobian           - System Jacobian (for linear method)
%   number_of_features - Features per object descriptor (synthetic mode)
%   v_homogeneous      - Homogeneous forward solution struct
%   resolution         - Output image resolution (Ny == Nx)
%   mode               - 'synthetic' or 'experimental'
%   method             - Struct controlling solver mode and options
%
% Outputs
%   image                      - [N x res x res] grid images per sample
%   v_diff                     - [N x M] differential measurements
%   img_elements               - [N x Ne] element conductivities
%   v_homo                     - [N x M] homogeneous measurements
%   electrodes_contact_resistance - Per-sample contact resistances or []

length_of_meas = length(v_homogeneous.meas); 
electrodes_num = length(img.fwd_model.electrode);
length_of_elements = length(img.fwd_model.elems);
[electrodes_contact_resistance, patch_size] = get_electrodes_resistance(data, length_of_meas, electrodes_num, mode, method);
img_elements = zeros(patch_size, length(img.elem_data));


image   = zeros(patch_size, resolution, resolution);
v_diff  = zeros(patch_size, length(v_homogeneous.meas));
v_homo  = zeros(patch_size, length(v_homogeneous.meas));

% first create the grid
x = linspace(-1,1,resolution)   ; x_space = x(2) - x(1) ;
y = linspace(-1,1,resolution)   ; y_space = y(2) - y(1) ;

[X,Y]    = meshgrid(x,y)        ; 

% after that, get the model parameters 
nodes       = img.fwd_model.nodes          ; 
round_value = 14 ; 
nodes_round = round(nodes,round_value)     ; 
elements    = img.fwd_model.elems          ;

background_conductivity = 1;
experimental_conductivity = 10^-6;
experimental_bias_contact_resistance = 0.01;

parfor counter = 1 : patch_size
 

% Calculate element membership in object
elem_data_all   = zeros(length_of_elements, 1);
binary_mask_all = false(size(X)); 
single_image    = zeros(size(X)); 

for counter2 = 1 : data.number_of_objects(counter)
    
    if strcmp(mode,'experimental')
    binary_mask = logical(squeeze(data.images(counter, 2, :, :)));
    binary_mask = logical(imrotate(binary_mask, method.rotation_angle, 'bilinear', 'crop'));
    else
    
    object_str = object2str(data.features(counter, number_of_features*(counter2-1)+1:number_of_features*counter2-1), data.features(counter, counter2.*number_of_features), data.type{counter, counter2}, '2d');
    select_fcn = inline(object_str, 'x', 'y', 'z');

        % get the binary values of the object and avoid intersections
    binary_mask = select_fcn(X, Y, []); 
    binary_mask = and(binary_mask, not(binary_mask_all)); 
    binary_mask_all = or(binary_mask_all, binary_mask);  
    end

    elem_data = select_grid_elements(elements, X, Y, x_space, y_space, binary_mask, round_value, nodes_round); 
    
if strcmp(mode,'experimental')
    elem_data = elem_data * (experimental_conductivity - background_conductivity);
    single_image = single_image + double(binary_mask) * (experimental_conductivity - background_conductivity);
    elem_data_all = elem_data_all + elem_data;
else
    elem_data = elem_data * (data.conductivity(counter, counter2) - background_conductivity);
    single_image = single_image + double(binary_mask) * (data.conductivity(counter, counter2) - background_conductivity);
    elem_data_all = elem_data_all + elem_data;
end
end
[v_homo(counter, :), img_elements(counter, :), v_diff(counter, :), image(counter, :, :), image_electric_volt{counter}] = forward_solver_for_one_sample(jacobian, img, elem_data_all, single_image, method, background_conductivity);
disp(counter)

end
end    