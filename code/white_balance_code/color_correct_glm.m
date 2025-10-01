

clear; close all; clc
%% Load in images and scale file
uncorrectedTiff_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\uncorrectedTiff_test';
white_balanced_png_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png_test_glm';
path2scale = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\glm_scale.csv';

% Create the output folder if it doesn't exist
if ~exist(white_balanced_png_folder, 'dir')
    mkdir(white_balanced_png_folder);  % fixed typo in folder variable
end

% Load the scale table with RGB scaling factors
scale_table = readtable(path2scale);

% Get a list of all TIFF images in the input folder
image_files = dir(fullfile(uncorrectedTiff_folder, '*.tif'));

%% Loop through each image in the folder
for i = 1:length(image_files)
    % Read the image
    img_name = image_files(i).name;
    img_path = fullfile(uncorrectedTiff_folder, img_name);
    I2 = im2double(imread(img_path));

    % Extract base filename (without extension) for saving and titles
    [~, base_name, ~] = fileparts(img_name);

    % Extract scaling factors from scale table (assuming single row)
    w_r = scale_table.Red_scale;
    w_g = scale_table.Green_scale;
    w_b = scale_table.Blue_scale;

    % Apply white balancing
    Y = zeros(size(I2));
    Y(:,:,1) = I2(:,:,1) * w_r; % Red
    Y(:,:,2) = I2(:,:,2) * w_g; % Green
    Y(:,:,3) = I2(:,:,3) * w_b; % Blue
    % Y = Y .^ (1/2.2); % Gamma correction (optional)

    % Convert to 8-bit preserving details
    Y = im2uint8(Y);

    % VERIFY REFLECTANCE VALUE
    figure;
    subplot(1,2,1);
    imshow(I2);
    title(['Original Image: ', img_name], 'Interpreter', 'none');

    subplot(1,2,2);
    imshow(Y);
    title(['White Balanced Image: ', base_name], 'Interpreter', 'none');

    % Change file extension to .png
    output_filename = [base_name, '.png'];

    % Save as PNG with optimized compression
    output_path = fullfile(white_balanced_png_folder, output_filename);
    imwrite(Y, output_path, 'BitDepth', 8, 'Compression', 'none');

    % Display progress
    fprintf('Processed and saved: %s\n', output_filename);
end

disp('White balancing complete for all images, saved as PNG.');


%% Copy metadata to PNG files 

dngPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\dng';
destinationPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png_test_glm';
exif_path = 'E:\Colorimetry\Color_correction_protocol\code\exiftool.exe';
copyMetadata_dng2png(dngPath,destinationPath, exif_path)