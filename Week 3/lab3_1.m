clc
clear all
close all
img = imread('Harshith.jpg');
subplot(2,2,1);
imshow(img);
title('Original Image');

subplot(2,2,2);
imshow(255 - img);
title('CMY Image');

subplot(2,2,3);
imshow(rgb2hsv(img));
title('HSV Image');

subplot(2,2,4);
imshow(rgb2gray(img));
title('Grayscale Image');