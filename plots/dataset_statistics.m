function [] = dataset_statistics(data, dir_dataset_metadata)
% DATASET_STATISTICS Generate and save dataset statistics plots.
%
% Inputs:
%   data                  - Table with dataset metadata. Expected columns:
%                           number_of_objects, type (cell array per object),
%                           conductivity (numeric per object), coverage_area.
%   dir_dataset_metadata  - Base directory of the dataset metadata; plots
%                           will be saved under plot/statistics.
%
% This function computes and visualizes several statistics:
%   - Distribution of the number of objects
%   - Types of objects overall and per object count
%   - Conductivity distribution overall and per object count (log10 scale)
%   - Coverage area distribution overall and per object count

path_plots = fullfile(dir_dataset_metadata,'plot','statistics');
if ~exist(path_plots,'dir'); mkdir(path_plots); end

% Number of objects distribution
number_of_objects     = groupcounts(data,'number_of_objects'); disp('number_of_objects'); disp(number_of_objects);
number_of_objects_max = max(number_of_objects.number_of_objects);
plot_bar(number_of_objects.number_of_objects, number_of_objects.GroupCount,'Number of objects','Count',path_plots,'number_of_objects',600,1,[],[],0);

% Types of objects (overall)
for counter = 1:number_of_objects_max
    type_once = groupcounts(table(data.type(:,counter)),'Var1'); disp(['type_once',num2str(counter)]); disp(type_once);

    if counter == 1
        objects = type_once.Var1;
        counts  = type_once.GroupCount;
    else
        % Delete empty strings
        for counter_str = 1:length(type_once.Var1)
            if strcmp(type_once.Var1{counter_str},'')
                type_once(counter_str,:) = [];
                break
            end
        end
        counts = [counts, type_once.GroupCount];
    end
end

counts_all = sum(counts,2); disp(counts_all)
plot_bar(categorical(objects), counts_all,'Type of object','Count',path_plots,'type_of_objects',600,2,[],[],0);

% Types of objects per number of objects
for counter = 1:number_of_objects_max
    for counter_once = 1:counter
        if counter_once == 1
            count_object_per_number_once = groupcounts(table(data(data.number_of_objects == counter,:).type(:,counter_once)),'Var1'); disp(['count_object_per_number_once ',num2str(counter),num2str(counter_once)]); disp(count_object_per_number_once);
            count_object_per_number(counter,:) = count_object_per_number_once.GroupCount;
        else
            count_object_per_number_once = groupcounts(table(data(data.number_of_objects == counter,:).type(:,counter_once)),'Var1'); disp(['count_object_per_number_once ',num2str(counter),num2str(counter_once)]); disp(count_object_per_number_once);
            count_object_per_number(counter,:) = count_object_per_number(counter,:) + count_object_per_number_once.GroupCount';
        end
    end
end

plot_bar(number_of_objects.number_of_objects, count_object_per_number , 'Number of objects', 'Count', path_plots,'number_and_type_of_objects',600,[],count_object_per_number_once.Var1,'northwest',0)

% Conductivity distribution (log10 scale)
count_object_per_number = [];
for counter = 1:number_of_objects_max
    for counter_once = 1:counter
        count_object_per_number_once = data(data.number_of_objects == counter,:).conductivity(:,counter_once);
        count_object_per_number = [count_object_per_number; count_object_per_number_once];
    end
end
count_object_per_number = log10(count_object_per_number);
plot_bar(count_object_per_number',[], 'log( \sigma [Sm^{-1}] )', 'Count', path_plots,'conductivity',600,1,[],[],1)

% Conductivity per number of objects (log10 scale)
for counter = 1:number_of_objects_max
    count_object_per_number = [];
    for counter_once = 1:counter
        count_object_per_number_once = data(data.number_of_objects == counter,:).conductivity(:,counter_once);
        count_object_per_number = [count_object_per_number; count_object_per_number_once];
    end
    count_object_per_number = log10(count_object_per_number);
    plot_bar(count_object_per_number',[], 'log( \sigma [Sm^{-1}] )', 'Count', path_plots, ['conductivity_',num2str(counter)], 600, counter, ['Number of objects = ',num2str(counter)], 'northeast', 1)
end

% Coverage area distribution (arbitrary units)
plot_bar(data.coverage_area(:)',[], 'Coverage area (arb. unit)', 'Count', path_plots,'coverage_area',600,3,[],[],1)

% Coverage area per number of objects (arbitrary units)
for counter = 1:number_of_objects_max
    count_object_per_number = [];
    for counter_once = 1:counter
        count_object_per_number_once = data(data.number_of_objects == counter,:).coverage_area;
        count_object_per_number = [count_object_per_number; count_object_per_number_once];
    end
    plot_bar(count_object_per_number',[], 'Coverage area (arb. unit)', 'Count', path_plots, ['coverage_area_',num2str(counter)], 600, counter, ['Number of objects = ',num2str(counter)], 'northeast', 1)
end

close all

end

function [] = plot_bar(var1, var2, label1, label2, save_plot_folder, save_name, save_resolution, colors, legend_labels, legend_location, hist_plot)
% Helper to draw and save either a histogram (when hist_plot == 1) or a bar chart.
% Inputs are positional; see calls above for usage.

h = figure();
pause(1)
% Color palettes
color_all{1} = [124,252,0;0,250,154;30,144,255;0,0,128]./255; % Blue + Green
color_all{2} = [139,0,139;255,0,255;255,165,0;255,0,0]./255;  % Red + Orange

if hist_plot == 1
    histogram(var1,'FaceColor',color_all{1}(colors,:))
    disp(['mean = ',num2str(mean(var1)), ' , std = ', num2str(std(var1))]);
else
    bar_plot = bar(var1, var2, 'FaceColor','flat');
    ylim([0, max(var2(:)) + 0.1*max(var2(:))]);
end

set(gca,'FontSize',15)

if ~isempty(legend_labels)
    legend(legend_labels,'Location',legend_location)
elseif (~hist_plot)
    for counter = 1:length(var1)
        bar_plot.CData(counter,:) = color_all{colors}(counter,:);
    end
end

xlabel(label1,'FontSize',20)
ylabel(label2,'FontSize',20)
hold on
exportgraphics(h, [save_plot_folder, save_name, '.jpg'], 'Resolution', save_resolution)

end