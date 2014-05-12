% This script is for compte the overlap across dif strategeis for CWAS results

clear
clc
close all

% define path and variables
fileDir='/home/data/Projects/BIRD/figs/easythresh_110sub/';
figDir='/home/data/Projects/BIRD/figs/paper_figs/';
effect='INT'

% for main effect
%strategyList={'thresh_DegreeCentrality_T2_Z_cmb', 'thresh_DualRegression0_T2_Z_cmb', 'thresh_DualRegression1_T2_Z_cmb', 'thresh_DualRegression3_T2_Z_cmb', 'thresh_DualRegression6_T2_Z_cmb', 'thresh_DualRegression7_T2_Z_cmb', 'thresh_DualRegression8_T2_Z_cmb', 'thresh_CWAS_T2'}

% for interaction effect
strategyList={'thresh_VMHC_T3_Z_cmb', 'thresh_DualRegression2_T3_Z_cmb', 'thresh_DualRegression7_T3_Z_cmb','thresh_fALFF_T3_Z_cmb', 'thresh_CWAS_T3'}
% read in the mask file and reshape to 1D
maskFile=['/home/data/Projects/BIRD/mask/meanStandFunMask_110sub_90pct.nii.gz']
[OutdataMask,VoxDimMask,HeaderMask]=rest_readfile(maskFile);
[nDim1Mask nDim2Mask nDim3Mask]=size(OutdataMask);
maskImg1D=reshape(OutdataMask, [], 1);
maskIndx=find(maskImg1D);

% read in the effect file and binarize into a mask
for i=1:length(strategyList)
    strategy=num2str(strategyList{i});
    fileName=[fileDir, strategy, '.nii']  
    
    [Outdata,VoxDim,Header]=rest_readfile(fileName);
    [nDim1 nDim2 nDim3]=size(Outdata);
    img1D=reshape(Outdata, [], 1);
    img1D=img1D(maskIndx);
    img1D=logical(img1D);
    imgAllStrategies(:, i)=img1D;
end

% find the voxels commonly significant for all strategies
imgAllStrategies=imgAllStrategies';

commonSigVox=sum(imgAllStrategies)';
CWASSigVox=commonSigVox.*imgAllStrategies(end,:)';
numVoxCommon=length(find(commonSigVox));
numVoxCWAS=length(find(CWASSigVox));

% % compute the percentage of significant voxels
% prctCommon=zeros(length(strategyList),1);
% prctCWAS=zeros(length(strategyList),1);
% for i=1:length(strategyList)
%     prctCommon(i,1)=length(find(commonSigVox==i))/numVoxCommon;
%     prctCWAS(i,1)=length(find(CWASSigVox==i))/numVoxCWAS;
% end
% colorMap=[64, 224, 208; 106, 90, 205; 30, 144, 255; 255, 255, 0; 220, 20, 60];
% colorMap=colorMap/255;
% % pie plot the percentage
% labels={'1', '2', '3', '4'}
% figure(1)
% h=pie(prctCommon, labels)
% hp = findobj(h, 'Type', 'patch');
% for k=1:length(hp)
% set(hp(k), 'FaceColor', colorMap(k,:));
% end
% saveas(figure(1),[figDir, 'prctSigCommon_', effect, '.png'])

% figure(2)
% 
% h=pie(prctCWAS, labels)
% hp = findobj(h, 'Type', 'patch');
% for k=1:length(hp)
% set(hp(k), 'FaceColor', colorMap(k,:));
% end

saveas(figure(2),[figDir, 'prctSigCWAS_', effect, '.png'])

% write common regions to img
final=zeros(size(maskImg1D));
final(maskIndx, 1)=commonSigVox;
final=reshape(final,nDim1Mask, nDim2Mask, nDim3Mask);

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

outName=[figDir, 'sigVoxCommon_', effect, '.nii'];
rest_Write4DNIfTI(final,Header,outName)

% write compCor unique regions to img
compCor=zeros(size(maskImg1D));
compCor(maskIndx, 1)=CWASSigVox;
compCor=reshape(compCor,nDim1Mask, nDim2Mask, nDim3Mask);

Header.pinfo = [1;0;0];
Header.dt    =[16,0];

outName=[figDir, 'sigVoxCCWAS_', effect, '.nii'];
rest_Write4DNIfTI(compCor,Header,outName)





