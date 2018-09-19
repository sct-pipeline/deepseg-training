%**************************************************************************
%
%   Reading JIM roi data, fitting an ellipse and returning the APW and LRW.
%
%   MFC 29.05.2015
%
%   RESEARCH USE ONLY!
%
%**************************************************************************
 
function [x_ROI, y_ROI, Slice_Number,missed_rois] = JIM_Reader_PK(filename)
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
 

