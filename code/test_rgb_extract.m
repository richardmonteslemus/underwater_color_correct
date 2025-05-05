% % Step 1: Load and display the PNG image
% [img, ~, alpha] = imread('C:\Users\monteslemusra\OneDrive - Smithsonian Institution\Pictures\Screenshots\example_ortho.png'); % Load image with transparency if it exists
% imshow(img);
% title('Select a region');
% 
% % Step 2: Select a region (rectangle) interactively
% roi = drawrectangle; % User selects a region
% position = round(roi.Position); % Get rectangle position [x, y, width, height]
% 
% % Step 3: Extract the region's RGB values
% x1 = position(1); y1 = position(2);
% width = position(3); height = position(4);
% region = img(y1:y1+height-1, x1:x1+width-1, :); % Extract RGB region
% 
% % Step 4: Handle transparency (if alpha exists)
% if ~isempty(alpha) % If there is an alpha channel
%     alpha_region = alpha(y1:y1+height-1, x1:x1+width-1); % Extract alpha values
%     mask = alpha_region > 0; % Create a mask for non-transparent pixels
%     if any(mask(:)) % Check if there are non-transparent pixels
%         % Compute mean only for non-transparent pixels
%         avgColor = sum(sum(double(region) .* mask, 1), 2) ./ sum(mask(:));
%     else
%         avgColor = [255, 255, 255]; % Default to white if fully transparent
%     end
% else
%     avgColor = mean(mean(region, 1), 2); % Compute mean across both dimensions
% end
% 
% avgColor = uint8(squeeze(avgColor)); % Convert to uint8
% 
% % Step 5: Display the extracted color
% figure;
% rectangle('Position',[0 0 100 100], 'FaceColor', double(avgColor) / 255, 'EdgeColor', 'none');
% xlim([0 100]); ylim([0 100]);
% axis off;
% title(sprintf('Extracted Color: R=%d, G=%d, B=%d', avgColor(1), avgColor(2), avgColor(3)));
% Step 1: Read in the PNG image
img = imread('E:\Colorimetry\Photos\Perlas\Contadora_28_August_2023\Contadora_28_Aug_2023_0to25\wb_png\233A5731.png'); % Replace with your image file path

% Step 2: Brighten the image by increasing pixel intensity values
brightness_factor = 2; % Increase brightness by 20% (you can adjust this value)
brightened_img = img * brightness_factor;

% Step 3: Clip any values greater than 255 (for uint8 images)
brightened_img = min(brightened_img, 255); % Ensure pixel values do not exceed 255

% Step 4: Convert to uint8 (if the image was uint8)
brightened_img = uint8(brightened_img);

imwrite(brightened_img, 'brightened_image.png'); % Save as PNG (change file name/path if needed)

% Step 5: Display the original and brightened images
subplot(1, 2, 1);
imshow(img);
title('Original Image');

subplot(1, 2, 2);
imshow(brightened_img);
title('Brightened Image');
