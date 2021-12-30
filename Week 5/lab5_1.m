clc
clear all
close all
tic;
D = './images';
S = dir(fullfile(D,'*.jpg')); % pattern to match filenames.

% Loading query image and converting to gray scale
query_image = imread('images/blue10.jpg');
query_image = rgb2gray(query_image);

Q_Row={'Query'};
%Extracting Horizontal and Vertical count of Query Image
[hc vc] = acg(query_image,[1 3]);
for i = 1:256
    Q_Row{end+1} = hc(i,1);
end
for i = 1:256
    Q_Row{end+1} = vc(i,1);
end
for i = 1:256
    Q_Row{end+1} = hc(i,2);
end
for i = 1:256
    Q_Row{end+1} = vc(i,2);
end
%Q_Row{end+1} = 0;
%Creating array with Column Names for Excel Sheet
CNames = {'file_name'};
for i = 1:256
    CNames{end+1} = sprintf('H-1-%d,%d', i-1, i-1);
end
for i = 1:256
    CNames{end+1} = sprintf('V-1-%d,%d', i-1, i-1);
end
for i = 1:256
    CNames{end+1} = sprintf('H-2-%d,%d', i-1, i-1);
end
for i = 1:256
    CNames{end+1} = sprintf('V-2-%d,%d', i-1, i-1);
end
CNames{end+1} = 'Chi-Square Distance';
info_table = cell2table(cell(0, 1026), 'VariableNames',CNames);
%info_table=[info_table;Q_Row];
% Looping through all the images in the directory
for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    I = imread(F);
    I = rgb2gray(I);
    S(k).data = I; % optional, save data.
    I_Row={S(k).name};
    [ihc ivc] = acg(I,[1 3]);
    for i = 1:256
        I_Row{end+1} = ihc(i,1);
    end
    for i = 1:256
        I_Row{end+1} = ivc(i,1);
    end
    for i = 1:256
        I_Row{end+1} = ihc(i,2);
    end
    for i = 1:256
        I_Row{end+1} = ivc(i,2);
    end
     tot_sum =0;
     for i = 2:1025
         num = (Q_Row{i} - I_Row{i})^2;
         denum = Q_Row{i} + I_Row{i};
         if(denum==0)
            csd = 0;
         else
             csd = num/denum;
         end
         tot_sum = tot_sum + csd;
         %disp(I_Row(1)+"-"+Q_Row{i}+"diff. sq."+I_Row{i}+"->"+tot_sum);
     end
     tot_sum = tot_sum * 0.5;
     I_Row{end+1} = tot_sum;
     info_table = [info_table;I_Row];
end

% Replacing the NaN with values in the previous cell and replacing the 
% rows in the table in the ascending order of city block distance
info_table = sortrows(fillmissing(info_table, 'previous'), 'Chi-Square Distance');
writetable(info_table, 'lab5_1.xlsx','Sheet',1);

% Displaying the first 5 nearest image
subplot(3, 3, 2);
imshow(query_image);
title('Query image');
% Extracting the filenames of the images
file_names = info_table(:, 'file_name').file_name; 
for i = 1:6
    F = fullfile(D,char(file_names(i)));
    I = imread(F);
    I = rgb2gray(I);
    subplot(3, 3, i+3);
    imshow(I);
    title(char(file_names(i)));
end

toc;
function [horizontal_count, vertical_count] = acg(img, distances, levels)
    % Check if levels provided or not
    if nargin == 2
    levels = 256;
    end

    [Y, X] = size(img);
    % Image quantization
    img = gray2ind(img, levels);
    % Set variable sizes
    [~, num_of_distances] = size(distances);
    horizontal_count = zeros(levels, num_of_distances);
    vertical_count = zeros(levels, num_of_distances);
    % For each row
    for r = 1:Y
    % For each column
        for c = 1:X
    % For each distance
            for d = 1:num_of_distances
                D = distances(d);
                value = img(r,c); % Get the value
                % Increment the resp. counter, if pixels equivalent
                if(r + D <= Y && img(r + D, c) == value)
                horizontal_count(value+1, d) = horizontal_count(value+1, d) + 1;
                end
                if(c + D <= X && img(r, c + D) == value)
                vertical_count(value+1, d) = vertical_count(value+1, d) + 1;
                end
            end
        end
    end
end