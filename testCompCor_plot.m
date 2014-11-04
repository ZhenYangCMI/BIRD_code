clear
clc
close all

dataDir='/home/data/Projects/Zhen/BIRD/testCompCor/newCode/';
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

%% plot the correlations between PCs and tissue signal
for i=1:length(corList)
    corType=char(corList(i))
    
    a=load([dataDir, corType, 'Detrend_5PC.csv']);
    
    % plot mean correlation
    average=mean(abs(a))
    x=1:size(a,2)
    figure(i)
    bar(x,average)
    ylim([0 0.8])
    saveas(figure(i), [dataDir, corType, '_5PC_bar.png'])
    close all
    
    figure(i)
    for j=1:size(a,2)
        subplot(2,3,j)
        xvalue=-1:0.1:1;
        b=abs(a(:,j));
        hist(b, xvalue)
        ylim([0 60])
        xlim([-0.5 1.5])
    end
    saveas(figure(i), [dataDir, corType, '_5PC_hist.png'])
    close all
    
end

