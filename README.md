# Ensemble_Learning
Repository of the code used for "Crowd-sourced Deep Learning for Intracranial Hemorrhage Identification: Wisdom of Crowds or Laissez Faire". All code was developed in MATLAB R2020a.

## Pre-processing data
Convert DICOM data to TIF files run the following script in MATLAB:

```
createTIF_ICH
```

Variables `path_load` and `path_save`, as well as the path to `Annotations.xlsx` (containing annotations) should be specified. The script will save every slice as a TIFF file along with an annotations file `new_labels`. The annotations file (`ICH = 1`, `No ICH = 0`) describes the level of the slice where the hemorrhage starts and where it ends, for every scan. Two examples are shown below:

![image](/images/im0020_caseT1_noMask.PNG)  ![image](/images/im0245_caseT20_noMask.PNG)

Then remove visible head support in TIF files by running:

```
MaskBrain
```

As before, `path_load` and `path_save` need to be specified. Examples of the saved output:

![image](/images/im0020_caseT1.PNG)   ![image](/images/im0245_caseT20.PNG)

## Data split

Split into the four sets was realised manually to ensure and approximately similar ratio (~34% ICH) of ICH/No-ICH:

All 2D slices were manually divided patient-wise into: 

* Training set for individual CNNs (48% of all data), 
* Validation set for inidvidual CNNs (12% of all data), 
* Training set for ensemble learning methods (28% of all data), and 
* Test set for both inidividual CNNs and ensemble learning methods (12% of all data). 

The `labels` array further needs to be split to match the sets created. Alternatively, this patient-wise split could be achieved using the DICOM data before any processing, which would obviate the need to do the same at this point.

Next, create image datastores from the four sets run:

```
createDatastores
```

Path to 2D TIF files and annotations needs to be defined. Script saves image `datastores` for every set that are used to train the networks. 

## Training seperate networks

```
Train_new_network
```

Define the path to image `datastores`, the layers of the CNNs, and the output path to store the trained networks. The script will save trained networks and specs of the networks (sensitivity/specificity) 

**Results may vary due to the stochastic nature of training CNNs unless the seed is explicitly set.**

## Training ensembles and MRMR algorithm

```
Ensemble_Learning
```

Specify path to the image `datastores` and to trained networks in the script. Output is the prediction (probability that the image *does not include* an ICH) for every image from every network on 3) and 4) as well as accuracies of the different techniques (see workspace).

The predictions from the third eplit above are used for analyses with the Minimum Redundancy Maximum Relevance (MRMR) algorithm, applying Majority Voting (MV) and for training the ensemble methods Decision Tree (DT), Support Vector Machine (SVM) and Multi-Input Deep Neural Network (MI-DNN). The MI-DNN is similar to a CNN or DNN. However, in addition to the image, the array with predictions from the individual CNNs should also be provided as an input. Both inputs are merged at a later point (see the Figure below).

![image](/images/mi-dnn.png)

To test MV and the trained DT, SVM, and MI-DNN, the predictions on the last test set above are used and accuracies are calculated.

## Citation

Citation to manuscript: 

E.I.S. Hofmeijer, C.O. Tan, F. van der Heijden, R. Gupta: "Crowd-Sourced Deep Learning for Intracranial Hemorrhage Identification: Wisdom of Crowds or Laissez-Faire", American Journal of Neuroradiology Jun 2023, DOI: 10.3174/ajnr.A7902

