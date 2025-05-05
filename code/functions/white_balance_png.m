% function white_balance_png(input_folder, output_folder, patch_rgb_path, selected_patch, Ref_expected)
%     % WHITE_BALANCE_TIFF applies white balancing to all TIFF images in a folder
%     % and saves them as PNG files while preserving precision.
%     %
%     % Parameters:
%     %   input_folder  - Path to the folder containing uncorrected TIFF images
%     %   output_folder - Path to the folder where white-balanced PNG images will be saved
%     %   patch_rgb_path - Path to the .mat file containing the patch RGB table
%     %   selected_patch - Name of the patch used for white balancing (e.g., 'gray3')
%     %   Ref_expected  - Expected reflectance for the selected patch (e.g., 0.40)
% 
%     % Create the output folder if it doesn't exist
%     if ~exist(output_folder, 'dir')
%         mkdir(output_folder);
%     end
% 
%     % Load the .mat file containing the patch RGB table
%     loaded_patch_rgb = load(patch_rgb_path);
%     patch_rgb_table = loaded_patch_rgb.patch_rgb_table;
% 
%     % Extract the measured RGB values for the selected patch
%     R_measured = patch_rgb_table{selected_patch, 'Red'};
%     G_measured = patch_rgb_table{selected_patch, 'Green'};
%     B_measured = patch_rgb_table{selected_patch, 'Blue'};
% 
%     % Compute scaling factors for white balancing
%     w_r = Ref_expected / R_measured;
%     w_g = Ref_expected / G_measured;
%     w_b = Ref_expected / B_measured;
% 
%     % Display scaling factors
%     fprintf('Scaling factors for %s: R=%.4f, G=%.4f, B=%.4f\n', selected_patch, w_r, w_g, w_b);
% 
%     % Get a list of all TIFF images in the input folder
%     image_files = dir(fullfile(input_folder, '*.tif'));
% 
%     % Loop through each image in the folder
%     for i = 1:length(image_files)
%         % Read the image
%         img_name = image_files(i).name;
%         img_path = fullfile(input_folder, img_name);
%         I2 = im2double(imread(img_path)); % Convert to double for calculations
% 
%         % Apply white balancing
%         Y(:,:,1) = I2(:,:,1) * w_r; % Scale red channel
%         Y(:,:,2) = I2(:,:,2) * w_g; % Scale green channel
%         Y(:,:,3) = I2(:,:,3) * w_b; % Scale blue channel
% 
%         % Convert to 8-bit if original is 16-bit
%         if isa(I2, 'uint16')
%             Y = uint8(Y * 255);  % Scale to 8-bit range
%         else
%             Y = im2uint8(Y);  % Convert to 8-bit preserving details
%         end
% % VERIFY REFLECTANCE VALUE
% 
%         figure;
%         subplot(1,2,1);
%         imshow(I2);
%         title(['Original Image: ', img_name], 'Interpreter', 'none');
% 
%         subplot(1,2,2);
%         imshow(Y);
%         title(['White Balanced Image: ', img_name], 'Interpreter', 'none');
% 
%         % Pause to allow viewing before moving to the next image
%         pause(1); % Adjust timing as needed
% 
%         % Define output file path with .png extension
%         output_filename = [img_name(1:end-4), '.png'];
%         output_path = fullfile(output_folder, output_filename);
% 
%         % Save as PNG with optimized compression
%         imwrite(Y, output_path, 'BitDepth', 8, 'Compression', 'none');
% 
%         % Display progress
%         fprintf('Processed and saved: %s\n', output_filename);
%     end
% 
%     disp('White balancing complete for all images, saved as PNG.');
% end

