clc
clear all
close all
tic;
% Reading in the query image and extracting it's LBP features
query_image = imread('./Faces/happy1.jpg');
query_image_features = getHOGFeatures(query_image);

% Initializing the path of the image base and getting the directory listing
D = './Faces';
S = dir(fullfile(D, '*.jpg'));

%Column Names
CNames = {'file_name'};
for i = 1:900
    CNames{end+1} = sprintf('%d',i);
end
CNames{end+1} = 'Euclidean Distance';
info_table = cell2table(cell(0, size(CNames,2)), 'VariableNames',CNames);

% Calculating the euclidean distance between every image in the image base and the query image
for k=1:numel(S)
    F = fullfile(D, S(k).name);
    I = imread(F);
    image_features = getHOGFeatures(I);
    if size(image_features, 2) == size(query_image_features, 2)
        euclidean_distance = sqrt(sum((image_features - query_image_features).^2));
        imageFeatures={S(k).name};
        for i=1:900
            imageFeatures{end+1}=image_features(i);
        end
        imageFeatures{end+1} = euclidean_distance;
        info_table = [info_table; imageFeatures];
    end
end

% Sorting the entries of the table based on ascending order of
% euclidean_distance
info_table = sortrows(info_table, 'Euclidean Distance');
writetable(info_table, 'lab12.xlsx','Sheet',1);

% Displaying the first 4 nearest image
subplot(3, 5, 3);
imshow(query_image);
title('Query image');
file_names = info_table(:, 'file_name').file_name; % Extracting the filenames of the images
for i = 1:10
    F = fullfile(D,char(file_names(i)));
    I = imread(F);
    subplot(3, 5, i+5);
    imshow(I);
    title(char(file_names(i)));
end
toc;
 