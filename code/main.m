% The main script to run the photogrammetry image pre-processing workflow
% Custom made for Neta!
% DA Feb 26, 2024
% Updated by Richie to ask user for inputs Feb, 27, 2025


clear;close;clc

%% Ask the user for the working directory path
default_workindir = fullfile('E:','Colorimetry', 'Color_correction_protocol','code');
fprintf('Default Working Directory is: %s\n', default_workindir);
workingdir = input('Enter the full path to the code folder (or press Enter to use default): ', 's');
if isempty(workingdir)
    workingdir = default_workindir;
end

% Check if the directory exists
if isfolder(workingdir)
    cd(workingdir)
    fprintf('Changed directory to: %s\n', workingdir);
else
    error('Invalid directory. Please check the path and try again.');
end

% Add all subfolders to path (important functions will be needed)
addpath(genpath('.'))

%% Ask user for the path of the folder with raw images we want to process.
% Answer questions in terminal to ensure this points to the right folder!
fprintf('\n')
user_raw_path = input('Enter the full path to the raw images folder: ', 's');
%formatted_rawpath = format_path(user_raw_path); % Use format_rawpath so reagrdless of the user input format it can be used in fullfile
% rawpath = fullfile(formatted_rawpath);  
[formatted_rawpath, rawpath] = format_path(user_raw_path);

%% Ask user for the exiftool path
fprintf('\n')
default_exif_path = fullfile('E:','Colorimetry','Color_correction_protocol','code','exiftool.exe');
fprintf('Default Exiftool Path is: %s\n', default_exif_path);
exif_path = input('Enter the full path to exiftool.exe (or press Enter to use default): ', 's');

% Use a default path if the user does not provide one
if isempty(exif_path)
    exif_path = default_exif_path;
end

% Verify if the file exists
while exist(exif_path, 'file') ~= 2
    fprintf('Invalid path. Please try again.\n');
    exif_path = input('Enter the full path to exiftool.exe: ', 's');
end


%% Create the preprocessed images (in JPG). These are the inputs to
% Agisoft. 
preprocess_images(rawpath, exif_path);

%% Save Image Metadata 
parent_rawpath =  rawpath;
mainfolder_metadata = fullfile(parent_rawpath,'dng');
savePath_metadata = fullfile(parent_rawpath,'metadata.csv');
saveImageData(mainfolder_metadata, savePath_metadata,exif_path);