% function white_balance_png(input_folder, output_folder, patch_rgb_path, selected_patch, Ref_expected)
%     % WHITE_BALANCE_TIFF applies white balancing to all TIFF images in a folder
%     % and saves them as PNG files while preserving precision.
% 
%     % Create the output folder if it doesn't exist
%     if ~exist(output_folder, 'dir')
%         mkdir(output_folder);
%     end
% 
%     % Load the .mat file containing the patch RGB table
%     loaded_patch_rgb = load(patch_rgb_path);
%     patch_rgb_table = loaded_patch_rgb.patch_rgb_table;
% 
%     % Check if the table is loaded correctly
%     if isempty(patch_rgb_table)
%         error('Error: patch_rgb_table is empty. Check patch_rgb_path.');
%     end
% 
%     % Extract the measured RGB values for the selected patch
%     R_measured = patch_rgb_table{selected_patch, 'Red'};
%     G_measured = patch_rgb_table{selected_patch, 'Green'};
%     B_measured = patch_rgb_table{selected_patch, 'Blue'};
% 
%     % Compute scaling factors for white balancing
%     w_r = Ref_expected / R_measured;
%     w_g = Ref_expected / G_measured;
%     w_b = Ref_expected / B_measured;
% 
%     % Display scaling factors
%     fprintf('Scaling factors for %s: R=%.4f, G=%.4f, B=%.4f\n', selected_patch, w_r, w_g, w_b);
% 
%     % Get a list of all TIFF images in the input folder
%     image_files = dir(fullfile(input_folder, '*.tif'));
% 
%     % Loop through each image in the folder
%     for i = 1:length(image_files)
%         % Read the image
%         img_name = image_files(i).name;
%         img_path = fullfile(input_folder, img_name);
%         I2 = im2double(imread(img_path)); % Convert to double for calculations
% 
%         % Ensure the image is correctly read
%         if isempty(I2)
%             fprintf('Skipping %s (could not read image)\n', img_name);
%             continue;
%         end
% 
%         % Apply white balancing
%         Y(:,:,1) = I2(:,:,1) * w_r; % Scale red channel
%         Y(:,:,2) = I2(:,:,2) * w_g; % Scale green channel
%         Y(:,:,3) = I2(:,:,3) * w_b; % Scale blue channel
% 
%         % Clip values to ensure they remain in the valid range [0,1]
%         Y = max(0, min(1, Y));
% 
%         % Convert to 8-bit
%         Y = im2uint8(Y);
% 
%         % Display original and processed images for debugging
%         figure;
%         subplot(1,2,1);
%         imshow(I2);
%         title(['Original Image: ', img_name], 'Interpreter', 'none');
% 
%         subplot(1,2,2);
%         imshow(Y);
%         title(['White Balanced Image: ', img_name], 'Interpreter', 'none');
% 
%         % Pause to allow viewing before moving to the next image
%         pause(1); % Adjust timing as needed
% 
%         % Define output file path with .png extension
%         output_filename = [img_name(1:end-4), '.png'];
%         output_path = fullfile(output_folder, output_filename);
% 
%         % Save as PNG with optimized compression
%         imwrite(Y, output_path, 'BitDepth', 8, 'Compression', 'none');
% 
%         % Display progress
%         fprintf('Processed and saved: %s\n', output_filename);
%     end
% 
%     disp('White balancing complete for all images, saved as PNG.');
% end
function white_balance_png(input_folder, output_folder, patch_rgb_path, selected_patch, Ref_expected)
    % WHITE_BALANCE_PNG applies white balancing to all TIFF images in a folder
    % and saves them as PNG files while preserving precision.
    %
    % Parameters:
    %   input_folder  - Path to the folder containing uncorrected TIFF images
    %   output_folder - Path to the folder where white-balanced PNG images will be saved
    %   patch_rgb_path - Path to the .mat file containing the patch RGB table
    %   selected_patch - Name of the patch used for white balancing (e.g., 'gray3')
    %   Ref_expected  - Expected reflectance for the selected patch (e.g., 0.40)

    % Create the output folder if it doesn't exist
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Load the .mat file containing the patch RGB table
    loaded_patch_rgb = load(patch_rgb_path);
    patch_rgb_table = loaded_patch_rgb.patch_rgb_table;

    % Extract the measured RGB values for the selected patch
    R_measured = patch_rgb_table{selected_patch, 'Red'};
    G_measured = patch_rgb_table{selected_patch, 'Green'};
    B_measured = patch_rgb_table{selected_patch, 'Blue'};

    % Compute scaling factors for white balancing
    w_r = Ref_expected / R_measured;
    w_g = Ref_expected / G_measured;
    w_b = Ref_expected / B_measured;

    % Display scaling factors
    fprintf('Scaling factors for %s: R=%.4f, G=%.4f, B=%.4f\n', selected_patch, w_r, w_g, w_b);

    % Get a list of all TIFF images in the input folder
    image_files = dir(fullfile(input_folder, '*.tif'));

    % Loop through each image in the folder
    for i = 1:length(image_files)
        % Read the image and convert to double for calculations
        img_name = image_files(i).name;
        img_path = fullfile(input_folder, img_name);
        I2 = im2double(imread(img_path));

        % Preallocate the output image to ensure each loop iteration starts fresh
        Y = zeros(size(I2));

        % Apply white balancing
        Y(:,:,1) = I2(:,:,1) * w_r; % Scale red channel
        Y(:,:,2) = I2(:,:,2) * w_g; % Scale green channel
        Y(:,:,3) = I2(:,:,3) * w_b; % Scale blue channel

        % Convert to 8-bit preserving details
        Y = im2uint8(Y);

        % % VERIFY REFLECTANCE VALUE
        % figure;
        % subplot(1,2,1);
        % imshow(I2);
        % title(['Original Image: ', img_name], 'Interpreter', 'none');
        % 
        % subplot(1,2,2);
        % imshow(Y);
        % title(['White Balanced Image: ', img_name], 'Interpreter', 'none');
        % 
        % % Pause to allow viewing before moving to the next image
        % pause(1); % Adjust timing as needed

        % Define output file path with .png extension
        output_filename = [img_name(1:end-4), '.png'];
        output_path = fullfile(output_folder, output_filename);

        % Save as PNG with optimized compression
        imwrite(Y, output_path, 'BitDepth', 8, 'Compression', 'none');

        % Display progress
        fprintf('Processed and saved: %s\n', output_filename);
    end

    disp('White balancing complete for all images, saved as PNG.');
