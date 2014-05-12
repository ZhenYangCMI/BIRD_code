%steps of doing classification:
%1. Run 10-fold cross validation TreeBagger to detect the top 5 most
%important features and estimate a good size of ensembles
% try different trees and pick up the 5 most frequently included
%2. Run sequential feature selection with the top 5 features kept in and
%the resulting feature list will be fitted into multiple classification
%algorithms
%3. Run classification with the reduced feature.

clc
clear
close all

addpath /home/data/Projects/BIRD/BIRD_TB/Machine_Learning
%%1. load in the data and separate data into xTrain, yTrain, xTest, and yTest

[NUM,TXT,RAW]=xlsread('/home/data/Projects/BIRD/BIRD_TB/phenotypicalData_organized.xlsx','ImgAndIndividualQuestion_104sub', 'A1:UG106' ); % 'ImgAndPhenPredictors_104sub', 'A1:DG105'; 'DynAndStatPredict_110sub_noINT', 'A1:BH111'
%[NUM,TXT,RAW]=xlsread('phenotypicalData_organized.xlsx', 'V8_forSVCWithASR_BDI', 'A1:BQ86');
% separately data into high and low DT group based on DT grouping
high=NUM(find(NUM(:,1)==1),:);
low=NUM(find(NUM(:,1)==-1),:);

% compute the mumber of sub for training 90%
numHigh=size(high,1);
numLow=size(low,1);

% only used it the first time, later runs use the saved index file
% highRand=randperm(numHigh);
% lowRand=randperm(numLow);
% save('/Users/zhenyang/Documents/Zhen_CMI_projects/BIRD/matlab/output/randomIndx.mat', 'highRand', 'lowRand')

tmp1=load('/home/data/Projects/BIRD/BIRD_TB/output/randomIndx_104sub.mat');
highRand=tmp1.highRand;
lowRand=tmp1.lowRand;

% hold 10% for testing

testHigh=high(highRand(1:4), :);
testLow=low(lowRand(1:4),:);


% the training data
trainHigh=high(highRand(5:44),:);
trainLow=[low(lowRand(5:43),:); low(lowRand(20), :)];


numTrees=200


