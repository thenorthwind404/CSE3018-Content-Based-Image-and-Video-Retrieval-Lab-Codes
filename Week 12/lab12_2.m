clc
clear all
close all
tic;
% Reading in the query image and extracting it's LBP features
query_image = imread('./images/blue3.jpg');

%Color Plane Slicing
red = query_image(:,:,1);
green = query_image(:,:,2);
blue = query_image(:,:,3);

%Extracting HOG Features from each Plane
r=[];
g=[];
b=[];
r = getHOGFeatures(red);
g = getHOGFeatures(green);
b = getHOGFeatures(blue);

queryImgFeatures=[];
for i = 1:size(r,2)
    queryImgFeatures{end+1} = r(i); 
end
for i = 1:size(g,2)
    queryImgFeatures{end+1} = g(i); 
end
for i = 1:size(b,2)
    queryImgFeatures{end+1} = b(i); 
end

% Initializing the path of the image base and getting the directory listing
D = './images';
S = dir(fullfile(D, '*.jpg'));

%Column Names
CNames = {'file_name'};
for i = 1:size(queryImgFeatures,2)
    CNames{end+1} = sprintf('%d',i);
end
CNames{end+1} = 'Euclidean Distance';
info_table = cell2table(cell(0, size(CNames,2)), 'VariableNames',CNames);

% Calculating the euclidean distance between every image in the image base and the query image
for k=1:numel(S)
    F = fullfile(D, S(k).name);
    I = imread(F);
    
    %Color Plane Slicing
    red = I(:,:,1);
    green = I(:,:,2);
    blue = I(:,:,3);
    
    %Extracting HOG Features from each Plane
    r=[];
    g=[];
    b=[];
    r = getHOGFeatures(red);
    g = getHOGFeatures(green);
    b = getHOGFeatures(blue);

    imageFeatures=[];
    imageFeatures{end+1} = S(k).name;
    for i = 1:size(r,2)
        imageFeatures{end+1} = r(i); 
    end
    for i = 1:size(g,2)
        imageFeatures{end+1} = g(i); 
    end
    for i = 1:size(b,2)
        imageFeatures{end+1} = b(i); 
    end

    if(size(queryImgFeatures,2) == size(imageFeatures,2))
        euclidean_distance = sqrt(sum((image_features - queryImgFeatures).^2));
        imageFeatures{end+1} = euclidean_distance;
        info_table = [info_table; imageFeatures];
    end
end

% Sorting the entries of the table based on ascending order of
% euclidean_distance
info_table = sortrows(info_table, 'Euclidean Distance');
writetable(info_table, 'lab12.xlsx','Sheet',2);

% Displaying the first 4 nearest image
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
 