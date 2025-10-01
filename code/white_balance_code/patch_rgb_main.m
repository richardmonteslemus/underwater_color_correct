
clear all; close all; clc;

%% Visualize gray patches RGB pixel intensity values
final_table = readtable("E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\rgb_depth_bc.csv");

% Define grayscale reflectance values
gray_scale_levels = [0.2430, 0.1860, 0.1240, 0.0790, 0.0322];
gray_scale_names = ["gray1", "gray2", "gray3", "gray4", "black"];
colors_markers = {'r', 'g', 'b'}; % Red, Green, Blue markers
color_channels = ["Red", "Green", "Blue"]; % Full channel names in table

% Get the number of rows dynamically
num_rows = height(final_table); 

hold on;
for i = 1:length(gray_scale_levels)  % Loop through grayscale levels
    for j = 1:length(colors_markers)  % Loop through color channels
        column_name = sprintf('%s_%s', gray_scale_names(i), color_channels(j)); 
        
        % Check if column exists before plotting
        if any(strcmp(final_table.Properties.VariableNames, column_name))
            plot(gray_scale_levels(i) * ones(num_rows, 1), final_table.(column_name), [colors_markers{j} '.']);
        else
            warning("Column %s not found in table!", column_name);
        end
    end
end
hold off;

xlabel('Grayscale Reflectance');
ylabel('Intensity');
title('RGB Intensity vs Grayscale Reflectance');
legend({'Red', 'Green', 'Blue'}, 'Location', 'best');
grid on;

