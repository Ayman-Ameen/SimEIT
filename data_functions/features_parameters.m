
function [features, types, coverage_area] = features_parameters(number_of_objects, type_all, features, dimension, number_of_features, dir_dataset, index1, conductivity)

% h = figure('visible','off');

        number_of_tries = 100; % number_of_tries = 1 ;% 
        resolution      = 256; 
        
        inner_radius = 1; % 0.9; 
        x = linspace(-1, 1, resolution);  %x = -1:0.01:1 ;
        y = linspace(-1, 1, resolution);  %y = -1:0.01:1 ;
        [X, Y] = meshgrid(x, y); 
    unit_circle_fcn = str2func('@(x,y,z) (x).^2 + (y).^2 < (1)^2');
    unit_circle_fcn_2 = str2func(['@(x,y,z) (x).^2 + (y).^2 < (', num2str(inner_radius), ')^2']);
        XY_mask_unit = unit_circle_fcn(X,Y,[]); area_of_the_unit_circle = sum(XY_mask_unit,'all');
        XY_mask_unit_2 = unit_circle_fcn_2(X,Y,[]);
        sum_unit_circle = sum(XY_mask_unit(:));
        frac_size       = 1/100 ; 
        condition_true = 0 ; 
       while ~condition_true 
        
       temp_rand = randi([0,1],[ number_of_tries , number_of_features ]); temp_rand(~temp_rand) = -1 ;
       features_rand_all = temp_rand .* rand( [ number_of_tries , number_of_features ] ) ;
       
       type              = type_all((randi([1,length(type_all)],[1,number_of_tries])));
       All_shapes_std_x  = zeros(1,number_of_tries) ; 
       All_shapes_std_y  = zeros(1,number_of_tries) ;
       
       
       All_shapes = ones([  number_of_tries , size(XY_mask_unit) ]); 
        
       for counter = 1 : number_of_tries 
    %FEATURES_PARAMETERS Sample non-overlapping shapes and return feature vectors.
    %   [features, types, coverage_area] = FEATURES_PARAMETERS(number_of_objects, ...)
    %
    %   This function randomly proposes many candidate shapes, filters them by
    %   constraints (inside unit circle, minimum size, not degenerate), selects a
    %   non-intersecting subset, and returns the corresponding feature vectors and
    %   types for the requested number_of_objects.
    %
    %   Inputs:
    %     number_of_objects  - Number of distinct objects to return.
    %     type_all           - Cell array of shape type names to sample from.
    %     features           - Preallocated feature vector (size determines output).
    %     dimension          - Dimensionality flag (e.g., '2d').
    %     number_of_features - Number of features per object.
    %     dir_dataset        - Dataset directory (currently unused).
    %     index1             - Sample index (currently unused).
    %     conductivity       - Per-object conductivity (currently unused here).
    %
    %   Outputs:
    %     features       - Column-wise stacked features for the selected objects.
    %     types          - Cell array of selected object types.
    %     coverage_area  - Area fraction covered by the selected objects.

            condition_shape = 1 ; 
            while condition_shape
                
             temp_rand = randi([0, 1], [1, number_of_features]); 
             temp_rand(~temp_rand) = -1;
             features_rand_all(counter, 1:end) = temp_rand .* rand([1, number_of_features]) * inner_radius;

            type(counter) = type_all((randi([1, length(type_all)], [1, 1])));
    
            if strcmp(type(counter), 'circle') == 1 
                features_rand_all(counter, number_of_features) = sqrt(abs(rand(1, 1)) * inner_radius);
            else 
                features_rand_all(counter, number_of_features) = 2*pi * rand(1, 1); 
            end
            
            object_str = object2str(features_rand_all(counter, 1:end-1), features_rand_all(counter, end), type{counter}, dimension);  
            select_fcn = str2func(['@(x,y,z) ', object_str]);
            All_shapes(counter, :, :) = select_fcn(X, Y, []);  
            
            
            %  conditions
            %check that the object is inside unit circle 
            condition_shape_1 = ~all(reshape(and(XY_mask_unit_2 , squeeze(All_shapes(counter,:,:))) == squeeze(All_shapes(counter,:,:)),[],1)) ; 
            %check if the object t certian size 
            condition_shape_2 = sum(reshape(All_shapes(counter,:,:),[],1))<=sum_unit_circle*frac_size ;
            condition_shape_3 =  or(condition_shape_1,condition_shape_2);
            %check if the object not line 
           All_shapes_std_x(counter) = sum(std(squeeze(All_shapes(counter,:,:)),0,1));
           All_shapes_std_y(counter) = sum(std(squeeze(All_shapes(counter,:,:)),0,2));
           
           
           
            condition_shape_4 = ~and(All_shapes_std_x(counter)/All_shapes_std_y(counter) <= 4 , All_shapes_std_y(counter)/All_shapes_std_x(counter) <= 4 );
            
            condition_shape = or(condition_shape_3,condition_shape_4);
            
            
           
            
            end
   
           
       end
       
       %%%%%%%% Building confusion matrix %%%%%%%
       cnf_matrix = zeros(number_of_tries,number_of_tries);
       for k = 1 : number_of_tries 
          for k1 = 1 : number_of_tries  % this can be improved be calculate the upper part only then reflect them
              cnf_matrix(k,k1) = ~any(reshape(and(All_shapes((k),:,:),All_shapes((k1),:,:)),[],1));
          end
  
       end
       
       [index_shapes] = not_intersect(cnf_matrix , number_of_objects) ;  
       if and(~isempty(index_shapes),length(index_shapes)>= number_of_objects)
           condition_true = 1 ; 
       end
