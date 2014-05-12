% This script perform the group analysis for full model
% check whether the standardized or non-standardized data were used

clear all;
clc
project='BIRD'
preprocessDate='1_24_14';
% Initiate the settings.
% 1. define Dir
% for numerical ID
%subList=load('/home/data/Projects/Colibazzi/data/subClean_step2_98sub.txt');
% for text ID
subListFile=['/home/data/Projects/', project, '/data/final110sub.txt'];
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
subList=cell2mat(subList{1})

numSub=length(subList)

%measureList={'CWASME_ROI1', 'CWASME_ROI2', 'CWASME_ROI3', 'CWASME_ROI4' };
measureList={'CWASINT_ROI1', 'CWASINT_ROI2', 'CWASINT_ROI3', 'CWASINT_ROI4'}
numMeasure=length(measureList)

mask=['/home/data/Projects/', project, '/mask/stdMask_110sub_compCor_100prct.nii'];

GroupAnalysis=['/home/data/Projects/', project, '/results/CPAC_zy', preprocessDate, '_reorganized/groupAnalysis_110sub/'];

% 2. set path
addpath /home/data/HeadMotion_YCG/YAN_Program/mdmp
addpath /home/data/HeadMotion_YCG/YAN_Program
addpath /home/data/HeadMotion_YCG/YAN_Program/TRT
addpath /home/data/HeadMotion_YCG/YAN_Program/DPARSF_V2.2_130309
addpath /home/data/HeadMotion_YCG/YAN_Program/spm8
[ProgramPath, fileN, extn] = fileparts(which('DPARSFA_run.m'));
Error=[];
addpath([ProgramPath,filesep,'Subfunctions']);
[SPMversion,c]=spm('Ver');
SPMversion=str2double(SPMversion(end));

% 3. Model Creation
[NUM,TXT,RAW]=xlsread(['/home/data/Projects/', project, '/data/regressionModel_110sub.xlsx']);

for j=1:numMeasure
    measure=char(measureList{j})
    
    % Model creation
    if strcmp(measure(1:7), 'CWASME_')
        labels=[TXT(1,3), TXT(1,5)];
        labels{1, 3}='constant';
        cov=[NUM(:,2), NUM(:,4)];
        model=[cov ones(numSub, 1)];
        disp(labels)
    elseif strcmp(measure(1:7), 'CWASINT')
        labels=TXT(1,2:5)
        labels{1, 5}='constant';
        cov=NUM(:,1:4);
        model=[cov ones(numSub, 1)];
        disp(labels)
    end
    
    % 5. group analysis
    
    FileName = {['/home/data/Projects/BIRD/results/CPAC_zy', preprocessDate, '_reorganized/meanRegress_110sub/', measure, '/', measure, '_AllVolume_meanRegress.nii']};
    % perform group analysis
    mkdir([GroupAnalysis,measure]);
    outDir=[GroupAnalysis,measure];
    
    OutputName=[outDir,filesep, measure]
    y_GroupAnalysis_Image(FileName,model,OutputName,mask);
    
    % 6. convert t to Z
    if strcmp(measure(1:7), 'CWASME_')
        effectList={'T1'};
    elseif strcmp(measure(1:7), 'CWASINT')
        effectList={'T1', 'T2', 'T3'};
    end
    
    Df1=numSub-size(model,2) % N-k-1: N:number of subjects; k=num of covariates (constant excluded)
    
    for k=1:length(effectList)
        effect=char(effectList{k})
        
        ImgFile=[outDir, filesep, measure, '_', effect, '.nii'];
        OutputName=[outDir, filesep,  measure, '_', effect, '_Z.nii'];
        Flag='T';
        [Z P] = y_TFRtoZ(ImgFile,OutputName,Flag,Df1);
    end
    
end
