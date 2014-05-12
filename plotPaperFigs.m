
clear
clc
close all

%%1.  recode the CWAS negative clusters
% maskDir='/home/data/Projects/Zhen/BIRD/figs/paper_figs/tmp/';
% numROI=4;
% for i=1:numROI
%     maskFile=[maskDir, 'cluster_mask_CWASINT_ROI', num2str(i), '_T3_Z_neg.nii.gz'];
%     %read in the mask and reshape to 1D
%     [OutdataMask,VoxDimMask,HeaderMask]=rest_readfile(maskFile);
%     [nDim1Mask nDim2Mask nDim3Mask]=size(OutdataMask);
%     maskImg1D=reshape(OutdataMask, [], 1);
%     numClust=length(unique(maskImg1D(find(maskImg1D~=0))))
%
%
%     % recode the cluster number so each cluster will be indicated by a
%     % distinctive color: cluster1 = -1; cluster2 = -2; cluster3 =-3;
%     % cluster4 = -4 et al;
%     for j=1:numClust
%         maskImg1D(find(maskImg1D==j))=j*(-1);
%     end
%
%     maskImgRecode=reshape(maskImg1D, [nDim1Mask nDim2Mask nDim3Mask]);
%
%     Header.pinfo = [1;0;0];
%     Header.dt    =[16,0];
%     rest_WriteNiftiImage(maskImgRecode,HeaderMask,[maskDir,'cluster_mask_CWASINT_ROI', num2str(i), '_T3_Z_neg_recoded.nii']);
% end

% %%2. plot the overlaps for univariate approaches: ME
%
% % for negative clusters
%
% fileDir='/home/data/Projects/Zhen/BIRD/mask/ROImasksME/'
% direction='neg'
%
% if strcmp(direction, 'neg')
%     % fileList={'cluster_mask_DegreeCentrality_T2_Z_neg', 'cluster_mask_DualRegression0_T2_Z_neg', 'cluster_mask_DualRegression6_T2_Z_neg'};

% elseif strcmp(direction, 'pos')
%     %fileList={'cluster_mask_DegreeCentrality_T2_Z_pos', 'cluster_mask_DualRegression1_T2_Z_pos', 'cluster_mask_DualRegression3_T2_Z_pos', 'cluster_mask_DualRegression6_T2_Z_pos', ...
%         'cluster_mask_DualRegression7_T2_Z_pos', 'cluster_mask_DualRegression8_T2_Z_pos'};

% end
% numFile=length(fileList)
%
% tmp=[];
% for j=1:numFile
%     file=[fileDir, char(fileList{j}), '.nii.gz']
%     [Outdata,VoxDim,Header]=rest_readfile(file);
%     [nDim1 nDim2 nDim3]=size(Outdata);
%     img1D=reshape(Outdata, [], 1);
%     img1D(find(img1D~=0))=j;
%     tmp(:, j)=img1D;
% end
% overlap=sum(tmp, 2);
%
% if strcmp(direction, 'neg')
%     overlap(find(overlap==1))=-3;
%       overlap(find(overlap==2))=-2;
%     overlap(find(overlap==3))=-1;
%
% elseif strcmp(direction, 'pos')
%     overlap(find(overlap==1))=-3;
%     overlap(find(overlap==2))=-2;
%     overlap(find(overlap==3))=-1;
%     overlap(find(overlap==4))=1;
%     overlap(find(overlap==5))=2;
%     overlap(find(overlap==6))=3;
% end
%
%
% imgRecode=reshape(overlap, [nDim1 nDim2 nDim3]);
%
% Header.pinfo = [1;0;0];
% Header.dt    =[16,0];
% rest_WriteNiftiImage(imgRecode,Header,[fileDir,'univariate_', direction, '.nii']);

%%3. plot the overlaps for univariate approaches: INT

% for negative clusters

% fileDir='/home/data/Projects/Zhen/BIRD/mask/ROImasksINT/'
% direction='pos'
% 
% if strcmp(direction, 'neg')
%     
%     fileList={'cluster_mask_DualRegression2_T3_Z_neg', 'cluster_mask_DualRegression7_T3_Z_neg', 'cluster_mask_VMHC_T3_Z_neg'}
% elseif strcmp(direction, 'pos')
%     
%     fileList={'cluster_mask_DualRegression7_T3_Z_pos', 'cluster_mask_fALFF_T3_Z_pos'}
% end
% numFile=length(fileList)
% 
% tmp=[];
% for j=1:numFile
%     file=[fileDir, char(fileList{j}), '.nii.gz']
%     [Outdata,VoxDim,Header]=rest_readfile(file);
%     [nDim1 nDim2 nDim3]=size(Outdata);
%     img1D=reshape(Outdata, [], 1);
%     img1D(find(img1D~=0))=j;
%     tmp(:, j)=img1D;
% end
% overlap=sum(tmp, 2);
% 
% if strcmp(direction, 'neg')
%     overlap(find(overlap==1))=-2;
%     overlap(find(overlap==2))=-1;
%     overlap(find(overlap==3))=1;
%     
% elseif strcmp(direction, 'pos')
%     overlap(find(overlap==1))=-1;
%     overlap(find(overlap==2))=2;
% end
% 
% 
% imgRecode=reshape(overlap, [nDim1 nDim2 nDim3]);
% 
% Header.pinfo = [1;0;0];
% Header.dt    =[16,0];
% rest_WriteNiftiImage(imgRecode,Header,[fileDir,'univariate_INT_', direction, '.nii']);





% %% 4. plot the clusters in specified colorMap for CWAS
% % define path and variables
% maskDir='/home/data/Projects/Zhen/BIRD/figs/CWAS_110sub/';
% maskFile=[maskDir, 'cluster_mask_age_demeanByDT_group.nii.gz'];
% atlasDir='/home/data/Projects/Zhen/workingMemory/mask/atlas/';
%
% % read in the MNI stand mask
% standardMask=[atlasDir, 'MNI152_T1_3mm_brain_mask.nii.gz'];
% [OutdataStand,VoxDimStand,HeaderStand]=rest_readfile(standardMask);
% dataStand1D=reshape(OutdataStand,[],1);
% standIndex = find(dataStand1D);
%
% % read in the mask and reshape to 1D
% [OutdataMask,VoxDimMask,HeaderMask]=rest_readfile(maskFile);
% [nDim1Mask nDim2Mask nDim3Mask]=size(OutdataMask);
% maskImg1D=reshape(OutdataMask, [], 1);
% %maskImg1D=maskImg1D(standIndex, 1);
% numClust=length(unique(maskImg1D(find(maskImg1D~=0))))
%
%
% % recode the cluster number so each cluster will be indicated by a
% % distinctive color: cluster1 = -2; cluster2 = -1; cluster3 = 1;
% % cluster4 = 2;
% maskImg1D(find(maskImg1D==1))=-2;
% maskImg1D(find(maskImg1D==2))=-1;
% maskImg1D(find(maskImg1D==3))=1;
% maskImg1D(find(maskImg1D==4))=2;
%
% maskImgRecode=reshape(maskImg1D, [nDim1Mask nDim2Mask nDim3Mask]);
%
% Header.pinfo = [1;0;0];
% Header.dt    =[16,0];
% rest_WriteNiftiImage(maskImgRecode,HeaderMask,[maskDir,'cluster_mask_age_demeanByDT_group_recoded.nii']);
