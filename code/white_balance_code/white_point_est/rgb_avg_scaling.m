% Set file paths
input_file = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wp_rgb_depth_bc_xyd.csv';
output_file = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wp_rgb_scale.csv';

% Load the data
rgb_scale_data = readtable(input_file);

% Set reflectance value for gray3
gray3_reflectance = 0.124;

% Compute scaling factors per image using gray3 values
R_wb_scaling = gray3_reflectance ./ rgb_scale_data.gray3_Red;
G_wb_scaling = gray3_reflectance ./ rgb_scale_data.gray3_Green;
B_wb_scaling = gray3_reflectance ./ rgb_scale_data.gray3_Blue;

% Append scaling columns
rgb_scale_data.R_wb_scaling = R_wb_scaling;
rgb_scale_data.G_wb_scaling = G_wb_scaling;
rgb_scale_data.B_wb_scaling = B_wb_scaling;

% Write updated table to new CSV
writetable(rgb_scale_data, output_file);

disp(['File saved as: ', output_file]);


% %% Join Metadata 
% % 
% scale_data = readtable('E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wp_rgb_scale.csv');
% metadata = readtable('E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\metadata.csv');
% 
% % Get base filename (strip extension) for matching
% [~, scale_base, ~] = cellfun(@fileparts, scale_data.Filename, 'UniformOutput', false);
% [~, meta_base, ~] = cellfun(@fileparts, metadata.Filename, 'UniformOutput', false);
% 
% % Add base name column for internal matching
% scale_data.BaseName = scale_base;
% metadata.BaseName = meta_base;
% 
% % Initialize metadata columns
% scale_data.Time=NaN(height(scale_data),1);
% scale_data.ExposureTime = NaN(height(scale_data), 1);
% scale_data.FNumber = NaN(height(scale_data), 1);
% scale_data.ISO = NaN(height(scale_data), 1);
% 
% % Match and assign metadata values
% [found, idx] = ismember(scale_data.BaseName, metadata.BaseName);
% scale_data.Time(found) = metadata.Time(idx(found));
% scale_data.ExposureTime(found) = metadata.ExposureTime(idx(found));
% scale_data.FNumber(found) = metadata.FNumber(idx(found));
% scale_data.ISO(found) = metadata.ISO(idx(found));
% 
% % Remove helper column
% scale_data.BaseName = [];
% 
% % Save updated file
% writetable(scale_data, 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wp_rgb_scale_with_metadata.csv');
% 
% disp('✅ Metadata attached and saved as wp_rgb_scale_with_metadata.csv');

% MATLAB script to merge data from metadata.csv into wp_rgb_scale.csv
% while preserving the original row order of wp_rgb_scale.csv.

%% Join Image Metadata 
% Define File Names 
wp_rgb_scale_file = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wp_rgb_scale.csv';
metadata_file = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\metadata.csv';
output_file = 'E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wp_rgb_scale_with_metadata.csv'; % Name for the merged output file

% Load the data into tables
% Read wp_rgb_scale.csv into a table
try
    tbl_rgb = readtable(wp_rgb_scale_file);
    disp(['Successfully loaded ' wp_rgb_scale_file]);
catch
    disp(['Error: Could not load ' wp_rgb_scale_file '. Please ensure it is in the current working directory.']);
    return; % Exit the script if file loading fails
end

% Read metadata.csv into a table
try
    tbl_metadata = readtable(metadata_file);
    disp(['Successfully loaded ' metadata_file]);
catch
    disp(['Error: Could not load ' metadata_file '. Please ensure it is in the current working directory.']);
    return; % Exit the script if file loading fails
end

% Preprocess 'Filename' columns to ensure matching keys
% The 'Filename' column in wp_rgb_scale.csv has '.tif' extension.
% The 'Filename' column in metadata.csv has '.dng' extension.
% We need to remove these extensions for a proper join based on the base filename.

% Convert 'Filename' columns to string arrays for easier manipulation if they are cell arrays of characters
if iscell(tbl_rgb.Filename)
    rgb_filenames_str = string(tbl_rgb.Filename);
else
    rgb_filenames_str = tbl_rgb.Filename;
end

if iscell(tbl_metadata.Filename)
    metadata_filenames_str = string(tbl_metadata.Filename);
else
    metadata_filenames_str = tbl_metadata.Filename;
end

% Remove file extensions (e.g., '.tif', '.dng')
tbl_rgb.Filename = cellstr(regexprep(rgb_filenames_str, '\.(tif)$', ''));
tbl_metadata.Filename = cellstr(regexprep(metadata_filenames_str, '\.(dng)$', ''));

disp('Processed Filename columns by removing extensions.');

% Join Metadata
% Use 'outerjoin' with 'Left' option to keep all rows from tbl_rgb
% and add matching metadata. If no match is found, metadata columns
% will be filled with NaN (for numeric) or <undefined> (for text).
% 'Keys' specifies the common column(s) for joining.
% 'MergeKeys', true ensures that the join key ('Filename') is only present once in the output table.

% Identify columns in tbl_metadata to join (all except 'Filename')
metadata_vars_to_add = tbl_metadata.Properties.VariableNames;
metadata_vars_to_add = metadata_vars_to_add(~strcmp(metadata_vars_to_add, 'Filename'));

% Perform the left join
% Ensure only the unique columns from metadata are added to avoid duplication
% by selecting specific variables from tbl_metadata after stripping the key.
tbl_merged = outerjoin(tbl_rgb, tbl_metadata(:, [{'Filename'} metadata_vars_to_add]), ...
                       'Keys', 'Filename', ...
                       'MergeKeys', true, ...
                       'Type', 'left');

disp('Preview of the merged table (first 5 rows and relevant columns):');
disp(head(tbl_merged(:, {'Filename', 'Time', 'ExposureTime', 'ISO', 'white_Red', 'white_Green'})));

% Save the merged table to a new CSV file
try
    writetable(tbl_merged, output_file);
    disp(['Merged data saved to: ' output_file]);
catch
    disp(['Error: Could not save the merged table to ' output_file '.']);
end

disp('Script execution complete.');

%% RGB Pixel Intensity Value Scaling Factor 
jitter_amount = 0.5;

% Red channel
figure;
scatter(rgb_scale_data.ColorChartNumber + (rand(size(rgb_scale_data.ColorChartNumber)) - 0.8) * jitter_amount, rgb_scale_data.gray3_Red, 'r', 'filled');
xlabel("ColorChartNumber");
ylabel("Red Pixel Intensity");
title('Red Channel PI per Color Chart');
grid on;
xticks(unique(rgb_scale_data.ColorChartNumber));

% Green channel
figure;
scatter(rgb_scale_data.ColorChartNumber + (rand(size(rgb_scale_data.ColorChartNumber)) - 0.8) * jitter_amount, rgb_scale_data.gray3_Green, 'g', 'filled');
xlabel("ColorChartNumber");
ylabel("Green Pixel Intensity");
title('Green Channel PI per Color Chart');
grid on;
xticks(unique(rgb_scale_data.ColorChartNumber));

% Blue channel
figure;
scatter(rgb_scale_data.ColorChartNumber + (rand(size(rgb_scale_data.ColorChartNumber)) - 0.8) * jitter_amount, rgb_scale_data.gray3_Blue, 'b', 'filled');
xlabel("ColorChartNumber");
ylabel("Blue Pixel Intensity");
title('Blue Channel PI per Color Chart');
grid on;
xticks(unique(rgb_scale_data.ColorChartNumber));

%% RGB WB Scaling Factor

% Red channel
figure;
scatter(rgb_scale_data.ColorChartNumber + (rand(size(rgb_scale_data.ColorChartNumber)) - 0.8) * jitter_amount, ...
        rgb_scale_data.R_wb_scaling, 'r', 'filled');
xlabel("ColorChartNumber");
ylabel("Red Pixel Intensity");
title('Red Channel Scaling per Color Chart');
grid on;
xticks(unique(rgb_scale_data.ColorChartNumber));

% Green channel
figure;
scatter(rgb_scale_data.ColorChartNumber + (rand(size(rgb_scale_data.ColorChartNumber)) - 0.8) * jitter_amount, ...
        rgb_scale_data.G_wb_scaling, 'g', 'filled');
xlabel("ColorChartNumber");
ylabel("Green Pixel Intensity");
title('Green Channel Scaling per Color Chart');
grid on;
xticks(unique(rgb_scale_data.ColorChartNumber));

% Blue channel
figure;
scatter(rgb_scale_data.ColorChartNumber + (rand(size(rgb_scale_data.ColorChartNumber)) - 0.8) * jitter_amount, ...
        rgb_scale_data.B_wb_scaling, 'b', 'filled');
xlabel("ColorChartNumber");
ylabel("Blue Pixel Intensity");
title('Blue Channel Scaling per Color Chart');
grid on;
xticks(unique(rgb_scale_data.ColorChartNumber));
