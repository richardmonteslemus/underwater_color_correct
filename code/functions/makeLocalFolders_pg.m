function folders = makeLocalFolders_pg(rawFolder)

% For the purposes of photogrammetry, we create these folders to populate
% later

pathParts = strsplit(rawFolder,filesep);
rawFolderName = pathParts{end};

rootFolder = rawFolder(1:end-numel(rawFolderName));
dngFolder = fullfile(rootFolder,'dng');
depthMapFolder = fullfile(rootFolder,'depth');
contrastStretchedJpgFolder = fullfile(rootFolder,'contrastStretchedJpg');
uncorrectedTiffFolder = fullfile(rootFolder,'uncorrectedTiff');
masks = fullfile(rootFolder,'masks'); % For when we want to make blue water masks

% If these don't exist already, create them
if ~exist(dngFolder,'dir'); mkdir(dngFolder); end
if ~exist(depthMapFolder,'dir'); mkdir(depthMapFolder); end
if ~exist(contrastStretchedJpgFolder,'dir'); mkdir(contrastStretchedJpgFolder); end
if ~exist(uncorrectedTiffFolder,'dir'); mkdir(uncorrectedTiffFolder); end
if ~exist(masks,'dir'); mkdir(masks); end

folders.dngFolder = dngFolder;
folders.depthMapFolder = depthMapFolder;
folders.contrastStretchedJpgFolder = contrastStretchedJpgFolder;
folders.uncorrectedTiffFolder = uncorrectedTiffFolder;
folders.rawFolder = rawFolder;
folders.masks = masks;

