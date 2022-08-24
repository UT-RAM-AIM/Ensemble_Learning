%% Function to save labels with corresponding images as .tiff
function labels_update = save_as_tiff(new_labels, images, path, ...
                                    case_name, slice_start, slice_end, WL)
%% Save each slice as a .tiff image
%
% Given information on the labels and the patients scan, this function
% processes and saves every slice in the patient scan as a .tiff image and
% updates the labels array.
%
% Inputs:
%
% new_labels:   Numeric array. Current list of labels for every slice in  
%               every scan (0 = no hemorrhage, 1 = hemorrhage)
%
% images:       images from scan loaded with dicomreadVolume
%
% path:         location where to save .tiff images
%
% case_name:    name of the current patient case
%
% slice_start:  slice number where the hemorrhage sequence starts
%
% slice_end:    slice number where the hemorrhage sequence ends
%
% WL:           HU lung window level
%
% Outputs:
%
% labels_update: New list with update labels.
%% =======================================================================
label_length = length(new_labels);

% for every image
for m = 1:length(images(1,1,1,:))
    image = imresize(images(:,:,:,m), [128 128]);  % resize
    image = mat2gray(image, WL);    % adjust HU  level and rescale [0, 1]
    if m >= slice_start && m<= slice_end
        label = 1;  % hemorrhage label
    else
        label = 0;  % no-hemorrhage label
    end
    pos = label_length + m;
    new_labels(pos,1) = label;
    % determine filename and save image as .tiff
    if pos < 10
        save_path = [path ['im000', num2str(pos), '_case', case_name, '.tif']];  % path + name
    elseif (10 <= pos) && (pos < 100)
        save_path = [path ['im00', num2str(pos), '_case', case_name, '.tif']];  % path + name
    elseif (100 <= pos) && (pos < 1000)
        save_path = [path ['im0', num2str(pos), '_case', case_name, '.tif']];  % path + name
    else
        save_path = [path ['im', num2str(pos), '_case', case_name, '.tif']];  % path + name
    end
    imwrite(image, save_path, 'Resolution', [128 128]);
end
% update and return new label list
labels_update = new_labels;
end