% PCA analysis
clear
clc

project='BIRD'
% Global variable

subListFile='/home/data/Projects/BIRD/data/final110sub.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n');
subList=cell2mat(subList{1});
numSub=length(subList);

maskDir=['/home/data/Projects/BIRD/mask/'];
standardBrainMask=[maskDir,'BrainMask_05_61x73x61.img'];
ROImask=[maskDir,'AAL_61x73x61_YCG_reduced_threshold70.nii'];

numVol=890;
winSize=69;
step=3;
numWinPerSub=floor((numVol-winSize)/step)+1;
numSub=length(subList);
numWinAllSub=numWinPerSub*numSub;

norm='norm2';

%% 0. mask creation AAL mask with ROI 1 to 88

mask=[maskDir, '/AAL_61x73x61_YCG.nii']
funMask=[maskDir, 'meanStandFunMask_110sub_90pct_3mm.nii']
[MaskData,MaskVox,MaskHead]=rest_readfile(mask);
[MaskData1,MaskVox1,MaskHead1]=rest_readfile(funMask);
numROI=length(unique(MaskData))-1;
numVoxPerROI=zeros(numROI, 1);
numOverlapVoxPerROI=zeros(numROI, 1);
pctOverlapVoxPerROI=zeros(numROI, 1);
overlapMask=MaskData.*MaskData1;

for i=1:numROI
    numVoxPerROI(i,1)=length(find(MaskData==i));
    numOverlapVoxPerROI(i,1)=length(find(overlapMask==i));
    if numVoxPerROI(i,1)~=0 || numOverlapVoxPerROI(i,1)~=0
        pctOverlapVoxPerROI(i,1)=numOverlapVoxPerROI(i,1)/numVoxPerROI(i,1);
    else
        pctOverlapVoxPerROI(i,1)=0;
    end
    
    if pctOverlapVoxPerROI(i,1)>=0.7
        MaskData(find(MaskData==i))=i;
    else
        MaskData(find(MaskData==i))=0;
    end
    
end
 reducedMask=MaskData;

 fileName=[maskDir, 'AAL_61x73x61_YCG_reduced_threshold70.nii'];
 rest_WriteNiftiImage(reducedMask,MaskHead,fileName);


%% 1. Extract the TS from ROIs

 ROIoutputDir=['/home/data/Projects/', project, '/results/PCA/'];
% dataDir=['/home/data/Projects/', project, '/results/CPAC_zy1_24_14_reorganized/noGSR/FunImg_3mm/'];
% [ counter ] = extractTC(subList, ROIoutputDir, dataDir, standardBrainMask, ROImask);
% disp ('ROI time series extraction done!')

%% 2. FC window creation, extract the feature from the lowertriangle

resultDir=['/home/data/Projects/', project, '/results/PCA/'];
figDir = ['/home/data/Projects/', project, '/figs/PCA/'];

% FC window creation
disp('Create FC windows')
[ fullCorrWin zFullCorrWin ] = FCwinCreation( subList, ROIoutputDir, winSize, numWinPerSub, step);
save([resultDir, 'fullCorrWin.mat'], 'fullCorrWin')
save([resultDir, 'zFullCorrWin.mat'], 'zFullCorrWin')

% extract the lower triangle and z standardize each window
disp('Extract lower triangle feature')
[featureWin, zFeatureWin] = featureExtract(zFullCorrWin);
save([resultDir, 'feature.mat'], 'featureWin')
save([resultDir, 'zNormWinFeature.mat'], 'zFeatureWin')

% standardize each subject's data by the global variable and row-wise demean (norm2) or not row-wise demean (norm1)
disp('Standardize the dyanmic FC matric')
[ norm1FeatureWin norm2FeatureWin ] = standardizeFeature( subList, featureWin, numWinPerSub );
save([resultDir,'/norm1FeatureWin.mat'],'norm1FeatureWin')
save([resultDir,'/norm2FeatureWin.mat'],'norm2FeatureWin')

%% 3 run PCA
disp ('Run PCA')
normFeature=eval([norm, 'FeatureWin']);
[COEFF,SCORE,latent, tsquare] = princomp(normFeature);
cumVar=cumsum(latent)./sum(latent);
save([resultDir,'/eigenvector_',norm, '.mat'],'COEFF')
save([resultDir,'/eigenvalue_',norm, '.mat'],'latent')
save([resultDir,'/cumVar_', norm, '.mat'],'cumVar')
save([resultDir,'/tsquare_', norm, '.mat'],'tsquare')

x=1:length(latent);
numEigenValue=[length(latent), 100, 20];
close all
figure(1)
for m=1:length(numEigenValue)
    num=numEigenValue(m);
    subplot(3,1,m)
    [AX, H1, H2]=plotyy(x(1:num),latent(1:num), x(1:num), cumVar(1:num));
    set(get(AX(1),'Ylabel'),'String','Eigen Value')
    set(get(AX(2),'Ylabel'),'String','Cummulative Variance')
    xlabel('Number of Eigen Values')
    title([num2str(num),  'Eigen Values'])
    set(H1,'LineStyle','-', 'LineWidth', 2)
    set(H2,'LineStyle','-', 'LineWidth', 2)
end
saveas(figure(1), [figDir, 'eigenValue_', norm, '.jpg'])


