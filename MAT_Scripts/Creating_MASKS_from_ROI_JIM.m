%**************************************************************************
%
%   Reading JIM roi data, and creating masks
%
%   MFC 12.08.2018
%
%   Author : Sreenath Pruthvi Kyathanahally
%**************************************************************************
 

clear
clc
close all
file_location='/Users/pruthvi_local/Desktop/Lesion_Segmentation/Selected_for_AutoQC/';
cd(file_location);
filenames=dir('*.nii');
 
for i=1:length(filenames)  
[~,name,ext] = fileparts(filenames(i).name);
Image_input=[name,'.nii'];ROI_input=[name,'_DP.roi'];
 
if ~exist([file_location ROI_input], 'file') == 1
    missed_files_list1{i,1}=Image_input;
    
else
    AA=load_untouch_nii(Image_input);
    [x_ROI, y_ROI,Slice_Number,missed_rois] = JIM_Reader_PK01(ROI_input);
    
    if (missed_rois==0)
 
        x_ROI=x_ROI';y_ROI=y_ROI';
 
        Dimen=AA.hdr.dime.pixdim;
        X_scaling=1/Dimen(2);
        Y_scaling=1/Dimen(3);
 
        BB=AA.img;CC=BB(:,:,(Slice_Number));DD=imadjust(CC);
 
        Image_Size=size(AA.img);
        XX_Size=Image_Size(1);YY_Size=Image_Size(2);ZZ_Size=Image_Size(3);
 
        %%
        %Rotation
        theta = pi/2; A2 = [cos(theta) sin(theta) 0; -sin(theta) cos(theta) 0; 0 0 1]; tform2 = maketform('affine', A2); uv2 = tformfwd(tform2, [x_ROI y_ROI]);%;plot(uv2(:,1),uv2(:,2))
        % Scaling
        A1 = [X_scaling 0 0; 0 Y_scaling 0; 0 0 1];tform1 = maketform('affine', A1);uv1 = tformfwd(tform1, [uv2(:,1) uv2(:,2)]);%figure;plot(uv1(:,1),uv1(:,2))
        % Rotated_scaled_ROI
        x_ROI1=uv1(:,1); y_ROI1=uv1(:,2); x_ROI2=x_ROI1+(XX_Size/2 + 0.5); y_ROI2=y_ROI1+(YY_Size/2+0.5);
 
        % Convert ROI to Mask
        ROI_Mask_all_slices=zeros(Image_Size);
        ROI_Mask_all_slices(:,:,(Slice_Number)) = poly2mask(x_ROI2,y_ROI2,XX_Size,YY_Size);
        AA.img=ROI_Mask_all_slices;
        save_untouch_nii(AA, ['/Users/pruthvi_local/Desktop/Lesion_Segmentation/Selected_for_AutoQC/Masks/' ,name,'_mask.nii'])
    else
        missed_rois_list2{i,1}=missed_rois;
        
    end
end
end
 
No_DP_ROI_file = missed_files_list1(~any(cellfun('isempty', missed_files_list1), 2), :);
No_ROI_drawn = missed_rois_list2(~any(cellfun('isempty', missed_rois_list2), 2), :);




 
function [x_ROI, y_ROI, Slice_Number,missed_rois] = JIM_Reader_PK01(filename)
% this function reads the ROI file given as input and calculates the best
% ellipse fit and the corrisponding APW and LRW
%
% INPUT:    pn: ROI file path and name to be analysed
%
% OUTPUT:   meanAPW: mean of APW vector 
%           meanLRW: mean of LPW vector 
%           APW:    vector contaning all anterior-posterior lengths of all 
%                   slices present in the ROI, they correspond to the size 
%                   of the short axis of the ellipse
%           LRW :   vector contaning all left-right lengths of all
%                   slices present in the ROI, they correspond to the size 
%                   of the long axis of the ellipse
 
 
fid = fopen(filename);
 
 
% Initialising things
goodData = false;
minNumPts = 5;
xROI=cell(1,1000);
yROI=cell(1,1000);
 
% Extract the info; this is spinal cord info:
disp('Extracting ROI boundaries from .roi file...')
while ~feof(fid)
    fileLine = fgetl(fid); % read line by line the file
    
    if contains(fileLine, 'Begin Irregular ROI')
     while ~feof(fid)
        fileLine = fgetl(fid); % read line by line the file
 
     if contains(fileLine, 'Slice')
               % This is a new slice; find the slice no. & reset the counter:
        sliceNum = str2double(fileLine(strfind(fileLine, '=')+1 : end));
        Slice_Number=sliceNum;
        counter = 1;
        goodData = true;
        % Read the next lines and make sure this is valid data.  It is
        % deemed valid if there isn't a stats error and if the no. of
        % points in the ROI is above a threshold number (minNumPts):
        fileLine = fgetl(fid);   % Created by
        fileLine = fgetl(fid);   % Statistics
        
        if strfind(fileLine, 'error')
            % There was a problem extracting the data
            goodData = false;
        end
        fileLine = fgetl(fid);   % Begin
        fileLine = fgetl(fid);   % Points
        
        numPoints = str2double(fileLine(strfind(fileLine, '=')+1:end));
        if numPoints < minNumPts
            % Not enought points to be a valid ROI:
            goodData = false;
        end
       
    while ~feof(fid)
    fileLine = fgetl(fid); % read line by line the file
 
        
    if contains(fileLine, 'X')
        if goodData && counter < numPoints+1
            % This is the data:
            equals = strfind(fileLine, '=');
            semiColon = strfind(fileLine, ';');
            xROI{sliceNum}(counter) = str2double(fileLine(equals(1)+1:semiColon-1));
            yROI{sliceNum}(counter) = str2double(fileLine(equals(2)+1:end));
            counter = counter + 1;    
        end
   end
    end    
    
     end
    end
   end
end
fclose(fid);
 
% if there are empty slices:
isEmptyIdx=cellfun(@(elem)isempty(elem),xROI);
xROI=xROI(~isEmptyIdx);
yROI=yROI(~isEmptyIdx);
 
if (isempty(xROI)==0) 
x_ROI=xROI{1,1};
y_ROI=yROI{1,1};
missed_rois=0;

else
    missed_rois=filename;
    x_ROI=0;
    y_ROI=0;
    Slice_Number=0;
end
end









