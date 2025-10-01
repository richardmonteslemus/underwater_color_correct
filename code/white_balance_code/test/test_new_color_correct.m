% Main script to estimate Kd and correct images based on extracted tables

clear; clc; close all;

%% 1. Load data tables

rgb_table = readtable('E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\rgb_depth_bc.csv'); % Filename, Patch, R, G, B, Depth
colorchart_table = readtable('E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\selected_color_charts.csv'); % Filename, ColorChartNumber
metadata_table = readtable('E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\metadata.csv'); % Filename, ExposureTime, FNumber, ISO

% Remove .dng extension if needed
metadata_table.Filename = erase(metadata_table.Filename, '.dng');
%Remove .tif extesnion if needed
rgb_table.Filename = erase(rgb_table.Filename, '.tif');

if any(strcmp(colorchart_table.Properties.VariableNames, 'FileName'))
    colorchart_table.Properties.VariableNames{'FileName'} = 'Filename';
end

%% 2. Merge tables into one master table

T = innerjoin(rgb_table, colorchart_table, 'Keys', 'Filename');
T = innerjoin(T, metadata_table, 'Keys', 'Filename');

%% 3. Normalize RGBs by exposure time

T.R_norm = T.R ./ T.ExposureTime;
T.G_norm = T.G ./ T.ExposureTime;
T.B_norm = T.B ./ T.ExposureTime;

%% 4. Load reflectance, camera sensitivity, and D65 light

refl = readtable('reflectance_dgk.csv');
lambda_refl = refl.wavelength;
Rho = table2array(refl(:,2:end));

lambda = 400:5:700; % working wavelengths
Rho_interp = interp1(lambda_refl, Rho', lambda, 'linear', 'extrap')'; % patches x lambda

load('camera_sensitivity.mat'); % SR, SG, SB

% Load and normalize D65
light_D65 = importdata('illuminant-D65.csv');
light_spectra_D65 = interp1(light_D65.data(:,1), light_D65.data(:,2), lambda, 'linear', 'extrap');
E0 = light_spectra_D65 / trapz(lambda, light_spectra_D65);

%% 5. Estimate Kd per color chart (using patches 1-6)

colorCharts = unique(T.ColorChartNumber);
Kd_all = containers.Map('KeyType','double','ValueType','any');

for i = 1:length(colorCharts)
    chart_num = colorCharts(i);
    T_sub = T(T.ColorChartNumber == chart_num,:);
    
    % Only grayscale patches 1-6
    T_gray = T_sub(T_sub.Patch <= 6, :);
    
    % Prepare normalized RGBs and depths
    RGB_matrix = [T_gray.R_norm, T_gray.G_norm, T_gray.B_norm];
    depths = T_gray.Depth;
    
    disp(['Estimating Kd for Color Chart #' num2str(chart_num)]);
    
    Rho_gray = Rho_interp(1:6,:); % Patches 1-6 only
    
    Kd_est = estimate_Kd(RGB_matrix, depths, Rho_gray, E0, SR, SG, SB, lambda);
    Kd_all(chart_num) = Kd_est;
    
    figure;
    plot(lambda, Kd_est, '-o');
    xlabel('Wavelength (nm)');
    ylabel('Kd (1/m)');
    title(['Estimated Kd for Color Chart #' num2str(chart_num)]);
    grid on;
end

save('Kd_estimates.mat', 'Kd_all', 'lambda');

%% 6. Color correct full images (if you want)

outputFolder = 'corrected_images';
mkdir(outputFolder);

uniqueFiles = unique(T.Filename);

for i = 1:length(uniqueFiles)
    fname = uniqueFiles{i};
    
    chart_num = unique(T.ColorChartNumber(strcmp(T.Filename, fname)));
    depth = unique(T.Depth(strcmp(T.Filename, fname)));
    
    if isempty(chart_num)
        warning(['No color chart found for ' fname]);
        continue;
    end
    
    Kd_est = Kd_all(chart_num);
    
    % Read linear image (must exist as .tif)
    img_path = fullfile('path_to_your_linear_images', [fname, '.tif']);
    if ~isfile(img_path)
        warning(['Missing image file: ' img_path]);
        continue;
    end
    img = im2double(imread(img_path));
    
    corrected_img = correct_image(img, depth, Kd_est, SR, SG, SB, lambda);
    
    imwrite(corrected_img, fullfile(outputFolder, [fname, '.tif']));
end

disp('Done!');

