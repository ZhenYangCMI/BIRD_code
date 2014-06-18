% This script is for compte the overlap across dif strategeis for CWAS results

clear
clc
close all

% define path and variables
fileDir='/home/data/Projects/BIRD/figs/easythresh_110sub/';
figDir='/home/data/Projects/BIRD/figs/paper_figs/';
effect='INT'

% define path and variables
maskDir='/home2/data/Projects/BIRD/figs/paper_figs/clusterMask/INT/';

clustList=dir([maskDir, 'cluster_mask_*.nii.gz'])

% read in the MNI stand mask
standardMask=[atlasDir, 'MNI152_T1_2mm_brain_mask.nii.gz'];
[OutdataStand,VoxDimStand,HeaderStand]=rest_readfile(standardMask);
dataStand1D=reshape(OutdataStand,[],1);
standIndex = find(dataStand1D);

% read in the cluster mask
t=1;
for i=1:length(clustList)
    effect=clustList(i).name
    effect=cellstr(effect(14:end-7));
    dataFile=[
    maskFile=[maskDir, 'cluster_mask_', char(effect), '.nii.gz'];
        
    % read in the mask and reshape to 1D
    [OutdataMask,VoxDimMask,HeaderMask]=rest_readfile(maskFile);
    [nDim1Mask nDim2Mask nDim3Mask]=size(OutdataMask);
    maskImg1D=reshape(OutdataMask, [], 1);
    maskImg1D=maskImg1D(standIndex, 1);
    numClust=length(unique(maskImg1D(find(maskImg1D~=0))))
    
    for j=1:numClust