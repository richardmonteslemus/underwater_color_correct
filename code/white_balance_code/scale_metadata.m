
%% Scaling and Metadata Script 
% The following script produces a white balance scaling factor for every
% image, attaches metadata, and the color chart number.

%%
clear all; close all; clc;

%% Set which gray patch to use
patch_selected = 'gray3';  % Change this to 'gray4' or another patch as needed
reflectance = 0.40;
savePath = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25';
if ~isfolder(savePath)
    mkdir(savePath);
end

%% Define the first high pass image filename
Highpass_filename = '233A6716';

%% File paths
input_file     = fullfile(savePath, 'rgb_depth_bc.csv');
metadata_file  = fullfile(savePath, 'metadata.csv');
chart_file     = fullfile(savePath, 'selected_color_charts.csv');
final_file     = fullfile(savePath, 'rgb_scale_with_metadata.csv');
filtered_output_file = fullfile(savePath,'wb_scale_with_metadata.csv');

%% Load base RGB-Depth-BC table
rgb_data = readtable(input_file);

% Build column names dynamically
red_col   = sprintf('%s_Red',   patch_selected);
green_col = sprintf('%s_Green', patch_selected);
blue_col  = sprintf('%s_Blue',  patch_selected);

% Compute white balance scaling factors dynamically
rgb_data.R_wb_scaling = reflectance ./ rgb_data.(red_col);
rgb_data.G_wb_scaling = reflectance ./ rgb_data.(green_col);
rgb_data.B_wb_scaling = reflectance ./ rgb_data.(blue_col);

%% Load and clean metadata and color chart files
tbl_rgb = rgb_data;
tbl_metadata = readtable(metadata_file);
tbl_chart = readtable(chart_file);

tbl_rgb.Filename      = erase(string(tbl_rgb.Filename), '.tif');
tbl_metadata.Filename = erase(string(tbl_metadata.Filename), '.dng');
tbl_chart.FileName    = erase(string(tbl_chart.FileName), '.tif');
tbl_chart.Properties.VariableNames{'FileName'} = 'Filename';

%% Merge with metadata
metadata_vars = setdiff(tbl_metadata.Properties.VariableNames, {'Filename'});
tbl_merged = outerjoin(tbl_rgb, tbl_metadata(:, [{'Filename'}, metadata_vars]), ...
    'Keys', 'Filename', 'MergeKeys', true, 'Type', 'left');

%% Merge with chart number
tbl_merged = outerjoin(tbl_merged, tbl_chart(:, {'Filename', 'ColorChartNumber'}), ...
    'Keys', 'Filename', 'MergeKeys', true, 'Type', 'left');

writetable(tbl_merged, final_file);
disp(['Saved final merged table to: ', final_file]);

%% Plotting
jitter_amount = 0.5;

% Intensity plots
colors = {'Red', 'Green', 'Blue'};
for c = 1:length(colors)
    figure;
    colname = sprintf('%s_%s', patch_selected, colors{c});
    scatter(tbl_merged.ColorChartNumber + (rand(size(tbl_merged.ColorChartNumber)) - 0.8) * jitter_amount, ...
            tbl_merged.(colname), lower(colors{c}(1)), 'filled');
    xlabel("ColorChartNumber");
    ylabel(sprintf('%s Pixel Intensity', colors{c}));
    title(sprintf('%s Channel PI per Color Chart', colors{c}));
    grid on;
    xticks(unique(tbl_merged.ColorChartNumber));
end

% Scaling plots
for c = 1:length(colors)
    figure;
    colname = sprintf('%s_wb_scaling', colors{c}(1)); % R_wb_scaling, G_wb_scaling, B_wb_scaling
    scatter(tbl_merged.ColorChartNumber + (rand(size(tbl_merged.ColorChartNumber)) - 0.8) * jitter_amount, ...
            tbl_merged.(colname), lower(colors{c}(1)), 'filled');
    xlabel("ColorChartNumber");
    ylabel(sprintf('%s Scaling Factor', colors{c}));
    title(sprintf('%s Channel Scaling per Color Chart', colors{c}));
    grid on;
    xticks(unique(tbl_merged.ColorChartNumber));
end
%% Create CSV file with White Balance Scaling Factors only for images used to White Balance 

% Make sure Filename is a string column (just in case it's not)
tbl_metadata.Filename = string(tbl_metadata.Filename);

% Find the row for the specified filename
row_idx = find(tbl_metadata.Filename == Highpass_filename, 1);

% Check if image was found
if isempty(row_idx)
    error('Filename %s not found in the table.', Highpass_filename);
end

% Get the reference Seconds_since_midnight value
cutoff_time = tbl_metadata.Seconds_since_midnight(row_idx);

% Filter table: only keep rows taken before the overpass image
filtered_tbl = tbl_merged(tbl_merged.Seconds_since_midnight < cutoff_time, :);

% Save the result to CSV
writetable(filtered_tbl, filtered_output_file);
disp(['Filtered table saved to: ', filtered_output_file]);



