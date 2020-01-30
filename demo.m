clear all

addpath('./DTCWT');
addpath('./disCLBP');
addpath('./GLRL');

% read image
img = im2double(imread('testimg.png'));
% convert to grayscale
img = rgb2gray(img);
% create ROI
mask = zeros(size(img));
mask(10:end-9,20:end-19) = 1;

% find texture features
features = findTextureFeatures(img, [], [], [], [1 4 5], mask, 0);
