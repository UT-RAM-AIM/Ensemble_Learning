# Ensemble_Learning
Repository containing code used for "Crowd-sourced Deep Learning for Intracranial Hemorrhage Identification: Wisdom of Crowds or Laissez Faire Information Corruption". All code was developed using MATLAB R2020a.

## Pre-processing data
DICOM data is converted to TIFF files using 'createTIF_ICH.m'. In the file the load and save path need to be specified, as wells as the location and name of the .xlsx file containing annotations. The script will load the files with `dicomCollection`, convert to 3D using `dicomreadVolume` and save each slice as TIFF file using the function script 'save_as_tiff.m'. Two examples of saved 2D slices can be seen below.

![image](/images/im0020_caseT1_noMask.PNG)  ![image](/images/im0245_caseT20_noMask.PNG)

Additionally, an annotations file (annotations.xlsx) is used to save annotations (ICH = 1, No ICH = 0) for every slice in an array. The annotations file describes the number of the slice where the hemorrhage starts and where it ends. The labels array needs to be saved manually.

After this'MaskBrain.m' can be used to remove the visible head support in TIFF files of the slices. It finds the gray value threshold and uses this to binarize the image. After some finetuning, this created mask is used on the TIFF image to remove the head support. Two examples can be seen below.

![image](/images/im0020_caseT1.PNG)   ![image](/images/im0245_caseT20.PNG)

All 2D slices are manually divided patient-wise into four sets in which the ratio ICH/NoICH is approximately similar (~34% ICH). The four sets consist of 1) Training set for individual CNNs (48% of all data), 2) Validation set for inidvidual CNNs (12% of all data), 3) Training set for ensemble learning methods (28% of all data), 4) Test set for both inidividual CNNs and ensemble learning methods (12% of all data). The labels array additionally needs to be split to match the created 4 sets. Alternatively, this patient-wise split could be realised using the DICOM data, which would take away the need to do that at this point.

Subsequently image datastores can be created using 'createDatastores.m' that are used for training the different networks. It needs the location of the 2D slices and the annotations file. Using `imageDatastore` it will link the location of each file to an annotation. This variable is saved and can be used for training. 

## Training seperate networks
The 'Train_new_network.m' file is used to train the individual CNNs. It requires paths to the image datastores, to the layers of the CNNs and the path of where the trained networks need to be saved. The options for training could be adjusted in `trainingOptions`. It uses the architecture (layers) of each network, trains and validates the networks using `trainNetwork` with the 1) Training set and 2) Validation set. Subsequently, it tests the trained network on by classifiying the images in the 4) Test set using `classify` and determines the `confusionchart`. Accuracy, sensitivity and specificity are saved in a struct for each network. All trained networks are saved as well. It will loop over all architecture found under the path to the CNN layers.

## Training ensembles and mrmr algorithm
'Ensemble_Learning.m' loads the individual networks and creates tables with predictions from every network on 3) Training set and 4) Test set. It requires paths to the image datastores and the trained networks and will obtain the prediction (probability that the image doesn't have ICH) for every image from every network. The predictions on 3) are used for analyses with the Minimum Redundancy Maximum Relevance (MRMR) algorithm (using `fscmrmr`), applying Majority Voting (MV) and for training the ensemble methods Decision Tree (DT, `fitctree`), Support Vector Machine (SVM, `fitcsvm`) and Multi-Input Deep Neural Network (MI-DNN). The MI-DNN is similar to a CNN or DNN, but in addition to the image, the array with predictions from the individual CNNs is also an input. Both inputs are merged at a later point (see Figure below).

![image](/images/mi-dnn.png)

To test MV and the trained DT, SVM, and MI-DNN, the predictions on 4) are used.  It will determine the accuracy on 4) for each Ensemble Learning method and will store it as a variable.

## Showing results in Figure
The 'make_figure1.m' is used to created Figure 3 from the manuscript. It requires an array of the accuracies of the CNNs on 4) and the accuracies of the Ensemble Learning methods need to be filled in. It will create a histogram with 10 bins of the CNN accuracies using `histfit` and will next fit a normal distribution to the data using `fitdist`. The average and 25th and 95th percentile are calculated and plotted. Finally, the accuracies of the Ensemble Methods are plotted (see Figure below).

![image](/images/Figure3.png)
