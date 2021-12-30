clc
clear all
close all
query_image_path = './images/yellow10.jpg';

% Creating the names of columns for the xls file
names = {'file_name'};
for i=1:16
names{end+1} = sprintf('%s%d', 'C-', i);
names{end+1} = sprintf('%s%d', 'NC-', i);
end
names{end+1} = 'city_block_distance';
info_table = cell2table(cell(0, size(names,2)), 'VariableNames', names);

% Getting the ccv feature vector for the query image
query_ccv_feature = getCCVfeature(query_image_path);

% Reading the images of textures from the image base
D = './images';
S = dir(fullfile(D,'*.jpg')); % pattern to match filenames.

% Looping through all the images in the directory
for k=1:numel(S)
    image_path = fullfile(D, S(k).name);
    image_ccv_feature = getCCVfeature(image_path);
    
    % Calculating the euclidean distance between the image and the query
    % image
    city_block_distance = 0;
    for i = 1:32
        city_block_distance = city_block_distance + abs(image_ccv_feature{i} - query_ccv_feature{i});
    end
    image_feature = [S(k).name, image_ccv_feature, city_block_distance];
    % Appending the result in the table
    info_table = [info_table; image_feature];
   
end

% Sorting the entries of the table based on ascending order of cuty block
% distance
info_table = sortrows(info_table, 'city_block_distance');
writetable(info_table, 'lab6.xls');

% Displaying the first 6 nearest image
subplot(3, 3, 2);
query_image = imread(query_image_path);
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

function[x] = getCCVfeature(image_path)
image = imread(image_path);
image = imresize(image, [64, 64]);
img = rgb2gray(image);
img = imgaussfilt(img, 2);

% Quantizing the image for 16 levels
steps = 256/16;
levels = steps:steps:256;
img = imquantize(img, levels);

% Creating table for storing the feature vector
T = cell2table(cell(0, 2), 'VariableNames', {'Intensity', 'Frequency'});

% Finding the patches
[s0, s1] = size(img);
CCV = zeros(16, 3);
for i=1:16
    CCV(i, 1) = i;
end
VISITED = zeros(s0, s1);    % To keep track of visited pixels
for i=1:s0
    for j=1:s1
        if VISITED(i, j) == 1
            continue
        else
            [ni, nv] = getCCV(img, i, j, VISITED);
%             disp(i+" "+j+" value: "+img(i, j)+" "+ni);
            VISITED = nv;
        end
        newrow = {img(i, j), ni};
        T = [T;newrow];
    end
end

% Defining the value of tao
tao = 250;

% Creating the CCV
for i=1:size(T, 1)
    if (T{i, 2} >= tao)
        CCV(T{i, 1}, 2) = CCV(T{i, 1}, 2) + T{i, 2};
    else
        CCV(T{i, 1}, 3) = CCV(T{i, 1}, 3) + T{i, 2};
    end
end
ccv_feature = {};
for i=1:size(CCV, 1)
   ccv_feature = [ccv_feature, CCV(i, 2), CCV(i, 3)]; 
end

% Returning the result
x = ccv_feature;
end


function[x,y] = getCCV(img, i, j, VISITED)
% Function to find the patches in the image for the given pixel at img(i,
% j)

% Finding the dimensions of the image
[s0, s1] = size(img);

% Checking if indices are out of bounds
if i<1 || i>s0 || j<1 || j>s1
    x = 0;
    y = VISITED;
    return
end

% Checking if the current pixel is already visited
if VISITED(i, j) == 1
    x = 0;
    y = VISITED;
    return
end

% Checking if all the pixels in the image are same to prevent infinite
% recursion
if numel(unique(img)) == 1
   x = s0*s1;
   y = ones(s0, s1);
   return
end

% Procedure if current pixel is not visited already

n = 1;  % Initializing the frequency of the current patch
VISITED(i, j) = 1;  % Marking the current pixel as visited

% Checking for the patch in the 8 neighbouring pixels
%%%%%%%%%%%%%%%%%%
% ||   | * |   ||%
% ||   | * |   ||%
% ||   |   |   ||%
%%%%%%%%%%%%%%%%%%
if i ~= 1
    if img(i, j) == img(i-1, j)
        [ni, nv] = getCCV(img, i-1, j, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end
%%%%%%%%%%%%%%%%%%
% ||   |   |   ||%
% ||   | * |   ||%
% ||   | * |   ||%
%%%%%%%%%%%%%%%%%%
if i ~= s0
    if img(i, j) == img(i+1, j)
        [ni, nv] = getCCV(img, i+1, j, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end
%%%%%%%%%%%%%%%%%%
% ||   |   |   ||%
% || * | * |   ||%
% ||   |   |   ||%
%%%%%%%%%%%%%%%%%%
if j ~= 1
    if img(i, j) == img(i, j-1)
        [ni, nv] = getCCV(img, i, j-1, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end
%%%%%%%%%%%%%%%%%%
% ||   |   |   ||%
% ||   | * | * ||%
% ||   |   |   ||%
%%%%%%%%%%%%%%%%%%
if j ~= s1
    if img(i, j) == img(i, j+1)
        [ni, nv] = getCCV(img, i, j+1, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end
%%%%%%%%%%%%%%%%%%
% || * |   |   ||%
% ||   | * |   ||%
% ||   |   |   ||%
%%%%%%%%%%%%%%%%%%
if (i~=1 && j~=1)
    if img(i, j) == img(i-1, j-1)
        [ni, nv] = getCCV(img, i-1, j-1, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end
%%%%%%%%%%%%%%%%%%
% ||   |   | * ||%
% ||   | * |   ||%
% ||   |   |   ||%
%%%%%%%%%%%%%%%%%%
if (i~=1 && j~=s1)
    if img(i, j) == img(i-1, j+1)
        [ni, nv] = getCCV(img, i-1, j+1, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end
%%%%%%%%%%%%%%%%%%
% ||   |   |   ||%
% ||   | * |   ||%
% || * |   |   ||%
%%%%%%%%%%%%%%%%%%
if (i~=s0 && j~=1)
    if img(i, j) == img(i+1, j-1)
        [ni, nv] = getCCV(img, i+1, j-1, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end
%%%%%%%%%%%%%%%%%%
% ||   |   |   ||%
% ||   | * |   ||%
% ||   |   | * ||%
%%%%%%%%%%%%%%%%%%
if (i~=s0 && j~=s1)
    if img(i, j) == img(i+1, j+1)
        [ni, nv] = getCCV(img, i+1, j+1, VISITED);
        n = n + ni;
        VISITED = nv;
    end
end

% Returning the final pixel count in the patch with the updated VISITED matrix 
x = n;
y = VISITED;
end
