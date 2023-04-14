%% Create the 4 data sets and save images + labels as image Datastore
clear all; close all; clc;
% Code below creates image datastores (imds). imds of the four data sets
% are necessary for training the individual networks and ensembles.
% Assumed is that the four sets are already in seperate folders, since
% data split is made manually
%%
% Data is already divided into the four sub sets in such a way that every
% set consists of approximately 35% hemorrhage images
% The labels file needs to be divided accordingly
% See file 'Hemorrhage_Annotations_Processed.xlsx' for used division

% Load data as imds
rootfolder = cd;
datafolder = [rootfolder '...']; % location of data set to be saved
addpath(datafolder)
imds = imageDatastore(fullfile(datafolder, 'im*'), 'LabelSource', 'none');
% load labels of corresponding set
load labels.mat
imds.Labels = labels;   % name of loaded label array

% save imds
save('imds_name', imds)
