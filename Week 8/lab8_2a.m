clc
clear all
close all
tic;
D = './images';
S = dir(fullfile(D,'*.jpg')); % pattern to match filenames.

query_image_path = 'images/blue10.jpg';
queryImgFeatures = getGLCMFeatures(query_image_path,32);
names = ['file_name',"H_Energy", "H_Entropy", "H_Contrast","H_InverseDifferenceMoment","V_Energy", "V_Entropy", "V_Contrast","V_InverseDifferenceMoment","LD_Energy", "LD_Entropy", "LD_Contrast","LD_InverseDifferenceMoment","Euclidean Distance"];
info_table = cell2table(cell(0, size(names,2)), 'VariableNames', names);

for k=1:numel(S)
    image_path = sprintf('images/%s', S(k).name);
    image_GLCM_feature = getGLCMFeatures(image_path,32);
    image_feature = [];
    image_path = S(k).name;
    image_feature{end+1} = image_path;    
    % Calculating the Euclidean distance between the image and the query
    euclidean_distance = 0;
     for i = 1:12
         euclidean_distance = euclidean_distance + (image_GLCM_feature(i)^2 - queryImgFeatures(i)^2);
         image_feature{end+1} = image_GLCM_feature(i);
     end
     euclidean_distance = sqrt(euclidean_distance);
    image_feature{end+1} = euclidean_distance;
    % Appending the result in the table
   info_table = [info_table; image_feature];
end
info_table = sortrows(info_table, 'Euclidean Distance');
writetable(info_table, 'lab8.xls','Sheet',1);

% Displaying the first 6 nearest image
subplot(3, 3, 2);
query_image = imread(query_image_path);
imshow(im2gray(query_image));
title('Query image');
file_names = info_table(:, 'file_name').file_name; % Extracting the filenames of the images
for i = 1:6
    F = fullfile(D,char(file_names(i)));
    I = imread(F);
    subplot(3, 3, i+3);
    imshow(im2gray(I));
    title(char(file_names(i)));
end
toc;

function features = getGLCMFeatures(imgFilePath, levels)
if ~exist('levels', 'var')
    levels = 32;
end
directions = 3;

img = imread(imgFilePath);
img = im2gray(img);
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