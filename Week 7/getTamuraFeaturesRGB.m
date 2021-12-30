function feat = getTamuraFeaturesRGB(imgFilePath)
feat = double(zeros(1,6));
img = imread(imgFilePath);

red = img(:,:,1);
green = img(:,:,2);
blue = img(:,:,3);

R_DLMI = double(red(:)); % Double Linear Matrix Image
G_DLMI = double(green(:)); % Double Linear Matrix Image
B_DLMI = double(blue(:)); % Double Linear Matrix Image

% Red
% Contrast
alpha = 0.25;
feat(1, 1) = var(R_DLMI)/(kurtosis(R_DLMI)^alpha);
% Directionality
[feat(1, 2), sita] = directionality(red);
% Coarseness
feat(1, 3) = coarseness(red, 5);
% Linelikeness
feat(1, 4) = linelikeness(red, sita, 4);
% Regularity
feat(1, 5) = regularity(red, 64);
% Roughness
feat(1, 6) = feat(1, 1) + feat(1, 3);

% Green
% Contrast
alpha = 0.25;
feat(1, 7) = var(G_DLMI)/(kurtosis(G_DLMI)^alpha);
% Directionality
[feat(1, 8), sita] = directionality(green);
% Coarseness
feat(1, 9) = coarseness(green, 5);
% Linelikeness
feat(1, 10) = linelikeness(green, sita, 4);
% Regularity
feat(1, 11) = regularity(green, 64);
% Roughness
feat(1, 12) = feat(1, 7) + feat(1, 9);

% Blue
% Contrast
alpha = 0.25;
feat(1, 13) = var(B_DLMI)/(kurtosis(B_DLMI)^alpha);
% Directionality
[feat(1, 14), sita] = directionality(blue);
% Coarseness
feat(1, 15) = coarseness(blue, 5);
% Linelikeness
feat(1, 16) = linelikeness(blue, sita, 4);
% Regularity
feat(1, 17) = regularity(blue, 64);
% Roughness
feat(1, 18) = feat(1, 13) + feat(1, 15);
end