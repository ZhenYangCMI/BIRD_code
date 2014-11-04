clear
clc


dataDir=['/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/compCor/FunImg/'];
subListFile='/home/data/Projects/Zhen/BIRD/generalizeClassifier/data/65AdultsWithBIRDAndImg_final.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n');
subList=cell2mat(subList{1});
numSub=size(subList, 1)

effect='DT_group_name' % can be "DT_group_name" or "age_demeanByDT_group"
MaskData='/home/data/Projects/Zhen/BIRD/mask/stdMask_110sub_compCor_100prct_final.nii.gz'
mkdir (['/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/compCor/', effect, '_followUp'])
outputDir= ['/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/compCor/', effect, '_followUp'];
 ROIDef={['/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/CWAS_110sub_maskPostSmooth/mdmr3mmFWHM6/cluster_mask_', effect, '.nii']}
 

% 1. compute the iFC for each ROI
% for i=1:numSub
%     sub=subList(i, 1:9)
%     AllVolume=[dataDir, 'normFunImg_', sub, '_3mm_fwhm6_masked.nii.gz'];
%        
%     OutputName=[outputDir, 'FC_', effect, '_', sub];
%     IsMultipleLabel=1;
%     [FCBrain, Header] = y_SCA(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel);
% end

% 2. mean regression the iFC map

[OutdataROI,VoxDimROI,HeaderROI]=rest_readfile(char(ROIDef));
[nDim1ROI nDim2ROI nDim3ROI]=size(OutdataROI);
ROI1D=reshape(OutdataROI, [], 1)';
%ROI1D=ROI1D(1, MaskIndex);
numClust=length(unique(ROI1D(find(ROI1D~=0))))
BrainMaskFile=MaskData;
for k=1:numClust

mkdir  (['/home/data/Projects/Zhen/BIRD/generalizeClassifier/meanRegress/CWASME_ROI', num2str(k)])
        dataOutDir=['/home/data/Projects/Zhen/BIRD/generalizeClassifier/meanRegress/CWASME_ROI', num2str(k), '/'];

FileNameSet=[];
    
    for i=1:numSub
        sub=subList(i, 1:9);
        
        disp(['Working on ', sub])
        
        FileName = sprintf('/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/compCor/%s_followUp/ROI%s%s_followUpFC_%s_%s.nii',  effect, num2str(k), effect, effect, sub);
               
        if ~exist(FileName,'file')
            
            disp(sub)
            
        else
            
            FileNameSet{i,1}=FileName;
            
        end
        
    end
    
    FileNameSet;
    
    [AllVolume,vsize,theImgFileList, Header,nVolumn] =rest_to4d(FileNameSet);
    
    
    
    [nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
    
    
    
    
    
    %Set Mask
    
    if ~isempty(BrainMaskFile)
        
        [MaskData,MaskVox,MaskHead]=rest_readfile(BrainMaskFile);
        
    else
        
        MaskData=ones(nDim1,nDim2,nDim3);
        
    end
    
    
    % Convert into 2D. NOTE: here the first dimension is voxels,
    
    % and the second dimension is subjects. This is different from
    
    % the way used in y_bandpass.
    
    %AllVolume=reshape(AllVolume,[],nDimTimePoints)';
    
    AllVolume=reshape(AllVolume,[],nDimTimePoints);
    
    
    MaskDataOneDim=reshape(MaskData,[],1);
    
    MaskIndex = find(MaskDataOneDim);
    
    nVoxels = length(MaskIndex);
    
    %AllVolume=AllVolume(:,MaskIndex);
    
    AllVolume=AllVolume(MaskIndex,:);
    
    
    
    AllVolumeBAK = AllVolume;
    
    
    % compute the mean and st acorss all voxels for each sub
    Mean_AllSub = mean(AllVolume)';
    
    Std_AllSub = std(AllVolume)';
    
    %Prctile_25_75 = prctile(AllVolume,[25 50 75]);
    
    
    %Median_AllSub = Prctile_25_75(2,:)';
    
    %IQR_AllSub = (Prctile_25_75(3,:) - Prctile_25_75(1,:))';
    
    
    Mat = [];
    
    Mat.Mean_AllSub = Mean_AllSub;
    
    Mat.Std_AllSub = Std_AllSub;
    
    if strcmp(effect, 'DT_group_name')
        OutputName=[dataOutDir, 'CWASME_ROI', num2str(k)];
    else
        OutputName=[dataOutDir, 'CWASINT_ROI', num2str(k)];
    end
    save([OutputName,'_MeanSTD.mat'],'Mean_AllSub','Std_AllSub');
    
    
    Cov = Mat.Mean_AllSub;
    
    
    %Mean centering
    
    Cov = (Cov - mean(Cov))/std(Cov);
    
    
    AllVolumeMean = mean(AllVolume,2);
    
    AllVolume = (AllVolume-repmat(AllVolumeMean,1,size(AllVolume,2)));
    
    
    %AllVolume = (eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')*AllVolume; %If the time series are columns
    
    AllVolume = AllVolume*(eye(size(Cov,1)) - Cov*inv(Cov'*Cov)*Cov')';  %If the time series are rows
    
    %AllVolume = AllVolume + repmat(AllVolumeMean,1,size(AllVolume,2));
    
    
    AllVolumeSign = sign(AllVolume);
    
    
    % write the data as a 4D volume
    AllVolumeBrain = (zeros(nDim1*nDim2*nDim3, nDimTimePoints));
    
    AllVolumeBrain(MaskIndex,:) = AllVolume;
    
    
    
    AllVolumeBrain=reshape(AllVolumeBrain,[nDim1, nDim2, nDim3, nDimTimePoints]);
    
    Header_Out = Header;
    
    Header_Out.pinfo = [1;0;0];
    
    Header_Out.dt    =[16,0];
    
    %write 4D file as a nift file
    if strcmp(effect, 'DT_group_name')
        outName=[dataOutDir, 'CWASME_ROI', num2str(k), '_AllVolume_meanRegress.nii'];
    else
        outName=[dataOutDir, 'CWASINT_ROI', num2str(k), '_AllVolume_meanRegress.nii'];
    end
    
    rest_Write4DNIfTI(AllVolumeBrain,Header_Out,outName)
    
end
