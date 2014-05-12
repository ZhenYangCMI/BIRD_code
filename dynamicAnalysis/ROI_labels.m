clear
clc

mask='/home/data/Projects/BIRD/mask/AAL_61x73x61_YCG_reduced.nii';
[MaskData,MaskVox,MaskHead]=rest_readfile(mask);
ROI=unique(MaskData);
ROI=ROI(find(ROI~=0))

tmp=load('/home/data/Projects/HCP/code/BrainNetViewer/BrainNet_AAL_Label.mat')
label=tmp.AAL_label;

BIRD_mask_label=[];
for i=1:length(ROI)
    BIRD_mask_label{i,1}=label{ROI(i)};
end

dataDir='/home/data/Projects/BIRD/data/'
javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');

xlwrite([dataDir, 'AAL_BIRD_mask_label.xls'],'ROI_number', 'sheet1','A1');
xlwrite([dataDir, 'AAL_BIRD_mask_label.xls'],'AAL_labels', 'sheet1','B1');
xlwrite([dataDir, 'AAL_BIRD_mask_label.xls'], ROI, 'sheet1','A2');
xlwrite([dataDir, 'AAL_BIRD_mask_label.xls'], BIRD_mask_label, 'sheet1','B2');