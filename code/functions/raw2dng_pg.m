% raw2dng converts a raw image to dng using the ADOBE DNG Converter.

% Status = raw2dng(rawPath) takes as input the path to a raw image file
% and uses the Adobe DNG Converter to save a DNG file in the same location
% as the raw file.
%
% Status is a struct containing information about the result of the
% conversion.
%
% You need to have Adobe DNG Converter installed, and add its path to the
% systemCommand line below. This example is for a Mac.
%
% See also:
%
% https://helpx.adobe.com/photoshop/digital-negative.html?sdid=B4XQ3XRQ
%
% https://wwwimages2.adobe.com/content/dam/acom/en/products/photoshop/pdfs/dng_commandline.pdf
%
% Derya Akkaynak 2019 | deryaa@alum.mit.edu
function raw2dng_pg(folders)

rawPath = fullfile(folders.rawFolder);
saveFolder = fullfile(folders.dngFolder);

% Calls the adobe dng converter, syntax here is for mac. Change as needed
% for your OS
applicationPath = '"C:\Program Files\Adobe\Adobe DNG Converter\Adobe DNG Converter.exe"';
opts = ' -l -u'; % Not compressed
%opts = ' -lossy -count20 '; % This is what Karaimer code wants but we
%don't use that

files = dir(fullfile(rawPath,'*'));


for i = 1:numel(files)
    if files(i).name(1) == '.'
    continue
    end
    status = system(append(applicationPath,opts,' -d ',saveFolder,' ',fullfile(files(i).folder, files(i).name)));
end

% status = system([applicationPath,opts,' -d ',saveFolder,' ',args]);

% Human readable output
if status ~= 0
    fprintf(2,'There was a problem converting raw images to DNG.\n');
end
