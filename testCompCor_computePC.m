clear
clc
close all

rmpath /home/milham/matlab/REST_V1.7
rmpath /home/milham/matlab/REST_V1.7/Template
rmpath /home/milham/matlab/REST_V1.7/man
rmpath /home/milham/matlab/REST_V1.7/mask
rmpath /home/milham/matlab/REST_V1.7/rest_spm5_files

restoredefaultpath

% addpath(genpath('/home/data/HeadMotion_YCG/YAN_Program/spm8'))
% addpath /home/data/HeadMotion_YCG/YAN_Program/DPARSF_V2.3_130615
% addpath /home/data/HeadMotion_YCG/YAN_Program/DPARSF_V2.3_130615/Subfunctions/
% addpath /home/data/HeadMotion_YCG/YAN_Program/REST_V1.8_130615

addpath(genpath('/home/data/Projects/Zhen/commonCode/spm8'))
addpath /home/data/Projects/Zhen/commonCode/DPARSF_V2.3_130615
addpath /home/data/Projects/Zhen/commonCode/DPARSF_V2.3_130615/Subfunctions/
addpath /home/data/Projects/Zhen/commonCode/REST_V1.8_130615

%subList={'M10996445', 'M10911693', 'M10914047'};
subListFile='/home/data/Projects/Zhen/BIRD/data/final110sub.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n');
subList=cell2mat(subList{1});
numSub=length(subList)

PCNum=5;

%% compute PC signals for each subject
% IsNeedDetrend=1;  % previous analysis did not detrend
% Band=[0.01 0.1];
% TR=0.645;
% 
% for i=1:length(subList)
%  %i=108 
% %     %sub=char(subList(i))
%      sub=subList(i, 1:9);
%     ADataDir=['/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_', sub, '/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/func_to_2mm_flirt_applyxfm/REST_645_calc_resample_volreg_calc_maths_flirt.nii.gz'];
%     Nuisance_MaskFilename=['/home/data/Projects/Zhen/BIRD/testCompCor/erodedMask/', sub, '_csf_WM_eroded.nii'];
%     OutputName=['/home/data/Projects/Zhen/BIRD/testCompCor/DPARSF/', sub, '_', num2str(PCNum), 'componets'];
%     [PCs] = y_CompCor_PC_new(ADataDir,Nuisance_MaskFilename, OutputName, PCNum, IsNeedDetrend, Band, TR);
% end

%% compute the correlation between PCs computed from python and DPARSF

for i=1:length(subList)
% for i=108   
    sub=subList(i, 1:9)
    
    %sub = 'M10914047'
    a=load(['/home/data/Projects/Zhen/BIRD/testCompCor/newCode/comps_', sub, '.csv']);
    b=load(['/home/data/Projects/Zhen/BIRD/testCompCor/DPARSF/', sub, '_5componets.txt']);
    
    % just compute the correlation directly
%     for j=1:PCNum
%         correl(i,j)=corr(a(:,j), b(:,j));
%     end
%     
%     % use procrustes to transform the data
    r=zeros(PCNum, PCNum);
    for j=1:PCNum
        for k=1:PCNum
            [d z] = procrustes(a(:,j), b(:, k));
            r(j,k)=corr(a(:,j), z);
            match(i,j)=find(r(j, :)==max(r(j, :)));
            correlMatch(i,j)=r(j, match(1,j));
        end
    end
    
end

figure(1)
for j=1:PCNum
subplot(2,3,j)
hist(abs(correlMatch(:,j)))
ylim([0 50])
xlim([-0.2 1])
end
% 
% 
% 
% 
% 
% 
% 
% 

