function writeDNGFilesToCSV(folderPath, savePath)
    % Get folder name from the folder path
    [~, folderName] = fileparts(folderPath); 
    
    % Get all DNG files in the folder
    files = dir(fullfile(folderPath, '*.DNG'));
    files = remove_non_files(files); % Ensure only files are kept

    % Extract file names
    fileNames = {files.name}'; % Convert to column cell array

    % Create a column of zeros with the same length as fileNames
    colorChart = zeros(length(fileNames), 1);

    % Convert to table with two columns
    fileTable = table(fileNames, colorChart, 'VariableNames', {'FileName', 'ColorChart'});

    % Define output CSV file name with folder name
    csvFileName = strcat(folderName, '_color_charts.csv');
    csvFilePath = fullfile(savePath, csvFileName);

    % Write to CSV
    writetable(fileTable, csvFilePath);
end
