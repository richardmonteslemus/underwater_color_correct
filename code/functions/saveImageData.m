%% New function requiring less inputs, but outputting same results as Old Function but outputting a CSV file

function saveImageData(mainfolder, savePath)
    % Get a list of only .dng images in the folder
    files = dir(fullfile(mainfolder, '*.dng'));

    % Check if there are any .dng images
    if isempty(files)
        error('No .dng images found in the specified folder.');
    end

    % Open the CSV file for writing
    fid = fopen(savePath, 'w+');

    % Write CSV header
    fprintf(fid, 'Filename,ExposureTime,FNumber,ISO\n');

    for i = 1:numel(files)
        info = imfinfo(fullfile(mainfolder, files(i).name));
        exposure = info(1).DigitalCamera.ExposureTime;
        f = info(1).DigitalCamera.FNumber;
        iso = info(1).DigitalCamera.ISOSpeedRatings;

        % Write data as a CSV row
        fprintf(fid, '%s,%.6f,%.1f,%d\n', files(i).name, exposure, f, iso);
    end

    fclose(fid);
    fprintf('Metadata successfully saved to %s\n', savePath);
end


%% Examples of how to use functions
% 
%% New Function 
% mainfolder_metadata = 'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\dng';
% savePath_metadata = 'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\metadata.csv';
% 
% saveImageData(mainfolder_metadata, savePath_metadata);

%% Old function requiring more inputs and outputting TXT file 
% function saveImageData(mainfolder,files,savePath)
% 
% fid = fopen(savePath,'w+');
% 
% for i = 1:numel(files)
%     info = imfinfo(fullfile(mainfolder,files(i).name));
%     exposure = info(1).DigitalCamera.ExposureTime;
%     f = info(1).DigitalCamera.FNumber;
%     iso = info(1).DigitalCamera.ISOSpeedRatings;
%     fprintf(fid,[files(i).name,'\t',num2str(exposure),'\t',num2str(f),'\t',num2str(iso),'\n']);
% end
% 
% fclose(fid);

%% Old Function
% % Define the folder containing the DNG images
% mainfolder_metadata = 'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\dng';
% 
% % Get a list of all DNG files in the folder
% files_metadata = dir(fullfile(mainfolder_metadata, '*.dng'));
% 
% % Define the path where you want to save the CSV file
% savePath_metadata = 'E:\Colorimetry\Photos\Coiba\Canales_15_January_2024\Canales_15_January_2024_0to25\dng_creation\metadata_2.txt';
% 
% % Call the function with the required inputs
% saveImageData(mainfolder_metadata, files_metadata, savePath_metadata);
