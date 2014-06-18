clear
clc
close all

addpath /home/data/Projects/Zhen/commonCode/BrainConnectivityToolbox20121204
addpath /home/data/Projects/Zhen/BIRD/BIRD_code/dynamicAnalysis/BrainNetViewer

resultDir=['/home/data/Projects/Zhen/BIRD/results/PCA_100ROI/'];
figDir =['/home/data/Projects/Zhen/BIRD/figs/PCA/Poster_figs/'];

% load the eigenvectors (EVs)
tmp=load([resultDir,'eigenvector_norm2.mat']);
eigenVector=tmp.COEFF;

numPC=10;
% Extract the first 10 EVs
PCs=eigenVector(:,1:numPC);

% load the node label
[NUM,TXT,RAW]=xlsread(['/home/data/Projects/Zhen/BIRD/data/AAL_BIRD.xls']);
labels=TXT(2:end, 6);
% Threshold the edges for each EV using the edge values from all 10 EVs
topNode=[];
for t=4
    disp (['Working on PC', num2str(t)])
    PC=PCs(:, t);
    Alledges=reshape(PC, [],1);
    pos=Alledges(find(Alledges>0));
    neg=Alledges(find(Alledges<0));
    
    PCThresh=PC;
    for j=1:size(PC,1)
        if PC(j)>0 && PC(j)<prctile(pos,98)
            PCThresh(j)=0;
        elseif PC(j)<0 && PC(j)>prctile(neg, 2)
            PCThresh(j)=0;
        else
            PCThresh(j)=PC(j);
        end
    end
    PCThreshBinary=logical(PCThresh);
    
    % setup the parameters to call brainnet viewer
    tmp1=load('/home/data/Projects/Zhen/BIRD/data/BIRD_AALnode_coordinate.mat');
    NodeCoordinates=tmp1.BIRD_node;
    
    EdgeMatrix=squareform(PC);
    EdgeMatrixThreshed=squareform(PCThresh);
    EdgeMatrixThreshedBinary=squareform(PCThreshBinary);
    
    EdgeThreshold=0;
    
    NodeWeight=sum(abs(EdgeMatrix))';
    NodeWeight=NodeWeight.^2;
    numEdges=sum(EdgeMatrixThreshedBinary);
    
    % run the modularity analysis
    [Ci Q] = modularity_louvain_und_sign(EdgeMatrix);
    NodeColor=Ci';
    
    for i=1:size(NodeCoordinates,1)
        NodeLabel{i,1}={{'-'}};
    end
    
    [sortedValues,sortIndex]=sort(NodeWeight,'descend');
    for k=1:5 % label the top 5 nodes
        NodeLabel{sortIndex(k),1}={labels(sortIndex(k))};
        topNode{k,t}=char(labels(sortIndex(k)));
    end
    
    ModularIndex=unique(Ci)
    colorMap=[0 255 0; 138 43 226; 255 255 0; 255 0 255; 0 255 255; 255 0 0];
    colorMap=colorMap/255;
    
    NodeColorMap=colorMap(1:length(ModularIndex),:);
    
    %viewtypeList={'SagittalView', 'AxialView'};
    viewtypeList={'MediumView'};
    for j=1:length(viewtypeList)
        viewtype=char(viewtypeList(j))
        SurfFileName='/home/data/Projects/Zhen/commonCode/BrainNetViewer1.43/Data/SurfTemplate/BrainMesh_ICBM152.nv';
        
        H_BrainNet = y_CallBrainNetViewer_NodeEdge(NodeCoordinates,EdgeMatrixThreshed,EdgeThreshold,NodeWeight,1,NodeColor,NodeColorMap,NodeLabel,ModularIndex,viewtype,SurfFileName)
        
        OutputName=[figDir, 'surfaceMap_PC', num2str(t), '_', viewtype, '.jpg'];
        eval(['print -r300 -djpeg -noui ''',OutputName,''';']);
    end
end
save([resultDir, '5topNode.mat'], 'topNode')
