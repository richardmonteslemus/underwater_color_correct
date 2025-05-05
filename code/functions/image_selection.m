% Read the CSV file
tableData = readtable('selected_color_charts.csv', 'TextType', 'string');

% Get image file names (assuming they are in the first column)
imageFiles = tableData{:, 1};

% Number of images
numImages = length(imageFiles);

deleteList = false(numImages, 1);
currentIdx = 1;

fig = figure;
while ishandle(fig)
    % Display current image
    img = imread(imageFiles{currentIdx});
    imshow(img);
    title(sprintf('%d/%d: %s', currentIdx, numImages, imageFiles{currentIdx}), 'Interpreter', 'none');
    
    % User instructions
    disp('Press Left/Right to navigate, D to delete/undelete, Q to quit.');
    
    % Wait for key press
    waitforbuttonpress;
    key = get(gcf, 'CurrentCharacter');
    
    switch key
        case 28  % Left arrow
            if currentIdx > 1
                currentIdx = currentIdx - 1;
            end
        case 29  % Right arrow
            if currentIdx < numImages
                currentIdx = currentIdx + 1;
            end
        case 'd'  % Toggle delete status
            deleteList(currentIdx) = ~deleteList(currentIdx);
            if deleteList(currentIdx)
                disp(['Marked for deletion: ', imageFiles{currentIdx}]);
            else
                disp(['Unmarked: ', imageFiles{currentIdx}]);
            end
        case 'q'  % Quit
            close(fig);
    end
end

% Update CSV file
tableData(deleteList, :) = [];
writetable(tableData, 'selected_color_charts.csv');

disp('CSV file updated. Selected images have been removed.');
