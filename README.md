# Ensemble_Learning
Repository containing code used for "Crowd-sourced Deep Learning for Intracranial Hemorrhage Identification: Wisdom of Crowds or Laissez Faire". All code was developed using MATLAB R2020a.

## Pre-processing data
1. To convert DICOM data to TIF files run the following script in MATLAB:

```
createTIF_ICH
```

In this script the 'path_load' and 'path_save' need to be specified, as well as the path to the 'Annotations.xlsx' file containing annotations. The script will save every slice as a TIFF file and save an annotations file 'new_labels'. The annotations file (ICH = 1, No ICH = 0) describes the number of the slice where the hemorrhage starts and where it ends for every scan. Two examples of saved 2D slices can be seen below:

![image](/images/im0020_caseT1_noMask.PNG)  ![image](/images/im0245_caseT20_noMask.PNG)

2. Remove visible head support in TIF files by running:

```
MaskBrain
```

Again 'path_load' and 'path_save' need to be specified. Examples of the saved output:

![image](/images/im0020_caseT1.PNG)   ![image](/images/im0245_caseT20.PNG)

## Data split
Split into the four sets was realised manually to ensure and approximately similar ratio (~34% ICH) of ICH/No-ICH:
All 2D slices were manually divided patient-wise into: 1) Training set for individual CNNs (48% of all data), 2) Validation set for inidvidual CNNs (12% of all data), 3) Training set for ensemble learning methods (28% of all data), 4) Test set for both inidividual CNNs and ensemble learning methods (12% of all data). The labels array additionally needs to be split to match the created 4 sets. Alternatively, this patient-wise split could be realised using the DICOM data before any processing, which would take away the need to do that at this point.

3. To create image datastores from the four sets run:

```
createDatastores
```

Path to 2D TIF files and annotations needs to be defined. Script saves image datastores for every set that are used to train the networks. 

## Training seperate networks
4. Train individual CNNs by running:

```
Train_new_network
```

Define the path to image datastores, the layers of the CNNs and the output path to store the trained networks. The script will save trained networks and specs of the networks (sensitivity/specificty) 
!Important: Results might vary due to the stochastic nature of training CNNs!

## Training ensembles and mrmr algorithm
5. To train the Ensemble Learning techniques, run:

```
Ensemble_Learning
```

Specify path to the image datastores and the trained networks in the script. Output is the prediction (probability that the image doesn't have ICH) for every image from every network on 3) and 4) as well as accuracies of the different techniques (see workspace).

The predictions on 3) are used for analyses with the Minimum Redundancy Maximum Relevance (MRMR) algorithm, applying Majority Voting (MV) and for training the ensemble methods Decision Tree (DT), Support Vector Machine (SVM) and Multi-Input Deep Neural Network (MI-DNN). The MI-DNN is similar to a CNN or DNN, but in addition to the image, the array with predictions from the individual CNNs is also an input. Both inputs are merged at a later point (see Figure below).

![image](/images/mi-dnn.png)

To test MV and the trained DT, SVM, and MI-DNN, the predictions on 4) are used and accuracies are calculated.

## Citation
Citation to manuscript:
