% function contraststretchedjpgs_pg(folders)
% 
% contrastStretchedJpgFolder = folders.contrastStretchedJpgFolder;
% linearTiffFolder = folders.uncorrectedTiffFolder;
% 
% % Take all the tiff files from this folder and loop over them
% files = dir(fullfile(linearTiffFolder,'*.tif'));
% % This step is necessary of the files came from a Windows computer which
% % makes copies starting with .
% files = remove_non_files(files);
% 
% % This is where we will copy the metadata from
% dngFileName = fullfile(folders.dngFolder,[files(1).name(1:end-4),'.dng']);
% iminfo = imfinfo(dngFileName);
% imgdata = iminfo.SubIFDs{1}';
% true_size = fliplr(imgdata.DefaultCropSize);
% % This is the exifpath for COLOR LAB 05
% exif_path = fullfile('C:','Program Files', 'exiftool','exiftool.exe');
% 
% for i = 1:numel(files)
%     fileName = files(i).name;
%     % Read the tiff image
%     I = im2double(imread(fullfile(linearTiffFolder,fileName)));
% 
%     % Resize it for faster processing
%     Ism = imresize(I,0.5);
%     s = size(Ism);
%     % Nanmap would be where there are areas to be ignored. At this point we do not have this so set to zeros
%     nanmap = zeros(s(1),s(2));
%     % Apply atmospheric dehazing
%     Ifinal = correct_with_dcp(Ism,nanmap,iminfo);
%     % Clip the image a bit to stretch the dynamic range
%     Ifinal = clipImage(Ifinal,99,0);
%     % Resize the image to what the DNG file said it should be
%     Ifinal = imresize(Ifinal,[true_size(1),true_size(2)]);
%     % Save the contrast stretched image in jpg form.
%     saveFilePath = fullfile(contrastStretchedJpgFolder,[fileName(1:end-4),'.jpg']);
%     imwrite(Ifinal,saveFilePath);
% 
%     % copy the exif tags so the metadata is in the jpgs (Agisoft needs it)
%     dngFilePath = fullfile(folders.dngFolder,[fileName(1:end-4),'.dng']);
% 
%     command = strjoin({['"' exif_path '"'],' -m -overwrite_original -tagsfromfile ',char(dngFilePath),' -all:all ', char(saveFilePath)});
% 
% 
%     status = system(command);
%     if status~=0
%         fprintf(2,'OOOPS... Something went wrong and metadata were not copied. /n')
%     end
% 
% end
% end
% 
% 


function contraststretchedjpgs_pg(folders, exif_path) % Add exif_path as an input argument

contrastStretchedJpgFolder = folders.contrastStretchedJpgFolder;
linearTiffFolder = folders.uncorrectedTiffFolder;

% Take all the tiff files from this folder and loop over them
files = dir(fullfile(linearTiffFolder, '*.tif'));
files = remove_non_files(files);

% This is where we will copy the metadata from
dngFileName = fullfile(folders.dngFolder, [files(1).name(1:end-4), '.dng']);
iminfo = imfinfo(dngFileName);
imgdata = iminfo.SubIFDs{1}';
true_size = fliplr(imgdata.DefaultCropSize);

% Use the provided exif_path instead of a hardcoded path

for i = 1:numel(files)
    fileName = files(i).name;
    I = im2double(imread(fullfile(linearTiffFolder, fileName)));
    Ism = imresize(I, 0.5);
    s = size(Ism);
    nanmap = zeros(s(1), s(2));

    % Apply atmospheric dehazing
    Ifinal = correct_with_dcp(Ism, nanmap, iminfo);
    Ifinal = clipImage(Ifinal, 99, 0);
    Ifinal = imresize(Ifinal, [true_size(1), true_size(2)]);

    % Save the contrast-stretched image in JPG form
    saveFilePath = fullfile(contrastStretchedJpgFolder, [fileName(1:end-4), '.jpg']);
    imwrite(Ifinal, saveFilePath);

    % Copy the exif tags so the metadata is in the JPGs
    dngFilePath = fullfile(folders.dngFolder, [fileName(1:end-4), '.dng']);

    command = strjoin({['"' exif_path '"'], ' -m -overwrite_original -tagsfromfile ', char(dngFilePath), ' -all:all ', char(saveFilePath)});

    status = system(command);
    if status ~= 0
        fprintf(2, 'OOOPS... Something went wrong and metadata were not copied.\n');
    end
