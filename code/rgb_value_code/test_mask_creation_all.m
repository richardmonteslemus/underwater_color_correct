

clear all; close all; clc;

%% LOAD A LINEAR IMAGE THAT HAS A Color Chart IN THE SCENE

% Read the CSV file
tiff_file_data = readtable('E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\img_csv_files\selected_dng_color_charts.csv');

% Extract the FileName column
tiff_file_names = tiff_file_data.FileName; % This will be a cell array of strings

% % Define the list of image files (adjust to add or remove files as needed)
% tiff_file_names = {'233A0013.tif', '233A0037.tif', '233A0059.tif'};  % Add new files here

% Define the base directory where the images are stored
base_dir_linear = 'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\uncorrectedTiff';
% Define the base directory of where the depth map folder is located
base_dir_depth = 'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\depth_tif';

% Define the save path for CSV files
savePath = 'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\img_csv_files';
if ~isfolder(savePath)
    mkdir(savePath);
end

% Initialize the final table to store all rows
final_table = table();

% Check if masks file exists, if so, load it
masks_file = fullfile(savePath, 'all_masks.mat');
if isfile(masks_file)
    load(masks_file, 'all_masks');
else
    all_masks = struct();  % Initialize all_masks if not loaded
end

%% Iterate through each linear image
for idx = 1:length(tiff_file_names)
    % Linear Tiff
    linear_tiff = tiff_file_names{idx};
    
    % Construct the full file path dynamically
    image_path = fullfile(base_dir_linear, linear_tiff);
    
    % Read the image dynamically
    I = im2double(imread(image_path));
    
    % Depth Map Tiff
    depthmap_tiff = imread(fullfile(base_dir_depth, linear_tiff));  % Assuming depth maps are named the same
    
    s = size(I);
    %figure; imshow(I * 2)
    %title('Linear image', 'fontsize', 20)

    %% LOAD COLOR CHART DATA
    load DGKColorChart.mat
    DGKColorChart_struct = load('DGKColorChart.mat');
    neutralPatches = [1 2; 1 3; 1 4; 1 5; 1 6];
    neutralTarget = [0.243 0.186 0.124 0.079 0.0322];
    
    %% CHECK IF MASK EXISTS FOR THIS IMAGE
    sanitized_name = matlab.lang.makeValidName(strrep(linear_tiff, '.', '_'));  % Replace '.' with '_' for compatibility
    if isfield(all_masks, sanitized_name)
        % Use the mask from all_masks
        current_mask = all_masks.(sanitized_name);
    else
        % If no mask exists, create a new one
        current_mask = makeChartMask(3 * I, chart, colors, 40);
        
        % Save the mask information for this image in the all_masks structure
        all_masks.(sanitized_name) = current_mask;
    end

    % Get RGB values from the patches
    rgb_values = getPatchValues(I, current_mask, neutralPatches, colors);
    
    % Extract color names using neutralPatches
    color_names = colors(sub2ind(size(colors), neutralPatches(:,1), neutralPatches(:,2)));
    
    % Create a filename column filled with linear_tiff value
    filename_column = repmat({linear_tiff}, size(neutralPatches, 1), 1);
    
    % Create a table with Filename, Color Name, and RGB values
    rgb_table = table(filename_column, color_names, rgb_values(1,:)', rgb_values(2,:)', rgb_values(3,:)', ...
        'VariableNames', {'Filename', 'ColorName', 'Red', 'Green', 'Blue'}); 

    %% Save Mask For Every Current Image

    all_colors_mask = rgb_table{:, 2};  % Get the second column (ColorName)

    % Specify the correct path to the image
    imageFile_masks = fullfile(base_dir_linear, linear_tiff);  % Correct path
    img_mask = imread(imageFile_masks);  % Read the image

    % Multiply the image by 3 (if desired)
    imgScaled_mask = img_mask * 3;

    % Create an image to store the combined overlays
    combinedImage = imgScaled_mask;  % Start with the scaled image