end

% 
% 
% function white_balance_png(input_folder, output_folder, patch_rgb_path, selected_patch, Ref_expected)
%     % WHITE_BALANCE_PNG applies white balancing to all PNG images in a folder.
%     %
%     % Parameters:
%     %   input_folder  - Path to the folder containing uncorrected PNG images
%     %   output_folder - Path to the folder where white-balanced images will be saved
%     %   patch_rgb_path - Path to the .mat file containing the patch RGB table
%     %   selected_patch - Name of the patch used for white balancing (e.g., 'gray3')
%     %   Ref_expected  - Expected reflectance for the selected patch (e.g., 0.40)
%     %
%     % Example:
%     %   white_balance_png('E:\input', 'E:\output', 'E:\patch_rgb.mat', 'gray3', 0.40);
% 
%     % Create output folder if it doesn't exist
%     if ~exist(output_folder, 'dir')
%         mkdir(output_folder);
%     end
% 
%     % Load the .mat file containing the patch RGB table
%     loaded_patch_rgb = load(patch_rgb_path);
%     patch_rgb_table = loaded_patch_rgb.patch_rgb_table;
% 
%     % Extract the measured RGB values for the selected patch
%     R_measured = patch_rgb_table{selected_patch, 'Red'};
%     G_measured = patch_rgb_table{selected_patch, 'Green'};
%     B_measured = patch_rgb_table{selected_patch, 'Blue'};
% 
%     % Compute scaling factors for white balancing (same for all images)
%     w_r = Ref_expected / R_measured;
%     w_g = Ref_expected / G_measured;
%     w_b = Ref_expected / B_measured;
% 
%     % Display scaling factors
%     fprintf('Scaling factors for %s: R=%.4f, G=%.4f, B=%.4f\n', selected_patch, w_r, w_g, w_b);
% 
%     % Get a list of all PNG images in the input folder
%     image_files = dir(fullfile(input_folder, '*.png'));
% 
%     % Loop through each image in the folder
%     for i = 1:length(image_files)
%         % Read the image
%         img_name = image_files(i).name;
%         img_path = fullfile(input_folder, img_name);
%         I2 = im2double(imread(img_path)); % Convert to double for calculations
% 
%         % Apply white balancing using precomputed scaling factors
%         Y = zeros(size(I2)); % Preallocate memory
%         Y(:,:,1) = I2(:,:,1) * w_r; % Scale red channel
%         Y(:,:,2) = I2(:,:,2) * w_g; % Scale green channel
%         Y(:,:,3) = I2(:,:,3) * w_b; % Scale blue channel
% 
%         % Clip values to [0,1] to prevent overflow when saving as PNG
%         Y = min(Y, 1);
% 
%         % Define output file path
%         output_path = fullfile(output_folder, img_name);
% 
%         % Save the white-balanced image
%         imwrite(Y, output_path);
% 
%         % Display progress
%         fprintf('Processed and saved: %s\n', img_name);
%     end
% 
%     disp('White balancing complete for all images.');
% end
