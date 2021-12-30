clc;
clear all;
close all;
tic;
query_image_path = '10.jpg';
queryImgFeatures = getTamuraFeaturesRGB(getImgFilePath(query_image_path));
names = ['file_name',"Red_Contrast", "Red_Directionality", "Red_Coarseness","Red_Linelikeness", "Red_Regularity", "Red_Roughness","Green_Contrast", "Green_Directionality", "Green_Coarseness","Green_Linelikeness", "Green_Regularity", "Green_Roughness","Blue_Contrast", "Blue_Directionality", "Blue_Coarseness","Blue_Linelikeness", "Blue_Regularity", "Blue_Roughness","City Block Distance"];
info_table = cell2table(cell(0, size(names,2)), 'VariableNames', names);
% Reading the images of textures from the image base
D = './img2';
S = dir(fullfile(D,'*.jpg')); % pattern to match filenames.
% Looping through all the images in the directory
for k=1:10
    image_path = S(k).name;
    image_tamura_feature = getTamuraFeaturesRGB(getImgFilePath(image_path));
    image_feature = [];
    image_feature{end+1} = image_path;    
    % Calculating the City Block distance between the image and the query
    city_block_distance = 0;
     for i = 1:18
         city_block_distance = city_block_distance + abs(image_tamura_feature(i) - queryImgFeatures(i));
         image_feature{end+1} = image_tamura_feature(i);
     end
    image_feature{end+1} = city_block_distance;
    % Appending the result in the table
   info_table = [info_table; image_feature];
end
info_table = sortrows(info_table, 'City Block Distance');
writetable(info_table, 'lab7.xls','Sheet', 2);

% Displaying the first 6 nearest image
subplot(3, 3, 2);
query_image = imread(getImgFilePath(query_image_path));
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

% |#| Function to retrieve file path
function filePath = getImgFilePath(imgName)
     imgSetPath = "./img2/";
    filePath = sprintf('%s%s', imgSetPath, imgName);
end