% Loop through each color and overlay the corresponding mask
    for i = 1:length(all_colors_mask)
        % Select the color from the list
        patch_color = all_colors_mask{i};  % Choose the color from the cell array

        % Get the mask for the chosen color (binary mask)
        visualized_mask = all_masks.(sanitized_name).(patch_color).mask;  % Binary mask

        % Overlay the current mask on the image
        combinedImage = imoverlay(combinedImage, visualized_mask, [1, 0, 0]);  % Red color for the overlay (adjust as needed)
    end

    % % Display the combined result
    % figure;
    % imshow(combinedImage);
    % title(sprintf('%s Mask Overlay', linear_tiff), 'Interpreter', 'none');


    mask_img_savePath = fullfile(savePath, 'mask_images');  % Example directory

    % Create the directory if it doesn't exist
    if ~exist(mask_img_savePath, 'dir')
        mkdir(mask_img_savePath);
    end

    % Create the file name dynamically based on linear_tiff
    mask_img_saveFileName = sprintf('mask_overlay_%s.png', linear_tiff);

    % Create the full save path for the image
    mask_img_saveImagePath = fullfile(mask_img_savePath, mask_img_saveFileName);

    % Save the image using imwrite
    imwrite(combinedImage, mask_img_saveImagePath);


% %% Save Mask For Every Current Image Depth Map
% 
% all_colors_mask = rgb_table{:, 2};  % Get the second column (ColorName)
% 
% % Specify the correct path to the image
% imageFile_masks = fullfile(base_dir_depth, linear_tiff);  % Correct path
% img_mask = imread(imageFile_masks);  % Read the image
% 
% % Apply false coloration to the depth map
% % Normalize the image values if needed (assuming the depth map is in the range [0, 255])
% img_mask_normalized = mat2gray(img_mask);  % Normalize the image to [0, 1]
% false_colored_img = ind2rgb(im2uint8(img_mask_normalized), jet);  % Apply 'jet' colormap for false coloration
% 
% % Multiply the image by 3 (if desired)
% imgScaled_mask = img_mask * 3;
% 
% % Create an image to store the combined overlays
% combinedImage = false_colored_img;  % Start with the false-colored image
% 
% % Loop through each color and overlay the corresponding mask
% for i = 1:length(all_colors_mask)
%     % Select the color from the list
%     patch_color = all_colors_mask{i};  % Choose the color from the cell array
% 
%     % Get the mask for the chosen color (binary mask)
%     visualized_mask = all_masks.(sanitized_name).(patch_color).mask;  % Binary mask
% 
%     % Overlay the current mask on the image
%     combinedImage = imoverlay(combinedImage, visualized_mask, [1, 0, 0]);  % Red color for the overlay (adjust as needed)
% end
% 
% % % Display the combined result
% % figure;
% % imshow(combinedImage);
% % title(sprintf('%s Mask Overlay', linear_tiff), 'Interpreter', 'none');
% 
% mask_img_savePath = fullfile(savePath, 'depth_mask_images');  % Example directory
% 
% % Create the directory if it doesn't exist
% if ~exist(mask_img_savePath, 'dir')
%     mkdir(mask_img_savePath);
% end
% 
% % Create the file name dynamically based on linear_tiff
% mask_img_saveFileName = sprintf('mask_overlay_%s.png', linear_tiff);
% 
% % Create the full save path for the image
% mask_img_saveImagePath = fullfile(mask_img_savePath, mask_img_saveFileName);
% 
% % Save the image using imwrite
% imwrite(combinedImage, mask_img_saveImagePath);

    
    %% One Row Format for CSV File
    % Reshape data into a single row
    new_column_names = {};  % Store dynamic column names
    new_values = [];  % Store corresponding values
    
    for i = 1:height(rgb_table)
        color = rgb_table.ColorName{i};  % Get color name
        new_column_names = [new_column_names, ...
            strcat(color, '_Red'), strcat(color, '_Green'), strcat(color, '_Blue')];  % Column names
        new_values = [new_values, rgb_table.Red(i), rgb_table.Green(i), rgb_table.Blue(i)];  % RGB values
    end
    
    % Create new table with single row
    new_table = array2table(new_values, 'VariableNames', new_column_names);
    new_table.Filename = {linear_tiff};  % Add filename as first column
    
    % Reorder so Filename is first
    new_table = movevars(new_table, 'Filename', 'Before', 1);
    
    %% Plotting Y values vs. RGB values (optional)
    figure;
    plot(neutralTarget, rgb_values(1,:), 'or', 'LineWidth', 2)
    hold on;
    plot(neutralTarget, rgb_values(2,:), 'og', 'LineWidth', 2)
    plot(neutralTarget, rgb_values(3,:), 'ob', 'LineWidth', 2)

    title(sprintf('%s Camera sensor linearity check', linear_tiff), 'Interpreter', 'none')
    xlabel('Y values')
    ylabel('RGB values')
    legend('Red channel', 'Green channel', 'Blue channel', 'Location', 'northwest')
    
    %% Initialize an array to store intercepts for each row
    chart1_bc = zeros(3, 1);  % 3 rows for R, G, B channels
    
    % Loop through each row (each channel)
    for i = 1:3
        % Fit a linear model (y = mx + b) for each row of RGB values
        p = polyfit(neutralTarget, rgb_values(i,:), 1);  % 1st-degree polynomial (linear regression)
        
        % Extract the intercept (b) and store it in the intercepts array
        chart1_bc(i) = p(2);
    end

    %% Write backscatter values into the table
    if ~ismember('red_bc', new_table.Properties.VariableNames)
        new_table.red_bc = NaN(height(new_table), 1); % Initialize with NaN
    end

    if ~ismember('green_bc', new_table.Properties.VariableNames)
        new_table.green_bc = NaN(height(new_table), 1); % Initialize with NaN
    end

    if ~ismember('blue_bc', new_table.Properties.VariableNames)
        new_table.blue_bc = NaN(height(new_table), 1); % Initialize with NaN
    end
    if ~ismember('depth', new_table.Properties.VariableNames)
        new_table.depth = NaN(height(new_table), 1); % Initialize with NaN
    end
    new_table.red_bc(end) = chart1_bc(1);
    new_table.green_bc(end) = chart1_bc(2);
    new_table.blue_bc(end) = chart1_bc(3);

    %% Calculate Depth
    averageDepth = getOverallMeanDepth(depthmap_tiff, current_mask, neutralPatches, colors);
    new_table.depth(end) = averageDepth;

     % Append new row to the final table
    final_table = [final_table; new_table];
