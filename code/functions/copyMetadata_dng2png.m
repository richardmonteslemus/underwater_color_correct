function copyMetadata_dng2png(dngPath, destinationPath)

% Get all DNG files in the folder
files = dir(fullfile(dngPath, '*.dng'));

% Define path to ExifTool
exif_path = fullfile('C:', 'Users', 'colorlab', 'Richard_lemus', 'stri_bleaching_project_local', 's1_depth_maps', 'code', 'exiftool.exe');

for i = 1:numel(files)
    % Full path of the DNG file
    dngFilePath = fullfile(dngPath, files(i).name);
    
    % Change destination file extension to .png instead of .tif
    saveFilePath = fullfile(destinationPath, [files(i).name(1:end-4), '.png']);
    
    % Construct ExifTool command for PNG metadata transfer
    command = strjoin({['"' exif_path '"'], ' -m -overwrite_original -tagsfromfile ', char(dngFilePath), ' -all:all ', char(saveFilePath)});
    
    % Run system command to copy metadata
    status = system(command);
    
    % Error handling
    if status ~= 0
        fprintf(2, 'Error: Failed to copy metadata from %s to %s\n', dngFilePath, saveFilePath);
    end
end

fprintf('\nMetadata copying process completed for all files.\n');

end
