% clear; close all; clc
% %%
% I_depth_name = '233A5900.tif';
% I_depth_base = "E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\depth";
% I_depth_path = fullfile(I_depth_base, I_depth_name);
% 
% I_depth = imread(I_depth_path)
% 
% figure;
% imagesc(I_depth);
% colorbar;
% title(sprintf("Depth Map: %s", I_depth_name), 'Interpreter', 'none');

close all; clc;
%%
I_depth_name = '233A5779.tif';
I_depth_base = "E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\depth";
I_depth_path = fullfile(I_depth_base, I_depth_name);

I_depth = imread(I_depth_path);

% Get image size
[img_height, img_width, ~] = size(I_depth);

% Define max figure size (adjust based on your screen resolution)
max_fig_width = 800;  % Max width for display
max_fig_height = 600; % Max height for display

% Compute scale factor based on max dimensions
scale_factor = min([max_fig_width / img_width, max_fig_height / img_height, 1]); 

% Compute new figure size
fig_width = img_width * scale_factor;
fig_height = img_height * scale_factor;

% Create figure with controlled size
figure('Position', [100, 100, fig_width, fig_height]);

imagesc(I_depth);
axis image; % Preserve aspect ratio
colorbar;
title(sprintf("Depth Map: %s", I_depth_name), 'Interpreter', 'none');
