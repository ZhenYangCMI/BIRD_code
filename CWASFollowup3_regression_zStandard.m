% This script perform the group analysis for full model
clear
clc

effect='DT_group_name' % can be 'age_demeanByDT_group', 'DT_group_name', the fullBrain FC will be calculated using the ROI mask detected for this effect

numROI=3

dataDir=['/home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/FunImg_3mm_fwhm6/'];
figDir=['/home2/data/Projects/BIRD/figs/CWAS/'];

maskFile=['/home/data/Projects/BIRD/mask/stdMask_115sub_compCor_100prct.nii']
GroupAnalysisOutDir=['/home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/CWAS/followUp/regressionResults/', effect, '/'];

subListFile='/home/data/Projects/BIRD/data/final115sub.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
subList=cell2mat(subList{1})
numSub=length(subList)

% 2. set path
%addpath /home/data/HeadMotion_YCG/YAN_Program/mdmp
addpath /home/data/HeadMotion_YCG/YAN_Program
addpath /home/data/HeadMotion_YCG/YAN_Program/TRT
addpath /home/data/HeadMotion_YCG/YAN_Program/DPARSF_V2.3_130615
addpath /home/data/HeadMotion_YCG/YAN_Program/spm8
[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
Error=[];
addpath([ProgramPath,filesep,'Subfunctions']);
[SPMversion,c]=spm('Ver');
SPMversion=str2double(SPMversion(end));

% 3. group analysis
NP=load(['/home/data/Projects/BIRD/data/regressionModel.txt']);

for k=1:numROI
    ROI=num2str(k)
    
    % define FileNameSet
    FileNameSet=[];
    for i=1:length(subList)
        sub=subList(i, 1:9);
        
        FileName=sprintf('/home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/CWAS/followUp/%s/zROI%sFC_ROI_%s_%s.nii', effect, ROI, effect, sub)
        
        FileNameSet{i,1}=FileName;
    end
    
    % define AllCov
    
    
    if strcmp(effect, 'age_demeanByDT_group')
        labels={'age_demean', 'DT_group', 'age_demeanByDT_group', 'meanFD', 'constant'}
        model=[NP(:, 1) NP(:, 2) NP(:, 3) NP(:, 4) ones(numSub, 1)];
    elseif strcmp(effect, 'DT_group_name')
        labels={'DT_group', 'meanFD', 'constant'}
        model=[NP(:, 2) NP(:, 4) ones(numSub, 1)];
    end
    
    AllCov = model;
    
    OutputName=[GroupAnalysisOutDir,effect, 'ROI', ROI ]
    
    y_GroupAnalysis_Image(FileNameSet,AllCov,OutputName,maskFile);
    
    % convert t to Z
    if strcmp(effect, 'age_demeanByDT_group')
        TscoreList={'T1', 'T2', 'T3'};
        Df1=109; % N-k-1=115-5-1=109
    elseif strcmp(effect, 'DT_group_name')
        TscoreList={'T1'};
        Df1=111; % N-k-1=115-3-1=111
    end
    
    for k=1:length(TscoreList)
        Tscore=char(TscoreList{k})
        
        ImgFile=[GroupAnalysisOutDir,effect, 'ROI', ROI, '_', Tscore, '.nii'];
        OutputName=[GroupAnalysisOutDir,effect, 'ROI', ROI, '_', Tscore, '_Z.nii'];
        Flag='T';
        [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1);
    end
    
    
end

