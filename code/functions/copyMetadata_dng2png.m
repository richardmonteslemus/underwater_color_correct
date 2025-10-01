
function copyMetadata_dng2png(dngPath, destinationPath, exif_path)
% COPYMETADATA_DNG2PNG Transfers metadata from DNG files to corresponding PNG files
%   Only applies metadata transfer if the matching PNG file exists.
%   Uses ExifTool to perform metadata copy.
%
%   Parameters:
%     dngPath         - Folder containing .dng files
%     destinationPath - Folder containing .png files
%     exif_path       - Full path to exiftool executable

    % Get all DNG files in the folder
    files = dir(fullfile(dngPath, '*.dng'));

    for i = 1:numel(files)
        % Full path of the DNG file
        dngFilePath = fullfile(dngPath, files(i).name);

        % Expected corresponding PNG path
        baseName = files(i).name(1:end-4);
        saveFilePath = fullfile(destinationPath, [baseName, '.png']);

        % Check if PNG exists before trying to copy metadata
        if ~isfile(saveFilePath)
            fprintf('Skipping %s — PNG file not found.\n', saveFilePath);
            continue;
        end

        % Construct ExifTool command for PNG metadata transfer
        command = strjoin({['"' exif_path '"'], ...
                           '-m -overwrite_original -tagsfromfile', ...
                           ['"' dngFilePath '"'], ...
                           '-all:all', ...
                           ['"' saveFilePath '"']});

        % Run system command to copy metadata
        status = system(command);

        % Error handling
        if status ~= 0
            fprintf(2, 'Error: Failed to copy metadata from %s to %s\n', ...
                dngFilePath, saveFilePath);
        end
    end

    fprintf('\nMetadata copying process completed for all matching files.\n');
end
