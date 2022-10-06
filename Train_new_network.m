%% Script to train 70 student networks on Set1/Set2 and test on Set 4
clear variables; close all; clc;
% Script is used to train the individual CNNs created by the 70 teams. It
% uses the architecture (layers) each team created, trains it on set 1 and
% 2 (training and validation) and subsequently tests the network on set 4
% (test set). Accuracy, Sensitivity, Specificity are saved in a struct. 
% All trained networks are also saved.
%% Load data
% define path to daughter data
rootfolder = cd;
datafolder = [cd '...'];  % path to saved imds files
addpath(datafolder); 

% Load train and test data
load('imds_Set1.mat')  %  imds of Set1
load('imds_Set2.mat')  %  imds of Set2
load('imds_Set4.mat')  %  imds of Set4
                                                     
%% Define training options of the CNNs
options = trainingOptions('sgdm', ...
    'MaxEpochs',50, ...
    'ValidationData',Set2, ...
    'ValidationPatience', Inf, ...
    'ValidationFrequency',20, ...
    'Verbose',true, ...
    'Shuffle', 'every-epoch',...
    'MiniBatchSize',32,...
    'InitialLearnRate',0.001,...
    'Plots','training-progress');

%% load network layers of the CNNs
% add path to folder with networks/layers
datafolder = [cd '...'];    % path to network layers
addpath(datafolder); 
% create list with all networknames
layers = dir([datafolder '/']);

% path to save networks
save_path = [cd '...'];  

%% load network and its layers, train and determine performance
specs = struct;     % save performance measures to a struct
for i = 3:1:length(layers)
    net_name = layers(i).name;  
    specs(i-2).name = net_name;     % add name
    % Load layers
    Layer = load([datafolder '/' net_name]);  
    Layer = Layer.Layers;
    % train network and determine performance
    net = trainNetwork(Set1, Layer, options);

    % test on test set
    labels_pred = classify(net, Set4);               % classify test set
    accuracy = mean(labels_pred == Set4.Labels);     % determine accuracy
    specs(i-2).accuracy = accuracy;     % add accuracy
    % get confusion matrix and determine sensitivity/specificity
    CM = confusionchart(imds2_test.Labels, labels_pred); 
    % determine sensitivity and specificity
    sensitivity = CM.NormalizedValues(4)/ ...
                 (CM.NormalizedValues(4)+CM.NormalizedValues(2));
    specs(i-2).sensitivity = sensitivity;
    specificity = CM.NormalizedValues(1)/ ...
                 (CM.NormalizedValues(1)+CM.NormalizedValues(3));
    specs(i-2).specificity = specificity;
    
    % save network on save_path with network_name
    save([save_path net_name], 'net')
    close all;
end

% save struct
save('specs_networks', specs);
