clear
clc


project='BIRD';
covType='noGSR' % covType can be noGSR or compCor
effect='age_demeanByDT_group';  % 'DT_group_name', or 'age_demeanByDT_group'

BrainMaskFile=['/home/data/Projects/Zhen/BIRD/mask/CWASMask_noGSR/stdMask_110sub_3mm_noGSR_100prct.nii.gz'];

subListFile='/home/data/Projects/Zhen/BIRD/data/final110sub.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
subList=cell2mat(subList{1})
numSub=size(subList, 1)

% load the cluster mask
ROIDef=['/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/noGSR/CWAS_110sub/mdmr3mmFWHM6/cluster_mask_', effect, '.nii']
[OutdataROI,VoxDimROI,HeaderROI]=rest_readfile(ROIDef);
[nDim1ROI nDim2ROI nDim3ROI]=size(OutdataROI);
ROI1D=reshape(OutdataROI, [], 1)';
%ROI1D=ROI1D(1, MaskIndex);
numClust=length(unique(ROI1D(find(ROI1D~=0))))


for k=1:numClust
    
    if strcmp(effect, 'DT_group_name')
        mkdir  (['/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/meanRegress_110sub/CWASME_ROI', num2str(k)])
        dataOutDir=['/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/meanRegress_110sub/CWASME_ROI', num2str(k), '/'];
    elseif strcmp(effect, 'age_demeanByDT_group')
        mkdir  (['/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/meanRegress_110sub/CWASINT_ROI', num2str(k)])
        dataOutDir=['/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/meanRegress_110sub/CWASINT_ROI', num2str(k), '/'];
    end
    %Test if all the subjects exist
    
    FileNameSet=[];
    
    for i=1:numSub
        sub=subList(i, 1:9);
        
        disp(['Working on ', sub])
        
        FileName = sprintf('/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/%s/CWAS_110sub/%s_followUp/ROI%sFC_%s_%s.nii',  covType, effect, num2str(k), effect, sub);
        
        
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
