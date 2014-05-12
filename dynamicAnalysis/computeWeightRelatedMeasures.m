close all
clear
clc

project='BIRD';
subListFile='/home/data/Projects/BIRD/data/final110sub.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n');
subList=cell2mat(subList{1});
numSub=length(subList);

norm='norm2';
numPC=10;

resultDir=['/home/data/Projects/', project, '/results/PCA/'];
figDir = ['/home/data/Projects/', project, '/figs/PCA/'];

tmp=load([resultDir,'/eigenvector_',norm, '.mat']);
PCs=tmp.COEFF;
a=PCs(:,1:10);

tmp1=load([resultDir,'/norm2FeatureWin.mat'])
normFeature=tmp1.norm2FeatureWin;
% projects the eigenVector to subject dyanmic FC matrix

numVol=890;
winSize=69;
step=3;
numWinPerSub=floor((numVol-winSize)/step)+1;
numSub=length(subList);
numWinAllSub=numWinPerSub*numSub;

allW=zeros(numSub,numWinPerSub, numPC);
for i=1:numSub
    
    % compute the weight by regression
    eachSub= normFeature(1+(i-1)*numWinPerSub: i*numWinPerSub, :)';
    W=a'*eachSub;
    
    for j=1:numPC
        
        allW(i,:,j)=W(j,:);
        % calc the % of pos weights
        prctPosW(i,j)=length(find(W(j,:)>0))/numWinPerSub*100;
        
        % calc the average magnitude of pos weights
        avgPosW(i,j)=mean(W(j,find(W(j,:)>0)));
        
        % calc the skewness of the W TS
        skewW(i,j)=skewness(W(j,:));
        
        % calc the std of thw W TS
        stdW(i,j)=std(W(j,:));
        
        % calc the transitions from - to + or + to -
        count=0;
        for k=1:size(W,2)-1
            if W(j,k)*W(j,k+1)<0
                count=count+1;
            end
        end
        transition(i,j)=count;
    end
    
end

%plot the weights for an exemplar subject
%color=['r','b','g','y','k','c','m', 'r--', 'b--','g--']
color=[1 215/255 0; 1 0 1; 0 1 1; 1 0 0; 0 1 0; 0 0 1; 0 0 0;205/255 92/255 92/255;85/255 107/255 47/255; 0 128/255 128/255];
for k=1:numSub
    sub=k;  % sub <=49;
    
    figure(k)
    for j=1 % numSession
        subplot(1,1,j)
        for i=1:10
            
            plot(allW(sub+numSub*(j-1),:,i), 'Color', color(i,:), 'LineWidth', 1)
            hold on
        end
        if mod(j,2)==1
            ses='1';
        else
            ses='2';
        end
        
        ylim([-60 80])
        xlabel('Time windows')
        ylabel('Time-dependent Weights')
    end
    saveas(figure(k), [figDir, 'sub', num2str(sub), '_weightsTC.jpg'])
    close all
end

% compute the threshold
Y=zeros(numPC,1);

for j=1:numPC
%     meanW(j,1)=mean(mean(allW(:,:,j)));
%     stdW(j,1)=std(std(allW(:,:,j)));
    pos=reshape(allW(:,:,j), [], 1);
    Y(j,1)= prctile(pos(find(pos>0)), 20);
end

% compute the metrics after thresholding
for i=1:numSub
    for j=1:numPC
        tmpW=allW(i,:,j);
        prctSigPosW(i,j)=length(find(tmpW>Y(j)))/numWinPerSub*100;
        avgSigPosW(i,j)=mean(tmpW(find(tmpW>Y(j))));
        medianSigPosW(i,j)=median(tmpW(find(tmpW>Y(j))));
        medianPosW(i,j)=median(tmpW(find(tmpW>0)));
        flag=0;
        count=0;
        for m=1:size(tmpW,2)
            if flag==0 && tmpW(m)>=Y(j)
                count=count+1;
                flag=1;
            elseif tmpW(m)<Y(j)
                flag=0;
            end
        end
        
        timesSigPosW(i,j)=count;
        
        durationSigPosW(i,j)=prctSigPosW(i,j)/timesSigPosW(i,j);
        
    end
end

metricList={'prctPosW', 'avgPosW', 'medianPosW',  'prctSigPosW', 'transition', 'avgSigPosW', 'medianSigPosW', 'timesSigPosW', 'durationSigPosW', 'skewW', 'stdW'}
allDynamicMetrics=[prctPosW, avgPosW, medianPosW,  prctSigPosW, transition, avgSigPosW, medianSigPosW, timesSigPosW, durationSigPosW, skewW, stdW];
save('/home/data/Projects/BIRD/data/allDynamicMetrics.txt',  '-ascii', '-tabs' , 'allDynamicMetrics')

%plot the ECs
for i=1:numPC
figure(i)
PC=squareform(a(:,i));
imagesc(PC)
colorbar
caxis([-0.03 0.03])
saveas(figure(i), [figDir, 'PC', num2str(i), '.jpg'])
end
