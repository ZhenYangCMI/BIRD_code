clear
clc

addpath /home/data/Projects/Zhen/commonCode
codeDir='/home/data/Projects/Zhen/commonCode/';
javaaddpath([codeDir, 'poi_library/poi-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/poi-ooxml-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/poi-ooxml-schemas-3.8-20120326.jar']);
javaaddpath([codeDir, 'poi_library/xmlbeans-2.3.0.jar']);
javaaddpath([codeDir, 'poi_library/dom4j-1.6.1.jar']);
javaaddpath([codeDir, 'poi_library/stax-api-1.0.1.jar']);

mask='/home/data/Projects/Zhen/BIRD/mask/AAL_61x73x61_YCG_reduced.nii';
[MaskData,MaskVox,MaskHead]=rest_readfile(mask);
ROI=unique(MaskData);
ROI=ROI(find(ROI~=0));

tmp1=load('/home/data/Projects/Zhen/commonCode/BrainNetViewer1.43/BrainNet_AAL_Label.mat')
label=tmp1.AAL_label;
NodeCoordinates=load('/home/data/Projects/Zhen/commonCode/Node_AAL116.txt');

BIRD_mask_label=[];
BIRD_node=[];
for i=1:length(ROI)
    BIRD_mask_label{i,1}=label{ROI(i)};
BIRD_node(i,:)=NodeCoordinates(ROI(i), :);
end

dataDir='/home/data/Projects/Zhen/BIRD/data/'
NodeCoordinate={'X','Y','Z'};
save([dataDir, 'BIRD_AALnode_coordinate.mat'], 'BIRD_node')
delete ([dataDir, 'AAL_BIRD.xls'])
xlwrite([dataDir, 'AAL_BIRD.xls'],cellstr('ROI_number'), 'sheet1','A1');
xlwrite([dataDir, 'AAL_BIRD.xls'],cellstr('AAL_labels'), 'sheet1','B1');
xlwrite([dataDir, 'AAL_BIRD.xls'], ROI, 'sheet1','A2');
xlwrite([dataDir, 'AAL_BIRD.xls'], cellstr(BIRD_mask_label), 'sheet1','B2');
xlwrite([dataDir, 'AAL_BIRD.xls'], NodeCoordinate, 'sheet1','C1');
xlwrite([dataDir, 'AAL_BIRD.xls'], BIRD_node, 'sheet1','C2');
