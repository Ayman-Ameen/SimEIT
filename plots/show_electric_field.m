function show_electric_field(image_electric_volt, v, img)
% SHOW_ELECTRIC_FIELD Visualize and save electric field images and voltages.
%
% Inputs:
%   image_electric_volt - 4D array [sample, electrode, x, y] of field images.
%   v                   - Voltage matrix [sample, measurement].
%   img                 - EIDORS image struct with mesh/electrodes.

% Number of electrodes and save folder
n_ele = 16; save_folder = 'electrical_field_plot/'; mkdir(save_folder);

figure
set(gcf, 'PaperUnits', 'inches');
set(gcf, 'PaperSize', [4 4]);
for counter3 = 1
  set(gcf, 'InvertHardCopy', 'off'); % prevent color inversion while saving

  for counter4 = 1:n_ele
    % Field image
    subplot(12,14,1:14*10);
    imagesc(linspace(-1,1,length(squeeze(image_electric_volt(counter3,counter4,:,:)))), ...
        linspace(-1,1,length(squeeze(image_electric_volt(counter3,counter4,:,:)))), ...
        squeeze(image_electric_volt(counter3,counter4,:,:)));
    axis equal; axis off; set(gcf,'Color','k'); colormap turbo;
    title([num2str(counter4)], 'Color', [1 1 1]);
    colorbar('Box','off','Color',[1,1,1]); hold on;

    % Electrodes (drive pair in red)
    for counter5 = 1:n_ele
      if (counter5 == counter4) || (counter5 == counter4 + 1)
        color = [1, 0, 0];
      elseif (counter4 == n_ele) && ((counter5 == 1) || (counter5 == n_ele))
        color = [1, 0, 0];
      else
        color = [1, 1, 1];
      end
      scatter(img.fwd_model.nodes(img.fwd_model.electrode(counter5).nodes,1), ...
          img.fwd_model.nodes(img.fwd_model.electrode(counter5).nodes,2), ...
          'filled', 'MarkerEdgeColor', color, 'MarkerFaceColor', color);
    end
    axis tight;

    pause(0.5);
    % Voltages for the subset of measurements
    subplot(12,14,(14*10+1):(12*14));
    plot(v(counter3, 1:counter4*n_ele), 'Color', [1 1 1], 'LineWidth', 2);
    set(gca,'Color','k'); set(gca,'XColor',[1 1 1],'YColor',[1 1 1]);
    xlabel('Meas. Num.'); ylabel('Volt (a.u.)');
    save_name = [save_folder,'Homo',num2str(counter4)];

    pause(0.5);
    exportgraphics(gcf, [save_name, '.png'], 'Resolution', 500, 'BackgroundColor', [0 0 0]);
  end
end
end