% %        Ignore the cnf_matrix 
%             condition_true = 1 ; 
%             index_shapes = 1   ; 
       end      
       
        features = reshape(features_rand_all(index_shapes,: )',size(features));
        
        types    =    type(index_shapes);
        
        coverage_area = sum(All_shapes(index_shapes,:,:),'all')/area_of_the_unit_circle;
        
        %%%% plot and write data 
%         
%         Combine_shapes = zeros(size(All_shapes(1,:,:)));
%         Combine_shapes_with_cond =  zeros(size(All_shapes(1,:,:)));
%         for k = 1 : length(index_shapes)
%             
%             Combine_shapes           = Combine_shapes + All_shapes(index_shapes(k),:,:);
%             Combine_shapes_with_cond = Combine_shapes_with_cond + All_shapes(index_shapes(k),:,:) * conductivity(k);
%         end
%         Combine_shapes_with_cond = Combine_shapes_with_cond + 1 ; 
%         
%         Combine_shapes_with_cond( 1 , XY_mask_unit == 0 ) = 0 ; 
        
%         
%         mkdir([dir_dataset,num2str(index1)])
%         dir_dataset_target = [dir_dataset,num2str(index1),'/'] ;
        
%         imagesc(squeeze(Combine_shapes)); colorbar; colormap jet ;
%         exportgraphics(gcf,[dir_dataset_target, num2str(index1) , 'without_cond' ,'.png'],'Resolution',200); 
%         exportgraphics(gcf,[dir_dataset_all num2str(index1) , 'without_cond' ,'.png'],'Resolution',200); 

%         
%         imagesc(squeeze(Combine_shapes_with_cond)); colorbar; colormap jet ;
%         exportgraphics(gcf,[dir_dataset_target, num2str(index1) , 'with_cond' ,'.png'],'Resolution',200); 
%         
%         exportgraphics(gcf,[dir_dataset_all num2str(index1) , 'with_cond' ,'.png'],'Resolution',200); 
%         
%         writematrix( squeeze(Combine_shapes) ,[dir_dataset_target,'image_without_cond.xls'])
%         writematrix( squeeze(Combine_shapes_with_cond) ,[dir_dataset_target,'image_with_cond.xls'])
%         
%         image_scale_all = [32,64,128] ; 
%         for image_counter = 1 : length(image_scale_all)
%             
%             ratio = image_scale_all(image_counter) ;
%             
%             image_scaled = imresize(squeeze(Combine_shapes),[ratio,ratio],'bilinear'); %,'nearest');
%             imagesc(image_scaled); colorbar; colormap jet ;
% %             exportgraphics(gcf,[dir_dataset_target, num2str(index1) , 'without_cond_', num2str(ratio) ,'_.png'],'Resolution',200); 
%             writematrix( image_scaled ,[dir_dataset_target,'image_without_cond_', num2str(ratio) ,'_.xls']);
%             
%             image_scaled = imresize(squeeze(Combine_shapes_with_cond),[ratio,ratio],'bilinear'); %,'nearest');
%             imagesc(image_scaled); colorbar; colormap jet ;
%             exportgraphics(gcf,[dir_dataset_target, num2str(index1) , 'with_cond_', num2str(ratio) ,'_.png'],'Resolution',200); 
%             if (ratio == image_scale_all(1)) 
%             exportgraphics(gcf,[dir_dataset_all num2str(index1) , 'with_cond_', num2str(ratio) ,'_.png'],'Resolution',200); 
%             end
%             writematrix( image_scaled ,[dir_dataset_target,'image_with_cond_', num2str(ratio) ,'_.xls'])
% 
%         end
%         
%         
% 
%         close all    

    return 
end





%%%%% Save the mask %%%%%
% imagesc(XY_mask_unit)
% save('mask.mat','XY_mask_unit')
% save('mask_256.mat','XY_mask_unit')
% mask_32 = imresize(XY_mask_unit,[32,32],'bilinear')
% imagesc(mask_32)
% save('mask_32.mat','mask_32')
% save('mask_64.mat','mask_64')
% mask_64 = imresize(XY_mask_unit,[64,64],'bilinear')
% save('mask_64.mat','mask_64')
% mask_32 = imresize(XY_mask_unit,[32,32],'bilinear')
% save('mask_32.mat','mask_32')
% mask_128 = imresize(XY_mask_unit,[128,128],'bilinear')
% save('mask_128.mat','mask_128')
% figure;imagesc(mask_128);
% figure;imagesc(mask_32);
% figure;imagesc(mask_64);
% close all
% writetable(table(mask_128),'mask_128.xls','WriteVariableNames',false)
% writetable(table(mask_64),'mask_64.xls','WriteVariableNames',false)
% writetable(table(mask_32),'mask_32.xls','WriteVariableNames',false)
% writetable(table(XY_mask_unit),'mask_256.xls','WriteVariableNames',false)
% mask = mask_128 ; save('/disk/DatasetB/dataset/metadata/Masks/mask_128.mat','mask')
% load('/disk/DatasetB/dataset/metadata/Masks/mask_32.mat')
% mask = mask_32 ; save('/disk/DatasetB/dataset/metadata/Masks/mask_32.mat','mask')
% load('/disk/DatasetB/dataset/metadata/Masks/mask_64.mat')
% mask = mask_64 ; save('/disk/DatasetB/dataset/metadata/Masks/mask_64.mat','mask')
% load('/disk/DatasetB/dataset/metadata/Masks/mask_256.mat')
% mask = XY_mask_unit ; save('/disk/DatasetB/dataset/metadata/Masks/mask_256.mat','mask')