%% Test Ensemble Learning techniques
clear all; close all; clc;
% Loads the 70 trained networks and creates tables with prediction on set3
% and set4. This information is used to analyse with MRMR algorithm and 
% train + test MV, DT, SVM and MI-DNN.
%% Load imds
rootfolder = cd;
datafolder = [rootfolder '...']; % path to folder with imds
addpath(datafolder)

imds = load('Set3.mat'); % change to load correct imds
imds_set3 = imds.imds_set3; % change to correct imds name
%% Load all student networks and get accuracy on Set3
datafolder = [rootfolder '...']; % folder to trained networks
addpath(datafolder)
% Load networks, get predictions on Set3 and add to struct
for i = 1:1:70
    network(i).name = i;
    b = string(i) + '.mat';
    net = load(b); % Load network
    network(i).net = net;
    net = struct2cell(net); net = net{1,1};
    % change below to name of imds
    pred = predict(net, imds_set3); % get prediction scores on imds
    network(i).prediction = pred;
    % get classification scores and accuracy
    class = classify(net, imds_set3); 
    accuracy = mean(class == imds_set3.Labels);
    network(i).classpred = class;
    network(i).accuracy = accuracy;
end

% create table with prediction per network per image of Set3
predictions = table({network.prediction}.', 'VariableNames', ...
                    {'prediction'});
for i = 1:length(predictions.prediction{1}) % number of images
    for j = 1:height(predictions) % number of networks
        % save in one big table
        predictionTable(i,j) = predictions.prediction{j,1}(i,2);  
    end
end


%% Get accuracy on Set4
% load test set
imds = load('Set4.mat'); % change to load correct imds
imds_set4 = imds.imds_set4; % change to correct imds name
% Create prediction table from testset
for i = 1:1:70
    networkTest(i).name = i;
    b = string(i) + '.mat';
    net = load(b); % Load network
    networkTest(i).net = net;
    net = struct2cell(net); net = net{1,1};
    % change below to name of imds
    pred = predict(net, imds_set4); % get prediction scores on imds
    networkTest(i).prediction = pred;
    % get classification scores and accuracy
    class = classify(net, imds_set4); 
    accuracy = mean(class == imds_set4.Labels);
    networkTest(i).classpred = class;
    networkTest(i).accuracy = accuracy;
end

% create table with prediction per network per image of test set
predictionsTest = table({networkTest.prediction}.', 'VariableNames', ...
                        {'prediction'});
for i = 1:length(predictionsTest.prediction{1}) % number of images
    for j = 1:height(predictionsTest) % number of networks
        % save in one big table
        predictionTableTest(i,j) = predictionsTest.prediction{j,1}(i,2);  
    end
end


%% Calculate and show mutual information using Set3
[idx, scores] = fscmrmr(predictionTable, imds_set3.Labels);
bar(scores(idx))
xlabel('Predictor rank')
ylabel('Predictor importance')

%% Apply Majority Voting and test on Set4

% create matrix with all classifications of each network
for m = 1:1:length(networkTest)
    class_mat(:,m) = networkTest(m).classpred;
end

% Check each row for class with the most occurences
final_decision = mode(class_mat,2) ;
% Calculate accuracy with these prediction scores
MV_accuracy = mean(final_decision == imds_set4.Labels);

%% Train Decision Tree on Set3 and test on Set4
% train
tree = fitctree(predictionTable, imds_set3.Labels);
% predict on set4
test_label = predict(tree, predictionTableTest);
% determine error
errtest = mean(~(test_label==imds_set4.Labels));
% determine accuracy
DT_accuracy = 1 - errtest;

%% Train Support Vector Machine on Set3 and test on Set4
% Train
svm = fitcsvm(predictionTable, imds_set3.Labels, 'KernelFunction', ...
              'linear', 'Standardize', true);
% predict on set4
test_labelsvm = predict(svm, predictionTableTest);
% determine error
errtestsvm = mean(~(test_labelsvm==imds_set4.Labels));
% determine accuracy
SVM_accuracy = 1 - errtestsvm;

%% Prepare data to train multi-input DNN
% if already run before, continue to next cell