end

%% Filter negative values and set them to zero

%% Filter negative values and set them to zero, only for numeric columns
% Find the numeric columns
numeric_columns = varfun(@isnumeric, final_table, 'OutputFormat', 'uniform');

% Apply the transformation to only numeric columns
final_table{:, numeric_columns} = max(final_table{:, numeric_columns}, 0);  % Set negative values to 0

%% Save the final table to a CSV file
save_csv_file_single_row = fullfile(savePath, 'test_rgb_depth_bc.csv');
writetable(final_table, save_csv_file_single_row);

% Confirmation message
fprintf('Updated CSV file with all images has been saved to %s\n', save_csv_file_single_row);



%% Saving masks struct as: masks_struct.mat
saveFile = fullfile(savePath, 'all_masks.mat');

% Save the masks struct to a .mat file using version 7.3 for large data support
save(saveFile, 'all_masks', '-v7.3');

% Confirmation message
fprintf('Masks struct has been saved to %s\n', saveFile);


%%
% Load the CSV file as a table
depth_vs_bc = readtable("E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\img_csv_files\test_rgb_depth_bc.csv");

% Extract columns by name
depth = depth_vs_bc.depth; 
red_bc = depth_vs_bc.red_bc;
green_bc = depth_vs_bc.green_bc;
blue_bc = depth_vs_bc.blue_bc;

% Create the plot
figure;
plot(depth, red_bc, 'or', 'LineWidth', 2); % Red channel
hold on;
plot(depth, green_bc, 'og', 'LineWidth', 2); % Green channel
plot(depth, blue_bc, 'ob', 'LineWidth', 2); % Blue channel
hold off;

% Customize the plot
xlabel('Depth');
ylabel('Backscatter');
title('Backscatter vs Depth');
legend({'Red Channel', 'Green Channel', 'Blue Channel'}, 'Location', 'best');
grid on;


