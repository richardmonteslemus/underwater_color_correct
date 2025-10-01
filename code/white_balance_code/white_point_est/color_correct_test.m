% Define the path to your CSV file

clear all; close all; clc;

addpath(genpath('.'))
%%
csvPath = 'E:\Colorimetry\GLM\data\gray3_rgb_patch_table.csv';  % Adjust path as needed

% Read the CSV and use row names
patch_rgb_table = readtable(csvPath, 'ReadRowNames', true);

% Display the table
disp(patch_rgb_table);

% Define save path for .mat file
savePath = 'E:\Colorimetry\GAMs\data';
save_patch_rgb = fullfile(savePath, 'patch_rgb.mat');

% Save the table to a .mat file
save(save_patch_rgb, 'patch_rgb_table');

% Confirmation message
fprintf('✅ MATLAB file saved to:\n%s\n', save_patch_rgb);


%% White balance PNG Images 
% use white_balance_png function
 % Parameters:
    %   input_folder  - Path to the folder containing uncorrected TIFF images
    %   output_folder - Path to the folder where white-balanced images will be saved
    %   patch_rgb_path - Path to the .mat file containing the patch RGB table
    %   selected_patch - Name of the patch used for white balancing (e.g., 'gray3')
    %   Ref_expected  - Expected reflectance for the selected patch (e.g., 0.40)

uncorrectedTiff_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\uncorrectedTiff_test';
white_balanced_png_folder = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png_test';
path2patch_rgb = 'E:\Colorimetry\GLM\data\patch_rgb';
selected_patch = 'gray3';
patch_reflectance_expected = 0.50;

white_balance_png(uncorrectedTiff_folder, white_balanced_png_folder, path2patch_rgb, selected_patch, patch_reflectance_expected);


% %% Copy metadata to tiff files 
% 
% dngPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\test_dng';
% destinationPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\test_wb_tiff';
% copyMetadata_dng2tiff(dngPath,destinationPath)

%% Copy metadata to PNG files 

dngPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\dng';
destinationPath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png_test';
copyMetadata_dng2png(dngPath,destinationPath)