end

end







function out_img = correct_with_dcp(Ism,nanmap,info)

[~,~,~,Jc_dcp] = getBackscatterFromDCP(Ism);
wp = illumgray(Jc_dcp,0.5,'mask',~nanmap);
Jc_dcp_wb = mat2gray(whiteBalance2(Jc_dcp,wp));

if nargin<3
    out_img = Jc_dcp_wb;
else
    out_img = convert_linear2rgb(Jc_dcp_wb,info);
end
end

function [Bc,T,L,Jhat] = getBackscatterFromDCP(I)

s = size(I);
Bc = zeros(s(1),s(2),3);
T = zeros(s(1),s(2),3);
L = zeros(3,1);
Jhat = zeros(s(1),s(2),3);

% Here T is haze thickness, which is related to scene depth D as D =
% -lnt/beta. But beta is not returned, so D is up to scale.

for j = 1:3
    [Jhat(:,:,j),T(:,:,j),L(j)] = imreducehaze(I(:,:,j),1,'method', 'approxdcp','contrastenhancement','none');
    Bc(:,:,j) = L(j).*(1-T(:,:,j));
end

end

function I = whiteBalance2(I,wb)

for j = 1:3
    I(:,:,j) = I(:,:,j)./wb(j);
end

end

function [nl_srgb, info] = convert_linear2rgb(img, info, wb_mode, neutral_color)
% This function takes a linear image in the camera's color space and converts it
% to an sRGB image and applies gamma correction.
% Based on the following RAWguide by Rob Summer:
% https://users.soe.ucsc.edu/~rcsumner/rawguide/RAWguide.pdf

warning off MATLAB:tifflib:TIFFReadDirectory:libraryWarning
warning off MATLAB:imagesci:tiffmexutils:libtiffWarning
warning off MATLAB:imagesci:tifftagsread:badTagValueDivisionByZero

if exist('info','var') && ~isempty(info) && isstruct(info)

    % Color Space Conversion
    xyz2cam = reshape(info.ColorMatrix2,3,3)';
    % Define transformation matrix from sRGB space to XYZ space
    srgb2xyz = [0.4124564 0.3575761 0.1804375;
        0.2126729 0.7151522 0.0721750;
        0.0193339 0.1191920 0.9503041];
    rgb2cam = xyz2cam * srgb2xyz;
    rgb2cam = rgb2cam ./ repmat(sum(rgb2cam,2),1,3);
    cam2rgb = rgb2cam^-1;

    lin_srgb = apply_cmatrix(img,cam2rgb);
    lin_srgb = max(0,min(lin_srgb,1));
    img = lin_srgb;
end

% Gamma Correction
nl_srgb = img.^(1/2.2);
%nl_srgb = img;
end

function I = clipImage(I,pmax,pmin,clipValMax,clipValMin)
% I can be single, double, or uint8

if nargin<5
    pctMax = prctile(I(:),pmax);
    pctMin = prctile(I(:),pmin);
    I = mat2gray(max(pctMin,min(I,pctMax)));
else
    I = mat2gray(max(clipValMin,min(I,clipValMax)));
end
end

function files = remove_non_files(files)

del_ind = [];
for i = 1:numel(files)
    if strcmp(files(i).name(1),'.') || files(i).isdir
        del_ind = [del_ind;i];
    end
end

files(del_ind) = [];
end

