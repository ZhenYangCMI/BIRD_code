
clear
clc

sub='M10905922'
data=['/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_', sub, '/func_preproc_0/_scan_rest_rest_645/func_normalize/REST_645_calc_resample_volreg_calc_maths.nii.gz'];
dataOutDir='/home/data/Projects/Zhen/BIRD/testCompCor/cmpResidual/';
cov1=load(['/home/data/Projects/Zhen/BIRD/testCompCor/newCode/compsOnlyDemean_', sub, '.csv']);
cov2=load(['/home/data/Projects/Zhen/BIRD/testCompCor/newCode/comps_', sub, '.csv']);
cov1Demean=cov1-repmat(mean(cov1), size(cov1, 1), 1);
cov2Demean=cov2-repmat(mean(cov2), size(cov2, 1), 1);

[AllVolume,VoxelSize,theImgFileList, Header] = y_ReadAll(data);
[nDim1 nDim2 nDim3 nDimTimePoints]=size(AllVolume);
BrainSize = [nDim1 nDim2 nDim3];
AllVolume=reshape(AllVolume,[],nDimTimePoints)';

correl=[];
for i=1:size(AllVolume, 2)
    
    [b1,bint1,r1] = regress(AllVolume(:,i),cov1Demean);
    [b2,bint2,r2] = regress(AllVolume(:,i),cov2Demean);
    correl(1,i)=corr(r1,r2);
end

correl(isnan(correl))=0;
correl=correl';
% write into a 3D image
AllVolumeBrain = (zeros(nDim1*nDim2*nDim3, 1));
AllVolumeBrain = correl;

AllVolumeBrain=reshape(AllVolumeBrain,[nDim1, nDim2, nDim3, 1]);

Header_Out = Header;

Header_Out.pinfo = [1;0;0];

Header_Out.dt    =[16,0];

%write 4D file as a nift file
outName=[dataOutDir, sub, '_correlBetweenResidual.nii'];
rest_Write4DNIfTI(AllVolumeBrain,Header_Out,outName)
