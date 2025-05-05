function avgDepth = getOverallMeanDepth(I, masks, locs, colors)
%
% AVGDEPTH = GETOVERALLMEANDEPTH(I, MASKS, LOCS, COLORS)
% 
% I         : Input depth map image (NxM, single-channel TIFF).
% MASKS     : Struct containing multiple masks.
% LOCS      : Row and column positions of patches of interest.
% COLORS    : Cell array containing the names or numbers of the patches.
% 
% AVGDEPTH  : Single mean depth value across the selected masks.
%

numMasks = size(locs,1); % Number of masks to use
depthValues = [];        % Initialize an empty array to store depth values
depthLayer = double(I);  % Convert depth image to double precision

% Extract depth values for the specified patches
for i = 1:numMasks
    maskName = colors{locs(i,1), locs(i,2)}; % Get mask name from colors and locs

    if isfield(masks, maskName) % Check if the mask exists
        mask = masks.(maskName).mask;  % Extract binary mask

        if sum(mask(:)) ~= 0  % Ensure the mask is not empty
            depthValues = [depthValues; depthLayer(mask)]; % Append masked values
        end
    else
        warning('Mask "%s" not found in the provided masks.', maskName);
    end
end

% Compute mean depth across selected masks
if ~isempty(depthValues)
    avgDepth = mean(depthValues);
else
    avgDepth = NaN;  % If no masks contained depth values, return NaN
end

end

% 
% 
% function avgDepth = getOverallMeanDepth(I, masks)
% %
% % AVGDEPTH = GETOVERALLMEANDEPTH(I, MASKS)
% % 
% % I      : Input depth map image (NxM, single-channel TIFF).
% % MASKS  : Struct containing multiple masks.
% % 
% % AVGDEPTH : Single mean depth value across all masks.
% %
% 
% % Initialize an empty array to collect depth values
% depthValues = [];
% 
% % Extract depth values for all masks
% maskNames = fieldnames(masks); % Get all mask names
% for i = 1:numel(maskNames)
%     mask = masks.(maskNames{i}).mask;  % Extract the binary mask
%     depthLayer = double(I);  % Convert depth image to double precision
% 
%     if sum(mask(:)) ~= 0  % Ensure the mask is not empty
%         depthValues = [depthValues; depthLayer(mask)]; % Append masked values
%     end
% end
% 
% % Compute mean depth across all masks
% if ~isempty(depthValues)
%     avgDepth = mean(depthValues);
% else
%     avgDepth = NaN;  % If no masks contained depth values, return NaN
% end
% 
% end
