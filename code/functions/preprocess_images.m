function preprocess_images(rawFolder, exif_path) % Add exif_path argument

% Photogrammetry image pre-processing workflow for COLOR Lab

% To run this script, there needs to be a folder called "raw" (lower case) that contains the
% raw images.
% You need to have Adobe DNG converter installed as a stand-alone
% application
% Updated by Richie Montes Lemus to take in exif_path

% Main operations

% 1) RAW--> DNG --> linear tiff

% 2) linear tiff --> contrast stretched JPG (same size)

% This script prepares a bunch of folders we will populate later
    folders = makeLocalFolders_pg(rawFolder);

    % Check how many raw images there are
    Nraw = dir(fullfile(folders.rawFolder));
    Nraw = Nraw(~[Nraw.isdir]);
    Nraw = remove_non_files(Nraw);

    % Check DNG numbers
    Ndng = dir(fullfile(folders.dngFolder));
    Ndng = Ndng(~[Ndng.isdir]);
    Ndng = remove_non_files(Ndng);

    if numel(Ndng) ~= numel(Nraw)
        % Convert RAW to DNG
        raw2dng_pg(folders);
    end

    % Check linear tiff numbers
    Ntiff = dir(fullfile(folders.uncorrectedTiffFolder));
    Ntiff = Ntiff(~[Ntiff.isdir]);

    if numel(Ntiff) ~= numel(Nraw)
        % Convert DNG to TIFF
        dng2tiff_pg(folders);
    end

    % Save contrast-stretched JPGs (now passing exif_path)
    contraststretchedjpgs_pg(folders, exif_path);

% % If we reached this point, all is good and we can save space by removing DNG and linear tiff to save space
% 
% fileList = dir(fullfile(folders.dngFolder, '*.dng')); 
% fileList = [fileList ; dir(fullfile(folders.uncorrectedTiffFolder, '*.tif'))]; 
% 
% % Filter out directories (to avoid deleting subdirectories)
% fileList = fileList(~[fileList.isdir]);
% 
% % Loop through each file and delete it
% for i = 1:length(fileList)
%     delete(fullfile(fileList(i).folder, fileList(i).name));
% end


% function preprocess_images(rawFolder)
% 
% % Photogrammetry image pre-processing workflow for COLOR Lab
% 
% % To run this script, there needs to be a folder called "raw" (lower case) that contains the
% % raw images.
% % You need to have Adobe DNG converter installed as a stand-alone
% % application
% 
% % Main operations
% 
% % 1) RAW--> DNG --> linear tiff
% 
% % 2) linear tiff --> contrast stretched JPG (same size)
% 
% % This script prepares a bunch of folders we will populate later
% folders = makeLocalFolders_pg(rawFolder);
% 
% % Check how many raw images there are
% Nraw = dir(fullfile(folders.rawFolder));
% Nraw = Nraw(~[Nraw.isdir]);
% 
% % Check DNG numbers
% Ndng = dir(fullfile(folders.dngFolder));
% Ndng = Ndng(~[Ndng.isdir]);
% 
% if numel(Ndng)~=numel(Nraw)
%     % Call the DNG converter to make DNG images
%     raw2dng_pg(folders);
% end
% 
% % Check linear tiff numbers
% Ntiff = dir(fullfile(folders.uncorrectedTiffFolder));
% Ntiff = Ntiff(~[Ntiff.isdir]);
% 
% if numel(Ntiff)~=numel(Nraw)
% 
%     % Now convert the images to linear tiffs -nice to have but too big and dark
%     dng2tiff_pg(folders)
% end
% 
% % Save contrast stretched JPGs - these are our inputs to photogrammetry
% contraststretchedjpgs_pg(folders)
% 
% % If we reached this point, all is good and we can save space by removing DNG and linear tiff to save space
% 
% % fileList = dir(fullfile(folders.dngFolder, '*.dng')); 
% fileList = [fileList ; dir(fullfile(folders.uncorrectedTiffFolder, '*.tif'))]; 
% 
% % Filter out directories (to avoid deleting subdirectories)
% fileList = fileList(~[fileList.isdir]);
% 
% % Loop through each file and delete it
% for i = 1:length(fileList)
%     delete(fullfile(fileList(i).folder, fileList(i).name));
% end
% 
