% The main script to run the photogrammetry image pre-processing workflow
% Custom made for Neta!
% DA Feb 26, 2024
% Updated by Richie to ask user for inputs Feb, 27, 2025


clear;close;clc

%% Ask the user for the working directory path
default_workindir = fullfile('C:', 'Users', 'colorlab', 'Richard_lemus', 'stri_bleaching_project_local', 'Sea_Thru_Protocol', 'code');
fprintf('Default Working Directory is: %s\n', default_workindir);
workingdir = input('Enter the full path to exiftool.exe (or press Enter to use default): ', 's');
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
default_exif_path = fullfile('C:', 'Users', 'colorlab', 'Richard_lemus', 'stri_bleaching_project_local', 'Sea_Thru_Protocol', 'code', 'exiftool.exe');
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

%% Save Image Exposure Metadata 
parent_rawpath =  fileparts(rawpath);
mainfolder_metadata = fullfile(parent_rawpath,'dng');
savePath_metadata = fullfile(parent_rawpath,'metadata.csv');

saveImageData(mainfolder_metadata, savePath_metadata);

%% The main script to run the photogrammetry image pre-processing workflow
% Custom made for Neta!
% DA Feb 26, 2024

% The main script to run the photogrammetry image pre-processing workflow,
% edited to automatically go through a directory assigned to rootdir and
% one by one look for folders labeled "raw". After its found a raw folder it
% runs the preprocess_images function on it and moves on to the next raw
% folder until it has finished processing all of them in the given
% directory. 
% Script modified from the original version by Derya Akkaynak.
% Updated to recursively search for raw folders and process them by Richie.

% 
% 
% % Define the root directory to search for 'raw' folders
% rootdir = 'D:';
% 
% % Find all folders named 'raw' recursively
% rawFolders = findRawFolders(rootdir);
% 
% % Check if any 'raw' folders were found
% if isempty(rawFolders)
%     disp('No folders named "raw" were found.');
%     return;
% end
% 
% % Display the list of 'raw' folders found
% disp('List of raw folders found:');
% disp(rawFolders);
% 
% % Process each 'raw' folder
% for i = 1:length(rawFolders)
%     % Clear all variables except 'rawFolders', 'rootdir', and i , close figures, and clear command window
%     clearvars -except rawFolders rootdir i; close all; clc;
% 
%     % Get the current 'raw' folder path
%     rawpath = rawFolders{i};
%     fprintf('Processing folder: %s\n', rawpath);
% 
%     % This is where the code is
%     workingdir = "C:\Users\colorlab.IUI\stri_bleaching_project_local\s1_depth_maps\code";
%     cd(workingdir);
% 
%     % Add all subfolders to the path
%     addpath(genpath('.'));
% 
%     % Preprocess the images in the current 'raw' folder
%     preprocess_images(rawpath);
% 
%     fprintf('Finished processing folder: %s\n', rawpath);
% end
% 
% disp('All folders processed.');
% 
% % Function to find all folders named 'raw' recursively
% function rawFolders = findRawFolders(rootdir)
%     % Initialize a cell array to store paths to 'raw' folders
%     rawFolders = {};
% 
%     % Get all files and folders in the root directory
%     files = dir(rootdir);
% 
%     % Loop through each item
%     for k = 1:length(files)
%         % Skip '.' and '..' entries
%         if strcmp(files(k).name, '.') || strcmp(files(k).name, '..')
%             continue;
%         end
% 
%         % If the item is a folder
%         if files(k).isdir
%             % Construct the full path
%             fullpath = fullfile(files(k).folder, files(k).name);
% 
%             % If the folder is named 'raw', add it to the list
%             if strcmp(files(k).name, 'raw')
%                 rawFolders{end+1} = fullpath;
%             else
%                 % Recursively search subdirectories
%                 subdirRawFolders = findRawFolders(fullpath);
%                 rawFolders = [rawFolders, subdirRawFolders];
%             end
%         end
%     end
% end