%% 1. run 10 folders corss-validation and train the treebagger classifier with the 90% of the training data
% criteria=10 %used to count the number of times a feature appearing as top 15 important features
% accuracy=zeros(2,2,10);
% error=zeros(numTrees,10);
% topFeature=zeros(criteria,10);
% impScore=zeros((size(NUM,2)-1),10);
% includedFeature=[];
% numSub=size(trainHigh,1)/10;
% for i=1:10
% 
%     disp(['corss validation ', num2str(i)])
%     t=cputime;
%     testIndx=(1+numSub*(i-1):numSub*i);
% 
%     %1. define training predictors and category data
%     cvTrainHigh=trainHigh;
%     cvTrainHigh(testIndx,:)=[];
% 
%     cvTrainLow=trainLow;
%     cvTrainLow(testIndx,:)=[];
% 
%     cvTrainX=[cvTrainHigh(:,2:end);cvTrainLow(:,2:end)];
%     cvTrainX_Z=(cvTrainX-repmat(mean(cvTrainX),size(cvTrainX,1),1))./repmat(std(cvTrainX), size(cvTrainX,1),1);
% 
%     cvTrainY=[cvTrainHigh(:,1); cvTrainLow(:,1)];
%     cvTrainY=nominal(cvTrainY);
% 
%     %2. define testing predictors and category data
%     cvTestHigh=trainHigh(testIndx, :);
%     cvTestLow=trainLow(testIndx, :);
% 
%     cvTestX=[cvTestHigh(:,2:end);cvTestLow(:,2:end)];
%     cvTestX_Z=(cvTestX-repmat(mean(cvTestX),size(cvTestX,1),1))./repmat(std(cvTestX), size(cvTestX,1),1);
% 
%     cvTestY=[cvTestHigh(:,1); cvTestLow(:,1)];
%     cvTestY=nominal(cvTestY);
% 
% 
%     %3. run TreeBagger
%     cost = [0 1; 1 0];
% 
%     tb=TreeBagger(numTrees, cvTrainX_Z, cvTrainY, 'method', 'classification', 'OOBPred', 'on', 'OOBVarImp', 'on', 'cat', ([1:190, 194:485]), 'cost',cost);
% 
%     [Y_tb,classifScore]=tb.predict(cvTestX_Z);
%         Y_tb=nominal(Y_tb);
% 
%     cvTestY=nominal(cvTestY);
% 
%     c_tb=confusionmat(cvTestY, Y_tb);
%     c_tb_prct=bsxfun(@rdivide, c_tb, sum(c_tb,2))*100
% 
%     c_tb_all(:,:,i)=c_tb;
%     accuracy(:,:,i)=c_tb_prct;
%     error(:,i)=oobError(tb);
% 
%     % compute values for receiver operating characteristic (ROC) curve
% 
%     classifScoreAll(:,:,i)=classifScore;
%     % sort the importance scores
%     [~,idxvarimp] = sort(tb.OOBPermutedVarDeltaError, 'descend');
% 
%     topFeature(:,i)=idxvarimp(1,1:criteria)';
%     impScore(:,i)=tb.OOBPermutedVarDeltaError;
%     e=(cputime-t)/60;
%     disp(['The elapsed time is ', num2str(e), ' minutes.'])
% end
% 
% % sumary of TreeBagger 10 folder cross validation results
% d=reshape(classifScoreAll, [],10);
% dmean=mean(d,2);
% meanClassifScore=reshape(dmean,numSub*2,2);
% [xVal,yVal,~,auc] = perfcurve(cvTestY,meanClassifScore(:,2),'1', 'negClass', '-1');
% 
% b=reshape(accuracy, [], 10);
% bmean=mean(b,2);
% meanAccuracy=reshape(bmean, 2,2)
% 
% c=reshape(c_tb_all, [],10);
% cmean=mean(c,2);
% meanClassifyResults=reshape(cmean,2,2)
% 
% meanError=mean(error,2);
% topFeatureAll=reshape(topFeature, 1,[]);
% meanImpScore=mean(impScore, 2);
% save('/Users/zhenyang/Documents/Zhen_CMI_projects/BIRD/matlab/output/TreeBagger10FolderCVResults.mat', 'meanError', 'xVal','yVal', 'auc', 'topFeatureAll', 'meanImpScore', 'meanClassifyResults')
% 
% %estimating the size of the ensemble
% figure;
% plot(meanError);
% xlabel('Number of Grown Trees');
% ylabel('Out-of-Bag Classification Error/Misclassification Probability');
% %ylim([0.4 0.55])
% 
% 
% % plot ROC
% xRand(1)=0; yRand(1)=0; xRand(2)=1; yRand(2)=1;
% xPerf(1)=0; yRand(1)=1;xPerf(2)=1;yPerf(2)=1;
% figure
% plot(xVal, yVal, 'r')
% hold on
% plot(xRand, yRand, 'k')
% hold on
% plot(xPerf, yPerf, 'b')
% xlabel('False positive rate');
% ylabel('True positive rate')
% title(['ROC curve for ''low'', predicted vs. actual response (Test Set', num2str(numTrees), 'trees)'])
% text(0.5,0.25,{'TreeBagger with full feature set',strcat('Area Under Curve = ',num2str(auc))},'EdgeColor','k');
% 
% 
% % estimating feature importance
% figure;
% bar(meanImpScore);
% ylabel('Out-Of-Bag Feature Importance');
% set(gca,'XTick',1:size(cvTrainX,2))
% names=TXT(1, 3:end);
% % set(gca,'XTickLabel',names)
% % Use file submitted from a user at MATLAB Central to rotate labels
% % rotateXLabels( gca, 60 )
% 
% % importance evaluated by frequency appearing as top 5 features
% table=tabulate(topFeatureAll);
% 
% [sortedValues,sortIndex]=sort(table(:,2),'descend');
% 
% maxIndex = sortIndex(1:10);
% disp('Top 10 features selected according to times as top 5 features in cross-validation:');
% disp(names(maxIndex)')
% 
% 
% % importance evaluated by importance score
% [~,meanIdxvarimp] = sort(meanImpScore, 'descend');
% top10=meanIdxvarimp(1:10);
% disp('Top 10 features selected accroding to the mean importance score:');
% names(top10)'
% save('/Users/zhenyang/Documents/Zhen_CMI_projects/BIRD/matlab/output/top10featureIndx_tb.mat', 'top10')

% the top 5 appeared accroding to both criteria were selected to feed in
% sequentialfs function

%% 2. Sequential feature selection
%featureImp: This function computes the misclassification rate for a given
%modeltype
tmp=load('/home/data/Projects/BIRD/BIRD_TB/output/top10featureIndx_tb_ImgAndIndividualQuest.mat')
top10=tmp.top10;
x=[trainHigh(:, 2:end); trainLow(:,2:end)];
y=[trainHigh(:, 1); trainLow(:,1)];
y=nominal(y);
x_Z=(x-repmat(mean(x),size(x,1),1))./repmat(std(x), size(x,1),1);
if matlabpool('size') == 0
    matlabpool open 12
end
opts1 = statset('UseParallel','always');
opts2 = statset('display','iter');
critfun = @(Xtr,Ytr,Xte,Yte)featureImp(Xtr,Ytr,Xte,Yte,'TreeBagger');

%     The top 5 features determined in the previous step have been included,
%     to reduce the number of combinations to be tried by sequentialfs
t=cputime;
[fs,history] = sequentialfs(critfun,x_Z,y,'options',opts1,'options',opts2,'keepin',top10);
e=(cputime-t)/60;
disp(['The elapsed time is ', num2str(e), ' minutes.'])
%[47,11,34,45,23] kept predictor for phenotype
disp('Included features:');
names=TXT(1, 3:end);
disp(names(fs)');

save('/home/data/Projects/BIRD/BIRD_TB/output/sequentiallySelectedFeature_ImgAndIndividualQuest_run2.mat', 'fs')



%% 3. TreeBagger with reduced feature set
% criteria=20
% numTrees=5 % determined according to the first round Treebagger
% tmp2=load('/Users/zhenyang/Documents/Zhen_CMI_projects/BIRD/matlab/sequentiallySelectedFeature.mat');
% fs=tmp2.fs;
% features=find(fs~=0);
% %features(find(features==46))=[]
% names=TXT(1, 3:end);
% names2=names(1, features);
% 
% rawCat=[1:190, 194:485]; % for phenotypic only
% reducedCat=intersect(rawCat,find(fs~=0))
% 
% xTest=[testHigh(:,2:end); testLow(:, 2:end)];
% xTest_Z=(xTest-repmat(mean(xTest),size(xTest,1),1))./repmat(std(xTest), size(xTest,1),1);
% yTest=[testHigh(:,1);testLowY(:,1)];
% yTest=nominal(yTest);
% 
% %run TreeBagger
% cost = [0 1;1 0];
% 
% tb=TreeBagger(numTrees, xTrain_Z, yTrain, 'method', 'classification', 'OOBPred', 'on', 'OOBVarImp', 'on', 'cat', reducedCat, 'cost',cost);
% 
% [Y_tb,classifScore]=tb.predict(xTest_Z(:,features));
% 
% Y_tb=nominal(Y_tb);
% 
% c_tb=confusionmat(yTest, Y_tb);
% c_tb_prct=bsxfun(@rdivide, c_tb, sum(c_tb,2))*100
% 
% [xVal,yVal,~,auc] = perfcurve(yTest,classifScore(:,2),'1', 'negClass', '-1');
% 
% error=oobError(tb);
% impScore=tb.OOBPermutedVarDeltaError;
% 
% % sort the importance scores
% [sortedValues,sortIndx] = sort(impScore, 'descend');
% 
% topFeature=sortIndx(1,1:criteria)';
% disp('Features sorted by importance:')
% disp(names2(topFeature)');
% 
% e=(cputime-t)/60;
% disp('The elapsed time is ', num2str(e), ' minutes.')
% 
% % plot error rate
% figure(1)
% plot(error);
% xlabel('Number of Grown Trees');
% ylabel('Out-of-Bag Classification Error/Misclassification Probability');
% %ylim([0.25 0.5])
% 
% 
% % plot ROC
% figure(2)
% xRand(1)=0; yRand(1)=0; xRand(2)=1; yRand(2)=1;
% xPerf(1)=0; yRand(1)=1;xPerf(2)=1;yPerf(2)=1;
% 
% plot(xVal, yVal, 'r', 'lineWidth', 2)
% hold on
% plot(xRand, yRand, 'k')
% hold on
% plot(xPerf, yPerf, 'b')
% xlabel('False positive rate');
% ylabel('True positive rate')
% %title(['ROC curve for ''high'', predicted vs. actual response (Test Set', num2str(numTrees), 'trees)'])
% text(0.5,0.25,{,strcat('AUC = ',num2str(auc))},'EdgeColor','k');
% 
% % plot feature importance score
% figure(3)
% bar(impScore);
% ylabel('Out-Of-Bag Feature Importance');
% set(gca,'XTick',1:size(xTrain,2))
% 
% save('/Users/zhenyang/Documents/Zhen_CMI_projects/BIRD/matlab/output/TBTestWithreducedFeature.mat', 'error', 'xVal', 'yVal','auc', 'impScore', 'c_tb', 'c_tb_prct')
