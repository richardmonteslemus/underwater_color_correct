
function saveImageData(mainfolder, savePath, exiftoolPath)
    % Optimized version using a single ExifTool call for speed

    % Get list of DNG files
    % files = [dir(fullfile(mainfolder, '*.dng')); dir(fullfile(mainfolder, '*.DNG'))];
    files = dir(fullfile(mainfolder, '*.dng'));
    if isempty(files)
        error('No .dng or .DNG images found in the specified folder.');
    end

    % === 1. Use ExifTool once to extract DateTimeOriginal for all files ===
    oldDir = pwd;
    cd(mainfolder);  % change to mainfolder to avoid full paths in output
    system(sprintf('"%s" -DateTimeOriginal -json *.dng *.DNG > temp_metadata.json', exiftoolPath));
    cd(oldDir);  % return to original directory

    % Read and parse JSON
    jsonPath = fullfile(mainfolder, 'temp_metadata.json');
    if ~isfile(jsonPath)
        error('ExifTool did not produce metadata JSON file.');
    end
    jsonText = fileread(jsonPath);
    exifData = jsondecode(jsonText);

    % Build a map from filename to DateTimeOriginal
    timeMap = containers.Map();
    for k = 1:numel(exifData)
        [~, name, ext] = fileparts(exifData(k).SourceFile);
        key = [name ext];  % e.g. '233A5730.dng'
        if isfield(exifData(k), 'DateTimeOriginal')
            timeMap(key) = exifData(k).DateTimeOriginal;
        end
    end

    % === 2. Write metadata to CSV ===
    fid = fopen(savePath, 'w');
    if fid == -1
        error('Could not open file: %s', savePath);
    end
    fprintf(fid, 'Filename,Time,ExposureTime,FNumber,ISO,Seconds_since_midnight\n');

    for i = 1:numel(files)
        filename = files(i).name;
        fullPath = fullfile(mainfolder, filename);

        % Look up time
        if ~isKey(timeMap, filename)
            warning('Missing DateTimeOriginal for %s. Skipping.', filename);
            continue;
        end
        time = timeMap(filename);

        % Get camera metadata using imfinfo
        info = imfinfo(fullPath);
        camInfo = info(1).DigitalCamera;

        exposure = camInfo.ExposureTime;
        fNumber = camInfo.FNumber;
        iso = camInfo.ISOSpeedRatings;

        % === Add Seconds_since_midnight column ===
        time_dt = datetime(time, 'InputFormat', 'yyyy:MM:dd HH:mm:ss');
        midnight = dateshift(time_dt, 'start', 'day');
        secondsSinceMidnight = seconds(time_dt - midnight);

        % Write to CSV
        fprintf(fid, '%s,%s,%.6f,%.1f,%d,%.0f\n', filename, time, exposure, fNumber, iso, secondsSinceMidnight);
    end

    fclose(fid);

    % Clean up temp file
    delete(jsonPath);

    fprintf('Metadata successfully saved to %s\n', savePath);
    % delete(fullfile(mainfolder_metadata, 'temp_metadata.json'));
end
