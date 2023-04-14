%% load all DICOM files and show slices
% This script is used to convert the DICOM data into TIFF files. TIFF files
% are created for each slice in each scan. It uses the function
% save_as_tiff.m
% Additionnally, the annotations xlsx file is used to save each 
% annotation (corresponding to each slice) in an array.
%% save slices as TIFF images with label
% path to load cases from
path_load = '...';
% path to save images to
path_save = '...';

% load slice labelling from excel
labels_list = readtable('Annotations.xlsx', 'ReadRowNames', true, ...
                        'Range', 'A1:C149');
%% change size and scale of each image and save as .tiff file
% HU values are converted between 0 and 4096
WL = [1009 1139]; % lung window level 
new_labels = [];
names = labels_list.Properties.RowNames;
% Preprocess cases
for i = 1:1:size(names, 1)  %  length(listing)
    % find case
    name = names{i, 1};
    % find hemmorhage labelling in scan
    start_slice = table2array(labels_list({name}, {'slice_start'}));
    end_slice = table2array(labels_list({name}, {'slice_end'}));
    % There might be multiple hemorrhage ranges in one patient scan. If
    % this is the case the second time the case name occurs it receives
    % '_1' or '_2' behind the case name. If this is the case we first need 
    % to save this labelling, before saving the slices in the scan:
    if size(name, 2) > 4
        name = name(1:end-2);
        % load images and information of patient
        collection = dicomCollection([ path_load '/' name '/IMAGES/']);
        % Get first collection
        [images, spatial] = dicomreadVolume(collection(1,:));  
        % The labelling has to be adjusted since this is another hemorrhage 
        % range in the same case as the previous one
        start_slice_adj = length(images(1,1,1,:)) - start_slice;
        end_slice_adj = length(images(1,1,1,:)) - end_slice;
        % save labelling
        new_labels(end-start_slice_adj:end-end_slice_adj) = 1;
    else
        name = name;
        % load images and information of patient
        collection = dicomCollection([ path_load '/' name '/IMAGES/']);
        % Get first collection
        [images, spatial] = dicomreadVolume(collection(1,:));  
        % save images using save_as_tiff function
        labels_update = save_as_tiff(new_labels, images, path_save, ...
                                     name, start_slice, end_slice, WL);
        % update labelling
        new_labels = labels_update;
    end
end
% save label array
save('label_list', new_labels);




