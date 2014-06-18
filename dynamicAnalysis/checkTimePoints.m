function [ subWithIncompleteData ] = extractTC(subListFile, dataDir)
%This function will check the time points for each subject and output a sublist with incomplete data acqusition
% 1. subListFile: a text file with subjectID, if not under the current directory, please add path
% e.g. subListFile='/home/data/Projects/Zhen/ADHDStimulant/data/subList16subRmdMotionOutliers.txt';

subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
subList=cell2mat(subList{1})
numSub=length(subList)

subWithIncompleteData={};
t=0;
for i=1:length(subList)
    sub=subList(i, 1:9)
    
    if ~exist([dataDir, sub], 'dir')
        disp(['Subject ', sub, 'dose not exist!'])
    end
       
    data=[dataDir, 'normFunImg_', sub, '_3mm.nii'];
    
    [AllVolume, VoxelSize, ImgFileList, Header1, nVolumn] =rest_to4d(data);
    [nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
    brainSize = [nDim1 nDim2 nDim3];
if nDimTimePoints~=900  
t=t+1;  
subject=cellstr(sub);
subWithIncompleteData{t,1}=subject;
subWithIncompleteData{t,2}=nDimTimePoints;
    
end

