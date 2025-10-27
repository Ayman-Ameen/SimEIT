function [image_resized,the_figure,save_properties] = convert_mesh_to_image_and_norm_and_scale(the_figure,save_properties, element_data,img,resolution_convert, resoultion_scale, colormap_for_patch )
% CONVERT_MESH_TO_IMAGE_AND_NORM_AND_SCALE Converts mesh data to normalized and scaled image
%   [image_resized, the_figure, save_properties] = convert_mesh_to_image_and_norm_and_scale(...)
%   Converts mesh data to an image, normalizes, and rescales it.
x = linspace(-1,1,resolution_convert)   ;
y = linspace(-1,1,resolution_convert)   ;
[X,Y]    = meshgrid(x,y)                ; 

%% normalize 
% element_data_norm     = (element_data-min(element_data))/(max(element_data)-min(element_data));
element_data_norm     = (element_data-mean(element_data(:)))/(std(element_data(:)));

%% 

if isempty(the_figure); [the_figure,save_properties] = get_figure(); end;
set(0, 'CurrentFigure', the_figure);
set(gca,'FontSize',30)
% set(gca,'visible','on')
patch_real = patch('Faces',img.fwd_model.elems          ,'Vertices',img.fwd_model.nodes          ,'FaceColor','flat','FaceVertexCData',element_data_norm,'EdgeColor','None');axis tight; axis equal; axis off; colorbar; colormap(colormap_for_patch);
X_real = patch_real.XData ; Y_real = patch_real.YData ; data_real = repmat(element_data,1,3)';
X_real = X_real(:);  Y_real = Y_real(:); data_real = data_real(:);
image  = griddata(X_real,Y_real,data_real,X,Y);

%% rescaled 
% image_resized = imresize(image,[resoultion_scale,resoultion_scale],'bilinear');
image_resized = image; 
%% Normalize the image 
image_resized = (image_resized-mean(image_resized(~isnan(image_resized))))/std(image_resized((~isnan(image_resized))));
end