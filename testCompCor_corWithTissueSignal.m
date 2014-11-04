clear
clc
close all

dataDir='/home/data/Projects/Zhen/BIRD/testCompCor/new_CameronCode/';
corList={'global', 'wm', 'csf', 'gm'};

%% plot the correlation between tissue signals
% a=load([dataDir, 'cor_tissueSig_allSub.csv']);
% size(a)
% average=mean(a)
% x=1:size(a,2)
% 
% figure(1)
% bar(x,average)
% ylim([0 1])
% figure(2)
% for j=1:size(a,2)
%     subplot(2,3,j)
%     xvalue=-1:0.1:1;
%     hist(a(:,j), xvalue)
%     if j~=3
%              ylim([0 30])
%     end
%              xlim([-1.2 1.2])
% end
% 
% saveas(figure(1), [dataDir, 'cor_tissue_meanCor.png'])
% saveas(figure(2), [dataDir, 'cor_tissue_CorDistribution.png'])


% for i=1:length(corList)
%     corType=char(corList(i))

%[number,txt,raw]= xlsread([dataDir, corType, '_5PC.csv'], 'sheet1','A1:E110');
%     a=load([dataDir, corType, '_5PC.csv']);
%     size(a)
%     average=mean(a)
%     x=1:size(a,2)
%
%     figure(i)
%     bar(x,average)
%     ylim([-0.18 0.02])

%     for j=1:size(a,2)
%         subplot(2,3,j)
%         xvalue=-1:0.1:1;
%         hist(a(:,j), xvalue)
%         ylim([0 30])
%         xlim([-1.5 1.5])
%     end
%saveas(figure(i), [dataDir, corType, '_5PC_hist.png'])
%saveas(figure(i), [dataDir, corType, '_5PC_bar.png'])

%end

