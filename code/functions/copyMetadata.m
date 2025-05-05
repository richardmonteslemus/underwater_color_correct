function copyMetadata(dngPath,destinationPath)

% copies metadata from a folder of dng images to a folder of jpg images
files = dir(fullfile(dngPath,'*.dng'));
% files = remove_non_files(files);

% exif_path = fullfile('C:', 'Users', 'colorlab.IUI', 'stri_bleaching_project_local', 's1_depth_maps', 'code', 'exiftool.exe');
exif_path = fullfile('C:','Program Files', 'exiftool','exiftool.exe');
for i = 1:numel(files)
    dngFilePath = fullfile(dngPath,files(i).name);
    saveFilePath = fullfile(destinationPath,[files(i).name(1:end-4),'.jpg']);
    % command = strjoin({exif_path,' -m -overwrite_original -tagsfromfile ',dngFilePath,' -all:all ', saveFilePath});
    command = strjoin({['"' exif_path '"'],' -m -overwrite_original -tagsfromfile ',char(dngFilePath),' -all:all ', char(saveFilePath)});
    status = system(command);
end

% command = ['/usr/local/bin/exiftool -m -overwrite_original -tagsfromfile "',dngFilePath,'" -all:all "', saveFilePath, '"'];
% "C:\Users\colorlab.IUI\stri_bleaching_project_local\s1_depth_maps\code\exiftool.exe"

% fullfile('C:', 'Users', 'colorlab.IUI', 'stri_bleaching_project_local', 's1_depth_maps', 'code', 'exiftool.exe')