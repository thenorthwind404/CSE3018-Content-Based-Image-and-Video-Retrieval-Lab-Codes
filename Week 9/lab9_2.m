clc
clear all
close all
img = imread('TPTest2.png');
imshow(img);

img = imbinarize(im2gray(img), graythresh(img));

[B, L] = bwboundaries(img);
figure;
imshow(img);
hold on;
for k=1:length(B)
boundary = B{k};
plot(boundary(:,2), boundary(:,1), 'g', 'LineWidth', 2);
end

[L, N] = bwlabel(img);
d = sprintf("N Value returned by bwlable = %d",N);
disp(d);
RGB = label2rgb(L, 'hsv', [.5 .5 .5], 'shuffle');
figure;
imshow(RGB);
hold on;
for k=1:length(B)
boundary = B{k};
plot(boundary(:,2), boundary(:,1), 'w', 'LineWidth', 2);
text(boundary(1,2)-11, boundary(1,1)+11, num2str(k), 'Color', 'y', ...
'FontSize', 14, 'FontWeight', 'bold');
end


stats = regionprops(L, 'all');
temp = zeros(1, N);
for k=1:N

temp(k) = 4*pi*stats(k,1).Area / (stats(k,1).Perimeter)^2;
stats(k,1).ThinnessRatio = temp(k);


temp(k) = (stats(k, 1).BoundingBox(3)) / (stats(k,1).BoundingBox(4));
stats(k,1).AspectRatio = temp(k);
end



areas = zeros(1,N);
for k=1:N
areas(k) = stats(k).Area;
end
TR = zeros(1,N);
for k=1:N
TR(k) = stats(k).ThinnessRatio;
end
figure();
hold on;
cmap = colormap(lines(16));
for k=1:N
scatter(areas(k), TR(k), [], cmap(k,:), 'filled'), ylabel('Thinness Ratio'), xlabel('Area');
hold on;
end

for i=1:10
     d = sprintf("SHAPE - %d",i);
     disp(d);
     d = sprintf(" Area %d : %f ",i,stats(i).Area);
     disp(d);    
     d = sprintf(" Centroid %d : (%f,%f) ",i,stats(i).Centroid(1),stats(i).Centroid(2));
     disp(d);
     d = sprintf(" Orientation %d : %f ",i,stats(i).Orientation);
     disp(d);
     d = sprintf(" Euler Number %d : %f ",i,stats(i).EulerNumber);
     disp(d);
     d = sprintf(" Eccentricity %d : %f ",i,stats(i).Eccentricity);
     disp(d);
     d = sprintf(" Asoect Ratio %d : %f ",i,stats(i).AspectRatio);
     disp(d);
     d = sprintf(" Perimenter %d : %f ",i,stats(i).Perimeter);
     disp(d);     
     d = sprintf(" Thinness Ratio %d : %f ",i,stats(i).ThinnessRatio);
     disp(d);          
end