function [inverse_model, metadata] = get_solver(name, resolution_reconstruct, electrodes_num)
% GET_SOLVER Creates an inverse model solver for EIT reconstruction
%
% Syntax:
%   [inverse_model, metadata] = get_solver(name, resolution_reconstruct, electrodes_num)
%
% Inputs:
%   name                  - String specifying the solver method:
%                           'total_variation', 'Tikhonov_prior',
%                           'Gauss-Newton', 'Tikhonov_regularization_Gauss_Newton_solver',
%                           'Backprojection'
%   resolution_reconstruct - Resolution for the reconstructed image
%   electrodes_num        - Number of electrodes in the EIT system
%
% Outputs:
%   inverse_model - EIDORS inverse model object configured with the specified solver
%   metadata      - Structure containing reference papers and documentation links
%
% See also: generate_homogenous_image, inv_solve

% Create the inverse model
[img_reconst, v_homogeneous_reconst] = generate_homogenous_image(resolution_reconstruct, electrodes_num);
inverse_model = eidors_obj('inv_model', 'EIT inverse');
inverse_model.reconst_type = 'difference';
inverse_model.jacobian_bkgnd.value = 1;
inverse_model.fwd_model = img_reconst.fwd_model;

% Choose the solver
switch name 
    
    case 'total_variation' 
        inverse_model.hyperparameter.value = .1;
        inverse_model.solve = @inv_solve_TV_pdipm;
        inverse_model.R_prior = @prior_TV;
        inverse_model.fwd_model = mdl_normalize(inverse_model.fwd_model, 1);
        inverse_model.parameters.max_iterationsinvtv.parameters.max_iterations = 30;
       
        metadata.paper_s = {'Borsic, Andrea, Brad M. Graham, Andy Adler, and William R. B. Lionheart. 2010. In Vivo Impedance Imaging With Total Variation Regularization. IEEE Transactions on Medical Imaging 29 (1): 44–54. https://doi.org/10.1109/TMI.2009.2022540.'};
        metadata.website = {'http://eidors3d.sourceforge.net/tutorial/adv_image_reconst/total_variation.shtml'};
       
    case 'Tikhonov_prior'
        inverse_model.hyperparameter.value = .03;
        inverse_model.RtR_prior = @prior_tikhonov;
      
    case 'Gauss-Newton'
        inverse_model.solve = @inv_solve_diff_GN_one_step;
        inverse_model.RtR_prior = @prior_noser;
        inverse_model.jacobian_bkgnd.value = 1;
        inverse_model.hyperparameter.value = 0.5;
        
        metadata.paper_s = {'Adler, A., and R. Guardo. 1996. "Electrical Impedance Tomography: Regularized Imaging and Contrast Detection." IEEE Transactions on Medical Imaging 15 (2): 170–79. https://doi.org/10.1109/42.491418.'};
        metadata.website = {'http://eidors3d.sourceforge.net/tutorial/EIDORS_basics/tutorial120.shtml'};
        
    case 'Tikhonov_regularization_Gauss_Newton_solver'
        inverse_model.solve = @inv_solve_diff_GN_one_step;
        inverse_model.hyperparameter.value = .1;
        inverse_model.RtR_prior = @prior_tikhonov;

        metadata.paper_s = {'Vauhkonen, M., D. Vadasz, P.A. Karjalainen, E. Somersalo, and J.P. Kaipio. 1998. Tikhonov Regularization and Prior Information in Electrical Impedance Tomography. IEEE Transactions on Medical Imaging 17 (2): 285–93. https://doi.org/10.1109/42.700740.'};
        metadata.website = {'http://eidors3d.sourceforge.net/tutorial/EIDORS_basics/tutorial120.shtml'};
        
    case 'Backprojection'
        inv_BP.solve = @inv_solve_backproj;
        inv_BP.inv_solve_backproj.type = 'naive';
        error('Backprojection method not complete. Please complete implementation.');
end

end
