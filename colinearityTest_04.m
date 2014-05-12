% multicolinearity test for noGSR, GSR, compCor, and meanRegression
clear
clc

numSub=115

model=load(['/home/data/Projects/BIRD/data/regressionModel.txt']);
labelsFull={'age_demean', 'DT_group', 'age_demeanByDT_group', 'meanFD', 'constant'}
    modelFull=[model(:, 1) model(:, 2) model(:, 3) model(:, 4) ones(numSub, 1)];

labels={'age_demean', 'DT_group', 'age_demeanByDT_group', 'meanFD', 'SES_demean', 'constant'}
    model=[model(:, 1) model(:, 2) model(:, 3) model(:, 4) model(:, 5) ones(numSub, 1)];
 
 
% You can also add an interecept term, which reproduces Belsley et al.'s
% example
colldiag(model,labels)
colldiag(modelFull,labelsFull)




