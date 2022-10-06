# Ensemble_Learning
Repository containing code used for "Crowd-sourced Deep Learning for Intracranial Hemorrhage Identification: Wisdom of Crowds or Laissez Faire Information Corruption". All code was developed using MATLAB R2020a.

## Pre-processing data
DICOM data can be converted to TIFF files by running the script `createTIF_ICH`. In the file the load and save path need to be specified, as well as the location and name of the .xlsx file containing annotations. Every slice will be saved as a TIFF file. Two examples of saved 2D slices can be seen below.

![image](/images/im0020_caseT1_noMask.PNG)  ![image](/images/im0245_caseT20_noMask.PNG)

Additionally, the annotations file is used to save annotations (ICH = 1, No ICH = 0) for every slice in an array. The annotations file describes the number of the slice where the hemorrhage starts and where it ends for every scan. The resulting labelling is also saved.

After this the script `MaskBrain` can be run to remove the visible head support in TIFF files of the slices. Paths to TIFF files and the output need to specified. Two resulting examples can be seen below.

![image](/images/im0020_caseT1.PNG)   ![image](/images/im0245_caseT20.PNG)

All 2D slices should be manually divided patient-wise into four sets in which the ratio ICH/NoICH is approximately similar (~34% ICH). The four sets consist of 1) Training set for individual CNNs (48% of all data), 2) Validation set for inidvidual CNNs (12% of all data), 3) Training set for ensemble learning methods (28% of all data), 4) Test set for both inidividual CNNs and ensemble learning methods (12% of all data). The labels array additionally needs to be split to match the created 4 sets. Alternatively, this patient-wise split could be realised using the DICOM data before any processing, which would take away the need to do that at this point.

Subsequently image datastores can be created by running `createDatastores`, necessary for training the different networks. Locations of the 2D slices and the annotations file need to be defined in the script. This resulting variable is saved and can be used for training. 

## Training seperate networks
Run `Train_new_network` to train the individual CNNs. It requires paths to the image datastores, to the layers of the CNNs and the output path to store the trained networks. Subsequently, it tests every trained network on the Test set and its accuracy, sensitivity and specificity are saved in a struct for each network. !Important: Results might vary from the manuscript due to the stochastic nature of training CNNs!

## Training ensembles and mrmr algorithm
Running `Ensemble_Learning` requires paths to the image datastores and the trained networks and will obtain the prediction (probability that the image doesn't have ICH) for every image from every network. The predictions on 3) are used for analyses with the Minimum Redundancy Maximum Relevance (MRMR) algorithm, applying Majority Voting (MV) and for training the ensemble methods Decision Tree (DT), Support Vector Machine (SVM) and Multi-Input Deep Neural Network (MI-DNN). The MI-DNN is similar to a CNN or DNN, but in addition to the image, the array with predictions from the individual CNNs is also an input. Both inputs are merged at a later point (see Figure below).

![image](/images/mi-dnn.png)

To test MV and the trained DT, SVM, and MI-DNN, the predictions on 4) are used. Accuracies on 4) for each Ensemble Learning method are determined and stored as a variable and can be viewed in the Workspace.

## Showing results in Figure
Run `make_figure1` to create Figure 3 from the manuscript. It requires an array of the accuracies of the CNNs on 4) and the accuracies of the Ensemble Learning methods need to be added in order to reproduce a similar Figure (see Figure below). 

![image](/images/Figure3.png)
