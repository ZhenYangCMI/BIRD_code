function [ tag ] = extractTC(subList, ROIoutputDir, dataDir, standardBrainMask, ROImask)
%This function standardize the volume and extract the TS of ROIs of a given
%mask

tag=0;
for i=1:length(subList)
    sub=subList(i, 1:9)
    tag=tag+1;
    if ~exist([ROIoutputDir, sub], 'dir')
        mkdir(ROIoutputDir,sub)
    end
    subDir=[ROIoutputDir,sub];
    
    data=[dataDir, 'normFunImg_', sub, '_3mm.nii'];
    
    [AllVolume, VoxelSize, ImgFileList, Header1, nVolumn] =rest_to4d(data);
    [nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
    brainSize = [nDim1 nDim2 nDim3];
    
    % remove the regions outside of the brain and convert data into 2D
    MaskData=rest_loadmask(nDim1, nDim2, nDim3, standardBrainMask);
    MaskData =logical(MaskData);%Revise the mask to ensure that it contain only 0 and 1
    AllVolume=reshape(AllVolume,[],nDimTimePoints)';
    MaskDataOneDim=reshape(MaskData,1,[]);
    MaskIndex = find(MaskDataOneDim);
    AllVolume=AllVolume(11:end,MaskIndex);
    
    
    % Z_norm the time series for each voxel
    AllVolume = (AllVolume-repmat(mean(AllVolume),size(AllVolume,1),1))./repmat(std(AllVolume),size(AllVolume,1),1);
    AllVolume(isnan(AllVolume))=0;
    
    
    % Convert 2D file back into 4D
    nTimePointsFinal=nDimTimePoints-10;
    AllVolumeBrain = single(zeros(nTimePointsFinal, nDim1*nDim2*nDim3));
    AllVolumeBrain(:,MaskIndex) = AllVolume;
    AllVolumeBrain=reshape(AllVolumeBrain',[nDim1, nDim2, nDim3, nTimePointsFinal]);
    
    
    % write 4D file as a nift file
    NormAllVolumeBrain=[subDir,'/','zFunImg.nii'];
    rest_Write4DNIfTI(AllVolumeBrain,Header1,NormAllVolumeBrain)
    
    disp ('Time series of each voxel was Z-score normalized.')
    
    
    % extract time series for seeds and ROIs
    
    y_ExtractROISignal(NormAllVolumeBrain, ...
        {ROImask},[subDir,'/', sub],MaskData,1);
end

end

