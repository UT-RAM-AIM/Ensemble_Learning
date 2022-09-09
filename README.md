# Ensemble_Learning
Repository containing code used for "Crowd-sourced Deep Learning for Intracranial Hemorrhage Identification: Wisdom of Crowds or Laissez Faire Information Corruption". All code was developed using MATLAB R2020a.

## Pre-processing data
DICOM data is converted to TIFF files using 'createTIF_ICH.m'. TIFF files are created for each slice in each scan. The .m file also uses the function 'save_as_tiff'. 

![image](/images/im0020_CaseT1.tif)

Additionally, an annotations file is used to save annotations (ICH = 1, No ICH = 0) for every slice in an array. 
Afterwards 'MaskBrain.m' can be used to remove the visible head support in TIFF files of the slices.

![image](/images/im0020_CaseT1_mask.png)
![im0020_caseT1_mask](https://user-images.githubusercontent.com/46965065/189350192-e19b45ec-1907-43ef-a2b8-f51feca8adf7.png)

All data is manually divided patient-wise into four sets in which the ratio ICH/NoICH is approximately similar (~34% ICH). The four sets consist of 1) Training set for individual CNNs (48% of all data), 2) Validation set for inidvidual CNNs (12% of all data), 3) Training set for ensemble learning methods (28% of all data), 4) Test set for both inidividual CNNs and ensemble learning methods (12% of all data). Subsequently image datastores can be created using 'createDatastores.m' that are used for training the different networks.

## Training seperate networks
The 'Train_new_network.m' file is used to train the individual CNNs. It uses the architecture (layers) of each network, trains and validates the networks on 1) Training set and 2) Validation set and subsequently tests the trained network on 4) Test set. Accuracy, sensitivity and specificity are saved in a struct for each network. All trained networks are saved.

## Training ensembles and mrmr algorithm
'Ensemble_Learning.m' loads the individual networks and creates tables with predictions on 3) Training set and 4) Test set. The predictions on 3) are used for analyses with the Minimum Redundancy Maximum Relevance (MRMR) algorithm and for training the ensemble methods Decision Tree (DT), Support Vector Machine (SVM) and Multi-Input Deep Neural Network (MI-DNN). To test Majority Voting and the trained DT, SVM, and MI-DNN, the predictions on 4) are used. MI-DNN additionally uses the TIFF file as input next to the predictions from the individual CNNs.

## showing results in Figure
The 'make_figure1.m' is used to created Figure 3 from the manuscript.
