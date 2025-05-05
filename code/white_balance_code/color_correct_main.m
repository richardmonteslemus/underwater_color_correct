
% final_table = readtable("E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\rgb_depth_bc.csv")

%%
% plot(0.2430*ones(50,1),final_table.gray1_Red,'r.')
% hold on
% plot(0.1860*ones(50,1),final_table.gray2_Red,'r.')
% plot(0.1240*ones(50,1),final_table.gray3_Red,'r.')
% plot(0.0790*ones(50,1),final_table.gray4_Red,'r.')
% plot(0.0322*ones(50,1),final_table.black_Red,'r.')
% plot(0.2430*ones(50,1),final_table.gray1_Green,'g.')
% plot(0.1860*ones(50,1),final_table.gray2_Green,'g.')
% plot(0.1240*ones(50,1),final_table.gray3_Green,'g.')
% plot(0.0790*ones(50,1),final_table.gray4_Green,'g.')
% plot(0.0322*ones(50,1),final_table.black_Green,'g.')
% plot(0.2430*ones(50,1),final_table.gray1_Blue,'b.')
% plot(0.1860*ones(50,1),final_table.gray2_Blue,'b.')
% plot(0.1240*ones(50,1),final_table.gray3_Blue,'b.')
% plot(0.0790*ones(50,1),final_table.gray4_Blue,'b.')
% plot(0.0322*ones(50,1),final_table.black_Blue,'b.')

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
% %%
% 
% % Define the x-axis values
% x_values = [0.2430, 0.1860, 0.1240, 0.0790, 0.0322];
% 
% % Preallocate matrix for means
% means = zeros(5,3); % 5 rows for x-values, 3 columns for RGB
% 
% % Compute means for each color channel at each x-value
% means(1,1) = mean(final_table.gray1_Red);
% means(2,1) = mean(final_table.gray2_Red);
% means(3,1) = mean(final_table.gray3_Red);
% means(4,1) = mean(final_table.gray4_Red);
% means(5,1) = mean(final_table.black_Red);
% 
% means(1,2) = mean(final_table.gray1_Green);
% means(2,2) = mean(final_table.gray2_Green);
% means(3,2) = mean(final_table.gray3_Green);
% means(4,2) = mean(final_table.gray4_Green);
% means(5,2) = mean(final_table.black_Green);
% 
% means(1,3) = mean(final_table.gray1_Blue);
% means(2,3) = mean(final_table.gray2_Blue);
% means(3,3) = mean(final_table.gray3_Blue);
% means(4,3) = mean(final_table.gray4_Blue);
% means(5,3) = mean(final_table.black_Blue);
% 
% % Convert to table for clarity
% patch_rgb_table = array2table(means, 'VariableNames', {'Red', 'Green', 'Blue'}, 'RowNames', {'gray1',	'gray2',	'gray3',	'gray4',	'black'});
% 
% % Display table
% disp(patch_rgb_table);


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

% %% White balance Tiff Images 
% % use white_balance_tiff function
%  % Parameters:
%     %   input_folder  - Path to the folder containing uncorrected TIFF images
%     %   output_folder - Path to the folder where white-balanced images will be saved
%     %   patch_rgb_path - Path to the .mat file containing the patch RGB table
%     %   selected_patch - Name of the patch used for white balancing (e.g., 'gray3')
%     %   Ref_expected  - Expected reflectance for the selected patch (e.g., 0.40)
% 
% uncorrectedTiff_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\uncorrectedTiff';
% white_balanced_tiff_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png';
% path2patch_rgb = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\patch_rgb';
% selected_patch = 'gray3';
% patch_reflectance_expected = 0.40;
% 
% white_balance_png(uncorrectedTiff_folder, white_balanced_tiff_folder, path2patch_rgb, selected_patch, patch_reflectance_expected);

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
selected_patch = 'gray3';
patch_reflectance_expected = 0.30;

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