clc
clear all
close all
D = './images';
S = dir(fullfile(D,'*.jpg')); % pattern to match filenames.

% Loading query image
query_image = imread('images/blue1.jpg');
query_image = rgb2gray(query_image);

% Extracting colour planes of query image
%q_red = single(query_image(:,:,1));
% q_green = single(query_image(:,:,2));
% q_blue = single(query_image(:,:,3));

%Getting bin values of each color plane of query image
[Qbinval_red,Qbinloc_red] = imhist(query_image);
% [Qbinval_green,Qbinloc_green] = imhist(q_green);
% [Qbinval_blue,Qbinloc_blue] = imhist(q_blue);

%Combining Bin Values into one array
Q_row={'garbage'};
for i=1:numel(Qbinval_red)
       Q_row{end+1} = Qbinval_red(i);
end
% for i=1:numel(Qbinval_green)
%        Q_row{end+1} = Qbinval_green(i);
% end
% for i=1:numel(Qbinval_blue)
%        Q_row{end+1} = Qbinval_blue(i);
% end

%creating first row - column names - of excel sheet
names = {'file_name'};
for i=0:255
names{end+1} = sprintf('%s%d', 'Bin ', i);
end
% for i=0:255
% names{end+1} = sprintf('%s%d', 'Green Color Bin ', i);
% end
% for i=0:255
% names{end+1} = sprintf('%s%d', 'Blue Color Bin ', i);
% end
names{end+1} = 'city block dist';
info_table = cell2table(cell(0, 258), 'VariableNames',names);

% Looping through all the images in the directory
for k = 1:numel(S)
    F = fullfile(D,S(k).name);
    I = imread(F);
    I = rgb2gray(I);
    S(k).data = I; % optional, save data.

    % Extracting the colour plane of the current image
%    red = single(I(:, : , 1));
%     green = single(I(:, :, 2));
%     blue = single(I(:, :, 3));  
    
    %Getting bin values of each color plane
    [binval_red,binloc_red] = imhist(I);
%     [binval_green,binloc_green] = imhist(green);
%     [binval_blue,binloc_blue] = imhist(blue);
    I_row={S(k).name};
    for i=1:numel(binval_red)
       I_row{end+1} = binval_red(i);
    end
%     for i=1:numel(binval_green)
%        I_row{end+1} = binval_green(i);
%     end
%     for i=1:numel(binval_blue)
%        I_row{end+1} = binval_blue(i);
%     end
    cbd=0;
    %size(I_row)
    for i=2:numel(Q_row)
        diff = Q_row{i}-I_row{i};
        cbd = cbd + abs(diff);
    end
    I_row{end+1} = cbd;
    info_table = [info_table;I_row];
end

%size(info_table)
%size(I_row)
%size(Q_row)

% Replacing the NaN with values in the previous cell and replacing the 
% rows in the table in the ascending order of city block distance
info_table = sortrows(fillmissing(info_table, 'previous'), 'city block dist');
%disp(info_table);
writetable(info_table, 'lab4_1.xlsx','Sheet',3)

% Displaying the first 5 nearest image
subplot(3, 3, 2);
imshow(query_image);
title('Query image');
file_names = info_table(:, 'file_name').file_name; % Extracting the filenames of the images
for i = 1:6
    F = fullfile(D,char(file_names(i)));
    I = imread(F);
    I = rgb2gray(I);
    subplot(3, 3, i+3);
    imshow(I);
    title(char(file_names(i)));
end








% % Create an all black channel.
% allBlack = zeros(size(rgbImage, 1), size(rgbImage, 2), 'uint8');
% % Create color versions of the individual color channels.
% just_red = cat(3, redChannel, allBlack, allBlack);
% just_green = cat(3, allBlack, greenChannel, allBlack);
% just_blue = cat(3, allBlack, allBlack, blueChannel);
% % Recombine the individual color channels to create the original RGB image again.
% recombinedRGBImage = cat(3, redChannel, greenChannel, blueChannel);
% % Display them all.
% subplot(3, 3, 2);
% imshow(rgbImage);
% fontSize = 20;
% title('Original RGB Image', 'FontSize', fontSize)
% subplot(3, 3, 4);
% imshow(just_red);
% title('Red Channel in Red', 'FontSize', fontSize)
% subplot(3, 3, 5);
% imshow(just_green)
% title('Green Channel in Green', 'FontSize', fontSize)
% subplot(3, 3, 6);
% imshow(just_blue);
% title('Blue Channel in Blue', 'FontSize', fontSize)
% subplot(3, 3, 8);
% imshow(recombinedRGBImage);
% title('Recombined to Form Original RGB Image Again', 'FontSize', fontSize)
% % Set up figure properties:
% % Enlarge figure to full screen.
% set(gcf, 'Units', 'Normalized', 'OuterPosition', [0, 0, 1, 1]);
% % Get rid of tool bar and pulldown menus that are along top of figure.
% % set(gcf, 'Toolbar', 'none', 'Menu', 'none');
% % Give a name to the title bar.
% set(gcf, 'Name', 'Demo by ImageAnalyst', 'NumberTitle', 'Off')