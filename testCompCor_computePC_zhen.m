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
%     sub=subList(i, 1:9)
%     data=load(['/home/data/Projects/Zhen/BIRD/testCompCor/newCode/wmCSF_', sub, '.csv']);
%     OutputName=['/home/data/Projects/Zhen/BIRD/testCompCor/DPARSF/', sub, '_', num2str(PCNum), 'componets'];
%     
%     AllVolume=data';
%     CUTNUMBER = 10;
%     nDimTimePoints=size(AllVolume, 1);
%     
%     %AllVolume: the voxle signal from WM and CSF
%     % 1. detrend
%     SegmentLength = ceil(size(AllVolume,2) / CUTNUMBER);
%     for iCut=1:CUTNUMBER
%         if iCut~=CUTNUMBER
%             Segment = (iCut-1)*SegmentLength+1 : iCut*SegmentLength;
%         else
%             Segment = (iCut-1)*SegmentLength+1 : size(AllVolume,2);
%         end
%         AllVolume(:,Segment) = detrend(AllVolume(:,Segment));
%         fprintf('.');
%     end
%     
%     % 2. Zero temporal Mean and Unit NORM %use std/sqrt(N)
%     AllVolume = (AllVolume-repmat(mean(AllVolume),size(AllVolume,1),1))./...
%         repmat(std(AllVolume)*sqrt(nDimTimePoints-1),size(AllVolume,1),1);
%     
%     % 3. Remove the voxel with zero variance
%     AllVolumeRow1=AllVolume(1,:);
%     colToRemove=find(isnan(AllVolumeRow1));
%     AllVolume(:, colToRemove)=[]; % Zhen 070214 Zhen set this to []
%     numVoxRemove=size(colToRemove);
%     size(AllVolume)
%     
%     % 4. SVD
%     [U S V] = svd(AllVolume,'econ');
%     
%     PCs = U(:,1:PCNum);
%     
%     
%     %Save the results
%     [pathstr, name, ext] = fileparts(OutputName);
%     
%     PCs = double(PCs);
%     
%     %save([fullfile(pathstr,[name]), '.mat'], 'PCs')
%     save([fullfile(pathstr,[name]), '.txt'], 'PCs', '-ASCII', '-DOUBLE','-TABS')
%     
%     fprintf('\nFinished Extracting principle components for CompCor Correction.\n');
%     
% end
% 
% %% compute the correlation between PCs computed from python and DPARSF
% 
for i=1:length(subList)
    % for i=108
    sub=subList(i, 1:9)
    
    %sub = 'M10914047'
    a=load(['/home/data/Projects/Zhen/BIRD/testCompCor/newCode/comps_', sub, '.csv']);
    %b=load(['/home/data/Projects/Zhen/BIRD/testCompCor/DPARSF/', sub, '_5componets.txt']);
b=load(['/home/data/Projects/Zhen/BIRD/testCompCor/newCode/compsOnlyDemean_', sub, '.csv']);
    
    %just compute the correlation directly
%     for j=1:PCNum
%         %correl(i,j)=corr(abs(a(:,j)), abs(b(:,j)));
%         correl(i,j)=corr(a(:,j), b(:,j));
%     end
    %
        % use procrustes to transform the data
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
    
    hist(abs(correl(:,j)))
    ylim([0 100])
    %xlim([0.8 1.2])
end