% create cell array from Set3 prediction table 
traincellFeatures = {};
for i=1:1:length(predictionTable)
    featureTrain = predictionTable(i,:);
    traincellFeatures{i,1} = featureTrain;
end
% create cell array from Set4 prediction table
testcellFeatures = {};
for i=1:1:length(predictionTableTest)
    featureTest = predictionTableTest(i,:);
    testcellFeatures{i,1} = featureTest;
end

% create Set3 cell array from labels
trainlabels = imds_set3.Labels;
traincellLabels = {};
for i=1:1:length(predictionTable)
    labelTrain = trainlabels(i,:);
    traincellLabels{i,1} = labelTrain;
end
% create Set4 cell array from labels
testlabels = imds_set4.Labels;
testcellLabels = {};
for i=1:1:length(predictionTableTest)
    labelTest = testlabels(i,:);
    testcellLabels{i,1} = labelTest;
end

% create Set3 cell array from images
traincellImages = {};
for i=1:1:length(predictionTable)
    imageTrain = imread(imds_set3.Files{i});
    traincellImages{i,1} = imageTrain;
end
% create Set4 cell array from images
testcellImages = {};
for i=1:1:length(predictionTableTest)
    imageTest = imread(imds_set4.Files{i});
    testcellImages{i,1} = imageTest;
end

% merge images, features and labels for Set3, Set4 is needed seperately 
traincellAll = [traincellImages traincellFeatures traincellLabels];

% create Tall Array from traincellAll and save 
tAset3 = tall(traincellAll); % create Tall Array
locnameTrain = [cd '...\tASet3.mat']; % specify location\name.mat
write(locnameTrain, tAset3);

% create Tall Arrays from seperate testcells
tAset4Image = tall(testcellImages); % create Tall Array for images
locnameTestImage = [cd '...\tAset4Images.mat']; % specify location\name.mat
write(locnameTestImage, tAset4Image);
tAset4Feat = tall(testcellFeatures); % create Tall Array for features
locnameTestFeat = [cd '...\tAset4Feat.mat']; % specify location\name.mat
write(locnameTestFeat, tAset4Feat);

%% Load Tall Arrays if already created otherwise run cell below
% load Tall Array with images,features and labels of Trainset as datastore
dts_set3 = datastore([cd '...\tASet3.mat'], 'Type', 'tall');

%% Create and train multi-input DNN
% Sadly, multi-input networks do not support validation, so we can not use
% a validation set

% Define image input
layers1 = [
    imageInputLayer([128 128],'Name','input')  
    convolution2dLayer(3,16,'Padding','same','Name','conv_1')
    batchNormalizationLayer('Name','BN_1')
    reluLayer('Name','relu_1')
    fullyConnectedLayer(70,'Name','fc11')   % adjust to number of networks
    additionLayer(2,'Name','add')
    fullyConnectedLayer(2,'Name','fc12')
    softmaxLayer('Name','softmax')
    classificationLayer('Name','classOutput')];

lGraph = layerGraph(layers1);

% Define vector input
layers2 = [
    % adjust second input to number of networks
    imageInputLayer([1 70], 'Name', 'vinput')  
    % adjust to number of networks
    fullyConnectedLayer(70, 'Name', 'fc21')];  

lGraph = addLayers(lGraph, layers2);
lGraph = connectLayers(lGraph, 'fc21', 'add/in2');
% if you want to plot the network, uncomment the line below
%plot(lGraph)

options = trainingOptions('sgdm', ...
    'MaxEpochs',25, ...
    'Verbose',true, ...
    'Shuffle', 'never',...
    'MiniBatchSize',32,...
    'InitialLearnRate',0.001,...
    'Plots','training-progress');

% train network
net = trainNetwork(dts_set3, lGraph, options);

%% Test performance of network
% load Tall Array images and features from set4
dts_set4I = datastore([cd '...\tAset4Images.mat'], 'Type', 'tall');
dts_set4F = datastore([cd '...\tAset4Feat.mat'], 'Type', 'tall');
% create input from set4 for trained DNN
dts_set4IF = combine(dts_set4I, dts_set4F);

% get prediction scores on set4
pred = predict(net, dts_set4IF); 
% get classification scores and accuracy
class = classify(net, dts_set4IF); 
DNN_accuracy = mean(class == imds_set4.Labels); 
