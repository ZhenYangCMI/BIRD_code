% This script extract ROI mean values for each measure and concate ROImean across all measures
clear
clc
close all
addpath /home/data/Projects/Zhen/commonCode
codeDir='/home/data/Projects/Zhen/commonCode/';
javaaddpath([codeDir, 'poi_library/poi-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/poi-ooxml-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/poi-ooxml-schemas-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/xmlbeans-2.3.0.jar']);
javaaddpath([codeDir, 'poi_library/dom4j-1.6.1.jar']);
javaaddpath([codeDir, 'poi_library/stax-api-1.0.1.jar']);

project='BIRD';

effect='ME'; % 'ME' or 'INT'
if strcmp(effect, 'ME')
    measureList={'CWASME_ROI1', 'CWASME_ROI2', 'CWASME_ROI3'}
    %measureList={'ReHo','fALFF', 'VMHC', 'DegreeCentrality', 'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4', 'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9', 'CWASME_ROI1', 'CWASME_ROI2', 'CWASME_ROI3', 'CWASME_ROI4' };
elseif strcmp(effect, 'INT')
    measureList={'ReHo','fALFF', 'VMHC', 'DegreeCentrality', 'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4', 'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9', 'CWASINT_ROI1', 'CWASINT_ROI2', 'CWASINT_ROI3', 'CWASINT_ROI4' };
end


numClusters=zeros(length(measureList), 2);
% load subList
subListFile='/home/data/Projects/Zhen/BIRD/data/final110sub.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
subList=cell2mat(subList{1});
numSub=length(subList)

subID{1,1}='subID';
for m=1:numSub
    subID{m+1,1}=subList(m,1:9);
end

outputDir=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy1_24_14_reorganized/ROIBasedAnalysis/'];
clustMeanConcate=[];
clustNameConcate=[];

for i=1:length(measureList)
    measure=measureList{i}
    
    % specify the effect interested in
    if strcmp(measure(1:4), 'CWAS')
        mask=['/home/data/Projects/Zhen/', project, '/mask/CWASMask_noGSR/stdMask_110sub_3mm_noGSR_100prct.nii.gz'];
    else
        mask=['/home/data/Projects/Zhen/', project, '/mask/meanStandFunMask_110sub_90pct.nii'];
    end
    
    if strcmp(effect, 'ME')
        if strcmp(measure(1:4), 'CWAS')
            T='T1'
        else
            T='T2'
        end
    else strcmp(effect, 'INT')
        T='T3'
    end
    % load the full brain mask
    
    [MaskData,VoxDimMask,HeaderMask]=rest_readfile(mask);
    % MaskData=rest_loadmask(nDim1, nDim2, nDim3, [maskDir,'stdMask_fullBrain_68sub_90percent.nii']);
    MaskData =logical(MaskData);%Revise the mask to ensure that it contain only 0 and 1
    MaskDataOneDim=reshape(MaskData,[],1)';
    MaskIndex = find(MaskDataOneDim);
    
    file=['/home/data/Projects/Zhen/', project, '/results/CPAC_zy1_24_14_reorganized/meanRegress_110sub/', measure, '/', measure, '_AllVolume_meanRegress.nii'];
    [AllVolume,VoxelSize,theImgFileList, Header] =rest_to4d(file);
    
    % reshape the data read in and mask out the regions outside of the brain
    [nDim1,nDim2,nDim3,nSub]=size(AllVolume);
    AllVolume=reshape(AllVolume,[],nSub)';
    AllVolume=AllVolume(:, MaskIndex);
    
    % exatract the ROI mean for neg clusters
    maskFileNeg=['/home/data/Projects/Zhen/BIRD/figs/CWAS_noGSR_MaskpreSmooth/cluster_mask/cluster_mask_', measure, '_', T, '_Z_neg.nii.gz']
    [OutdataNegROI,VoxDimNegROI,HeaderNegROI]=rest_readfile(maskFileNeg);
    [nDim1NegROI nDim2NegROI nDim3NegROI]=size(OutdataNegROI);
    NegROI1D=reshape(OutdataNegROI, [], 1)';
    NegROI1D=NegROI1D(1, MaskIndex);
    numNegClust=length(unique(NegROI1D(find(NegROI1D~=0))))
    numClusters(i, 1)=numNegClust;
    
    clustMeanNeg=zeros(numSub, numNegClust);
    clustNameNeg=[];
    for j=1:numNegClust
        ROI=AllVolume(:, find(NegROI1D==j));
        avg=mean(ROI, 2);
        clustMeanNeg(:, j)=avg;
        clustNameNeg{1, j}=[effect, '_', measure, '_neg_ROI', num2str(j)];
    end
    
    % extract the ROI mean for pos clusters
    maskFilePos=['/home/data/Projects/Zhen/BIRD/figs/CWAS_noGSR_MaskpreSmooth/cluster_mask/cluster_mask_', measure, '_', T, '_Z_pos.nii.gz']
    [OutdataPosROI,VoxDimPosROI,HeaderPosROI]=rest_readfile(maskFilePos);
    [nDim1PosROI nDim2PosROI nDim3PosROI]=size(OutdataPosROI);
    PosROI1D=reshape(OutdataPosROI, [], 1)';
    PosROI1D=PosROI1D(1, MaskIndex);
    numPosClust=length(unique(PosROI1D(find(PosROI1D~=0))))
    numClusters(i,2)=numPosClust;
    
    clustMeanPos=zeros(numSub, numPosClust);
    clustNamePos=[];
    for k=1:numPosClust
        ROI=AllVolume(:, find(PosROI1D==k));
        avg=mean(ROI, 2);
        clustMeanPos(:, k)=avg;
        clustNamePos{1, k}=[effect, '_', measure, '_pos_ROI', num2str(k)];
    end
    
    clustMean=[clustMeanNeg, clustMeanPos];
    clustMeanConcate=[clustMeanConcate, clustMean];
    clustName=[clustNameNeg, clustNamePos];
    clustNameConcate=[clustNameConcate, clustName];
end

totNumClusters=sum(numClusters(:,1))+sum(numClusters(:, 2))

% save the ROI mean and number of clusters
xlwrite([effect, '_ROImeanAllMeasures_total', num2str(totNumClusters), 'clusters.xls'], subID, 'sheet1','A1');
xlwrite([effect, '_ROImeanAllMeasures_total', num2str(totNumClusters), 'clusters.xls'], clustNameConcate, 'sheet1','B1');
xlwrite([effect, '_ROImeanAllMeasures_total', num2str(totNumClusters), 'clusters.xls'], clustMeanConcate, 'sheet1','B2');

rowTitle={'measure', 'negative', 'positive'};
xlwrite([ effect, '_numClustersEachMeasure.xls'],numClusters, 'sheet1', 'B2')
xlwrite([ effect, '_numClustersEachMeasure.xls'],measureList', 'sheet1', 'A2')
xlwrite([ effect, '_numClustersEachMeasure.xls'], rowTitle, 'sheet1', 'A1')



