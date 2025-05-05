% function tiff2png(pngPath,tiffPath)
% 
% files = dir(fullfile(tiffPath,'*.tif'));
% 
% for i = 1:numel(files)
%     I = imread(fullfile(tiffPath,files(i).name));
%     imwrite(imresize(I,0.3),fullfile(pngPath,[files(i).name(1:end-4),'.png']))
% end
% 
% function tiff2png(pngPath, tiffPath)
%     files = dir(fullfile(tiffPath, '*.tif'));
% 
%     for i = 1:numel(files)
%         % Read TIFF
%         I = imread(fullfile(tiffPath, files(i).name));
% 
%         % Check if image is 16-bit or higher and convert to uint16 if needed
%         if isa(I, 'uint16')
%             imwrite(I, fullfile(pngPath, [files(i).name(1:end-4), '.png']), 'BitDepth', 16);
%         else
%             imwrite(I, fullfile(pngPath, [files(i).name(1:end-4), '.png']));
%         end
%     end
% end
% function tiff2png(pngPath, tiffPath)
% 
%     % Ensure output directory exists
%     if ~exist(pngPath, 'dir')
%         mkdir(pngPath);
%     end
% 
%     files = dir(fullfile(tiffPath, '*.tif'));
% 
%     for i = 1:numel(files)
%         % Read TIFF image
%         I = imread(fullfile(tiffPath, files(i).name));
% 
%         % Preserve intensity by normalizing if >8-bit
%         info = imfinfo(fullfile(tiffPath, files(i).name));
%         bitDepth = info.BitDepth;
% 
%         if bitDepth > 8  % Convert 16-bit/32-bit to 8-bit safely
%             I = mat2gray(I);  % Normalize to [0,1]
%             I = im2uint8(I);   % Convert to 8-bit uint
%         end
% 
%         % Resize image (optional, 30% of original size)
%         I_resized = imresize(I, 0.3);
% 
%         % Save as PNG with maximum lossless compression
%         imwrite(I_resized, fullfile(pngPath, [files(i).name(1:end-4), '.png']), 'png', 'BitDepth', 8);
% 
%         fprintf('Converted %s -> %s\n', files(i).name, [files(i).name(1:end-4), '.png']);
%     end
% 
%     fprintf('All TIFFs successfully converted to PNGs in %s\n', pngPath);
% end
% 
% function tiff2png(pngPath, tiffPath)
%     files = dir(fullfile(tiffPath, '*.tif'));
% 
%     for i = 1:numel(files)
%         I = imread(fullfile(tiffPath, files(i).name));
%         imwrite(I, fullfile(pngPath, [files(i).name(1:end-4), '.png']), 'BitDepth', 16);
%     end
% end

function tiff2png(pngPath, tiffPath)
    files = dir(fullfile(tiffPath, '*.tif'));

    for i = 1:numel(files)
        I = imread(fullfile(tiffPath, files(i).name));

        % Convert to 8-bit if not needed in 16-bit (reduces size but maintains quality)
        if isa(I, 'uint16')
            I = uint8(double(I) / 256);  % Scale down from 16-bit to 8-bit
        end

        % Save as PNG with optimized compression
        imwrite(I, fullfile(pngPath, [files(i).name(1:end-4), '.png']), 'BitDepth', 8, 'Compression', 'none');
    end
end
