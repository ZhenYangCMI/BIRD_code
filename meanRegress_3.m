clear
clc

preprocessDate='1_24_14';

covType='noGSR' % covType can be noGSR or compCor

subListFile='/home/data/Projects/BIRD/data/final110sub.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
SubID=cell2mat(subList{1});


%measureList={'ReHo','fALFF', 'VMHC', 'DegreeCentrality', 'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4', 'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9' };
measureList={'DegreeCentrality'}
numMeasure=length(measureList)

BrainMaskFile=['/home/data/Projects/BIRD/mask/meanStandFunMask_110sub_90pct.nii.gz'];

for j=1:numMeasure
    measure=char(measureList{j})
    
    
    mkdir (['/home/data/Projects/BIRD/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_110sub/', measure])
    dataOutDir=['/home/data/Projects/BIRD/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_110sub/', measure, '/'];
    %Test if all the subjects exist
    
    FileNameSet=[];
    
    for i=1:length(SubID)
        
        sub=SubID(i, 1:9);
        disp(['Working on ', sub])
        if strcmp(measure, 'VMHC')
            FileName = sprintf('/home/data/Projects/BIRD/results/CPAC_zy%s_reorganized/%s/%s/Snorm%s_%s.nii.gz', preprocessDate, covType, measure,measure,sub);
        else
            FileName = sprintf('/home/data/Projects/BIRD/results/CPAC_zy%s_reorganized/%s/%s/%s_%s_MNI_fwhm6.nii', preprocessDate, covType, measure,measure,sub);
        end
        
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
    
    OutputName=[dataOutDir, measure];
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
    outName=[dataOutDir, measure, '_AllVolume_meanRegress.nii'];
    rest_Write4DNIfTI(AllVolumeBrain,Header_Out,outName)
    
end
