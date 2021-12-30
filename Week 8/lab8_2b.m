clc
clear all
close all
tic;
D = './images';
S = dir(fullfile(D,'*.jpg')); % pattern to match filenames.

query_image = imread('images/blue10.jpg');

%Color Plane Slicing
red = query_image(:,:,1);
green = query_image(:,:,2);
blue = query_image(:,:,3);

%Extracting GLCM Features from each Plane
r=[];
g=[];
b=[];
r = getGLCMFeatures(red,32);
g = getGLCMFeatures(green,32);
b = getGLCMFeatures(blue,32);

queryImgFeatures=[];
for i = 1:12
    queryImgFeatures{end+1} = r(i); 
end
for i = 1:12
    queryImgFeatures{end+1} = g(i); 
end
for i = 1:12
    queryImgFeatures{end+1} = b(i); 
end

names = ['file_name',"R_H_Energy", "R_H_Entropy", "R_H_Contrast","R_H_InverseDifferenceMoment","R_V_Energy", "R_V_Entropy", "R_V_Contrast","R_V_InverseDifferenceMoment","R_LD_Energy", "R_LD_Entropy", "R_LD_Contrast","R_LD_InverseDifferenceMoment","G_H_Energy","G_H_Entropy", "G_H_Contrast","G_H_InverseDifferenceMoment","G_V_Energy", "G_V_Entropy", "G_V_Contrast","G_V_InverseDifferenceMoment","G_LD_Energy", "G_LD_Entropy", "G_LD_Contrast","G_LD_InverseDifferenceMoment","B_H_Energy","B_H_Entropy", "B_H_Contrast","B_H_InverseDifferenceMoment","B_V_Energy", "B_V_Entropy", "B_V_Contrast","B_V_InverseDifferenceMoment","B_LD_Energy", "B_LD_Entropy", "B_LD_Contrast","B_LD_InverseDifferenceMoment","Euclidean Distance"];

info_table = cell2table(cell(0, size(names,2)), 'VariableNames', names);

for k=1:numel(S)
    image_path = sprintf('images/%s', S(k).name);
    img = imread(image_path);

    %Color Plane Slicing
    red = img(:,:,1);
    green = img(:,:,2);
    blue = img(:,:,3);
    
    %Extracting GLCM Features from each Plane
    r = getGLCMFeatures(red,32);
    g = getGLCMFeatures(green,32);
    b = getGLCMFeatures(blue,32);
    
    image_GLCM_feature=[];
    image_feature = [];
    
    for i = 1:12
        image_GLCM_feature{end+1} = r(i); 
    end
    for i = 1:12
        image_GLCM_feature{end+1} = g(i); 
    end
    for i = 1:12
        image_GLCM_feature{end+1} = b(i); 
    end
    
    image_path = S(k).name;
    image_feature{end+1} = image_path;    
    % Calculating the Euclidean distance between the image and the query
    euclidean_distance = 0;
     for i = 1:36
         x = image_GLCM_feature{i};
         y = queryImgFeatures{i};
         euclidean_distance = euclidean_distance + (x*x - y*y);
         image_feature{end+1} = image_GLCM_feature(i);
     end
     euclidean_distance = sqrt(euclidean_distance);
    image_feature{end+1} = euclidean_distance;
    
    % Appending the result in the table
    info_table = [info_table; image_feature];
end
info_table = sortrows(info_table, 'Euclidean Distance');
writetable(info_table, 'lab8.xls','Sheet',2);

% Displaying the first 6 nearest image
subplot(3, 3, 2);
imshow(query_image);
title('Query image');
file_names = info_table(:, 'file_name').file_name; % Extracting the filenames of the images
for i = 1:6
    F = fullfile(D,char(file_names(i)));
    I = imread(F);
    subplot(3, 3, i+3);
    imshow(I);
    title(char(file_names(i)));
end
toc;

function features = getGLCMFeatures(imgFile, levels)
if ~exist('levels', 'var')
    levels = 32;
end
directions = 3;

img = imgFile;

[h, w] = size(img);

% Initialize the GLCM
GLCM = zeros(levels, levels, directions);

% Quantize the image
partitions = 256/levels;
img = imquantize(img, partitions:partitions:256);

for i=1:h
    for j=1:w
        % Horizontal
        if j ~= w
            GLCM(img(i,j),img(i,j+1),1) = GLCM(img(i,j),img(i,j+1),1) + 1;
        end
        % Vertical
        if i ~= h
            GLCM(img(i,j),img(i+1,j),2) = GLCM(img(i,j),img(i+1,j),2) + 1;
        end
        % Leading Diagonal
        if i ~= h && j ~=w
            GLCM(img(i,j),img(i+1,j+1),3) = GLCM(img(i,j),img(i+1,j+1),3) + 1;
        end
    end
end

features = zeros(4,3);

% Calculate features for resp. directions
for d=1:directions
    GLCMDR = GLCM(:,:,d); % GLCM Direction Resp.
    % Normalize
    GLCMDR = GLCM(:,:,d)./sum(sum(GLCMDR));
    
    % Calculate energy
    tmp = GLCMDR.^2;
    features(1,d) = sum(tmp(:));
    
    % Calculate entropy
    tmp = GLCMDR.*log(GLCMDR);
    tmp(isnan(tmp)) = 0; % To avoid calc errors
    features(2,d) = -1 * sum(tmp(:));
    
    % Calculate contrast & IDM
    for i=1:levels
        for j=1:levels
            % Contrast
            features(3,d) = features(3,d) + ((i-j)^2*GLCMDR(i,j));
            % Inverse Difference Moment
            features(4,d) = features(4,d) + (GLCMDR(i,j)/(1+(i-j)^2));
        end
    end
end

features = features(:);

end