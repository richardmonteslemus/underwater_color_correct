function white_balance_png_linear_preserved(input_folder, output_folder, patch_rgb_path, selected_patch, Ref_expected)
    % Applies white balancing using a gray patch and saves 16-bit PNGs without clipping
    
    if ~exist(output_folder, 'dir')
        mkdir(output_folder);
    end

    % Load patch reflectance RGB values
    loaded_patch_rgb = load(patch_rgb_path);
    patch_rgb_table = loaded_patch_rgb.patch_rgb_table;

    R_measured = patch_rgb_table{selected_patch, 'Red'};
    G_measured = patch_rgb_table{selected_patch, 'Green'};
    B_measured = patch_rgb_table{selected_patch, 'Blue'};

    % Scaling factors
    w_r = Ref_expected / R_measured;
    w_g = Ref_expected / G_measured;
    w_b = Ref_expected / B_measured;

    fprintf('Scaling factors for %s: R=%.4f, G=%.4f, B=%.4f\n', selected_patch, w_r, w_g, w_b);

    % Get TIFF files
    image_files = dir(fullfile(input_folder, '*.tif'));

    for i = 1:length(image_files)
        img_name = image_files(i).name;
        img_path = fullfile(input_folder, img_name);
        I2 = im2double(imread(img_path));  % Read as double [0,1]

        % Apply white balance
        Y = zeros(size(I2));
        Y(:,:,1) = I2(:,:,1) * w_r;
        Y(:,:,2) = I2(:,:,2) * w_g;
        Y(:,:,3) = I2(:,:,3) * w_b;


        % Convert to 16-bit integer format
        Y_16 = uint16(Y * 65535);  % Linear scaling to 16-bit

        % Output name
        output_filename = [img_name(1:end-4), '.png'];
        output_path = fullfile(output_folder, output_filename);

        % Save as 16-bit PNG
        imwrite(Y_16, output_path, 'BitDepth', 16, 'Compression', 'none');

        fprintf('Saved: %s\n', output_filename);
    end

    disp('All images white-balanced and saved as 16-bit PNGs.');
end
