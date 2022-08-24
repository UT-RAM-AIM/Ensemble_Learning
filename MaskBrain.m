%% Remove headsupport from image after they are preprocessed
% Uses the pre-processed data created by 'createTIF_ICH.m' and further
% processes the TIFF files by removing head support
close all; clear all; clc;
%%
% Load images form location
% Specify path to load from
path_load = '...'; 
listing = dir(path_load); % list images in image location

% Specify path to save masked images to
path_save = '...';

%% Mask the head support for every image
for i = 3:1:length(listing)
    image = imread([path_load listing(i).name]); % laod image
    % Find threshold level
    level = graythresh(image);
    % apply level to binarize image
    BW = imbinarize(image, level);
    % fill holes in binarized image
    BW = imfill(BW, 'holes');
    % Select brain in the binary image to remove head support
    c = [64];  % column number
    r = [64];  % row number
    BW = bwselect(BW, c, r, 8);  % last input specifies connectedness
    % show original image and binary mask
    %imshowpair(image, BW, 'montage')
    
    % The mask removes too much of the top part of the image, i.e. it 
    % removes eyes and nose etc. Therefore, the mask will only be applied 
    % roughly around the brain. This will remove headsupport
    BW(1:110, 17:115) = 1;
    % Apply mask
    image(BW == 0) = 0;
    save_path = [path_save listing(i).name];
    % save masked image
    imwrite(image, save_path);
end
