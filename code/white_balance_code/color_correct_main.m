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

%%

% Preallocate matrix for means
means = zeros(length(gray_scale_levels), length(colors_markers)); % Rows for gray levels, columns for RGB

% Compute means for each color channel at each grayscale level
for i = 1:length(gray_scale_levels)
    for j = 1:length(colors_markers)
        column_name = sprintf('%s_%s', gray_scale_names(i), color_channels(j)); 
        
        % Check if column exists before computing mean
        if any(strcmp(final_table.Properties.VariableNames, column_name))
            means(i, j) = mean(final_table.(column_name));
        else
            warning("Column %s not found in table!", column_name);
            means(i, j) = NaN; % Assign NaN if column is missing
        end
    end
end

% Convert to table for clarity
patch_rgb_table = array2table(means, 'VariableNames', color_channels, 'RowNames', gray_scale_names);

% Display table
disp(patch_rgb_table);

% Save the table
save_patch_rgb = fullfile(savePath, 'patch_rgb.mat');
save(save_patch_rgb, 'patch_rgb_table');

% Confirmation message
fprintf('Updated Mat file with patch RGB averages has been saved to %s\n', save_patch_rgb);

%% White balance PNG Images 
% use white_balance_png function
 % Parameters:
    %   input_folder  - Path to the folder containing uncorrected TIFF images
    %   output_folder - Path to the folder where white-balanced images will be saved
    %   patch_rgb_path - Path to the .mat file containing the patch RGB table
    %   selected_patch - Name of the patch used for white balancing (e.g., 'gray3')
    %   Ref_expected  - Expected reflectance for the selected patch (e.g., 0.40)

uncorrectedTiff_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\uncorrectedTiff';
%uncorrectedTiff_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\test_uncorrectedTiff';
white_balanced_png_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png';
%white_balanced_png_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\test_wb_png';
path2patch_rgb = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\patch_rgb';
selected_patch = 'gray4';
patch_reflectance_expected = 0.1244;

white_balance_png(uncorrectedTiff_folder, white_balanced_png_folder, path2patch_rgb, selected_patch, patch_reflectance_expected);


% %% Copy metadata to tiff files 
% 
% dngPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\test_dng';
% destinationPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\test_wb_tiff';
% copyMetadata_dng2tiff(dngPath,destinationPath)

%% Copy metadata to PNG files 

dngPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\dng';
destinationPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png';
copyMetadata_dng2png(dngPath,destinationPath)