% function formatted_path = format_path(user_input)
%     % Normalize path: trim spaces and convert backslashes to forward slashes
%     rawpath = strrep(strtrim(user_input), '\', '/');
% 
%     % Split into folder components (handles both slashes and commas)
%     folderList = strsplit(rawpath, {'/', ','});
% 
%     % Ensure the drive letter is correctly formatted
%     if contains(folderList{1}, ':')
%         folderList{1} = strrep(folderList{1}, '/', '');
%     end
% 
%     % Format as single-quoted, comma-separated values
%     formatted_path = strjoin("'" + folderList + "'", ', ');
% 
%     % Convert back to fullfile format
%     rawpath = fullfile(folderList{:});
% 
%     % Verify that the path exists, prompt again if invalid
%     while exist(rawpath, 'dir') ~= 7
%         user_input = input('Invalid path. Enter again: ', 's');
%         rawpath = strrep(strtrim(user_input), '\', '/');
%         folderList = strsplit(rawpath, {'/', ','});
%         if contains(folderList{1}, ':')
%             folderList{1} = strrep(folderList{1}, '/', '');
%         end
%         % formatted_path = strjoin("'" + folderList + "'", ', ');
%         % rawpath = fullfile(folderList{:});
%         formatted_path = strjoin(folderList, ', '); 
%         rawpath = fullfile(folderList{:});
%     end
% end

function [formatted_path, rawpath] = format_path(user_input) 
    % Normalize path: trim spaces and convert backslashes to forward slashes
    rawpath = strrep(strtrim(user_input), '\', '/');
    
    % Split into folder components (handles both slashes and commas)
    folderList = strsplit(rawpath, {'/', ','});
    
    % Ensure the drive letter is correctly formatted
    if contains(folderList{1}, ':')
        folderList{1} = strrep(folderList{1}, '/', '');
    end
    
    % Format as a comma-separated string (for display/debugging)
    formatted_path = strjoin(folderList, ', ');  

    % Convert back to fullfile format correctly
    rawpath = fullfile(folderList{:});

    % Verify that the path exists, prompt again if invalid
    while exist(rawpath, 'dir') ~= 7
        user_input = input('Invalid path. Enter again: ', 's');
        rawpath = strrep(strtrim(user_input), '\', '/');
        folderList = strsplit(rawpath, {'/', ','});
        if contains(folderList{1}, ':')
            folderList{1} = strrep(folderList{1}, '/', '');
        end
        formatted_path = strjoin(folderList, ', ');  
        rawpath = fullfile(folderList{:});
    end
end
