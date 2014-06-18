clear
clc

rmpath /home/milham/matlab/REST_V1.7
rmpath /home/milham/matlab/REST_V1.7/Template
rmpath /home/milham/matlab/REST_V1.7/man
rmpath /home/milham/matlab/REST_V1.7/mask
rmpath /home/milham/matlab/REST_V1.7/rest_spm5_files

addpath /home/data/HeadMotion_YCG/YAN_Program/DPARSF_V2.3_130615
addpath /home/data/HeadMotion_YCG/YAN_Program/REST_V1.8_130615
addpath(genpath('/home/data/HeadMotion_YCG/YAN_Program/spm8'))
%addpath /home/data/Projects/Zhen/BIRD/code/DPARSF_V2.3_130615
%addpath /home/data/Projects/Zhen/BIRD/code/DPARSF_V2.3_130615/Subfunctions
%addpath /home/data/Projects/Zhen/BIRD/code/REST_V1.8_130615

dataDir='/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/noGSR/test/'
MaskData=[dataDir, 'stdMask_110sub_3mm_noGSR_100prct.nii'];
outputDir=dataDir;
ROIDef={[dataDir, 'cluster_mask_DT_group_name.nii']}


AllVolume=[dataDir, 'normFunImg_M10998101_3mm_fwhm6_masked.nii.gz'];

OutputName=[outputDir, 'FC_test'];
IsMultipleLabel=1;
[FCBrain, Header] = y_SCA(AllVolume, ROIDef, OutputName, MaskData, IsMultipleLabel);

