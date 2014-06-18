clear
clc
close all

addpath /home/data/Projects/Zhen/commonCode/BrainNetViewer
%addpath /home/data/Projects/Zhen/microstate/DPARSF_preprocessed/code/colorRamp.m
addpath /home/data/Projects/Zhen/commonCode

imgInputDir = ['/home/data/Projects/Zhen/workingMemory/figs/paper_figs/compStrategies/compCor/CWAS/test'];
cd (imgInputDir)

NMin=-0.001; PMin = 0.001;
NMax=-4; PMax=4; % for CWAS set for 4, for others set for 5 to plot the overlapping

Prefix='';
DirImg = dir([imgInputDir,filesep,Prefix,'*.nii.gz']);

% AFNI colorMap
% ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0;1,0,0;0,0,1;0,0.2667,1;0,0.4118,1;0,0.6,1;0,0.8,1;0,1,1;];

% colormap used to plot the overlap
% ColorMap=[1,1,0;1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0; 64, 224, 208; 106, 90, 205; 30, 144, 255; 255, 255, 0; 220, 20, 60];
%
% ColorMap=[1,0.8,0;1,0.6,0;1,0.4118,0;1,0.2667,0; 64, 224, 208; 106, 90, 205; 30, 144, 255; 255, 255, 0];
% ColorMap=ColorMap/255;

% the colorMap used in the pib. This is for plotting the threshed Z map.
% remember to change the scale to -5 to 5
ColorMap=[1,1,0;1,0.9,0;1,0.8,0;1,0.7,0;1,0.6,0;1,0.5,0;0,0.5,1;0,0.6,1;0,0.7,1;0,0.8,1;0,0.9,1;0,1,1;];
ColorMap=flipdim(ColorMap,1);
cmap1 = colorRamp(ColorMap(1:6,:), 32);
cmap2= colorRamp(ColorMap(7:end,:), 32);
ColorMap=vertcat(cmap1,cmap2);

% the colormap below are for plotting the combined or overlapped maps
% [64, 196, 255] and [255, 255, 0] are fake, always using odd number of
% colors, the middle, the first, or the last are colors possibly not used.
%ColorMap=[0, 128,0; 106, 196, 255; 51, 83, 255; 106, 90, 205; 64, 196, 255; 230, 123, 184; 228, 108, 10;  255, 255, 0; 205, 0, 0]

%ColorMap=[ 106, 196, 255; 51, 83, 255; 102, 60, 123; 106, 90, 205; 64, 196, 255; 230, 123, 184; 228, 108, 10; 255, 226, 0] % used to plot Smith 7ICNs
%ColorMap=[ 106, 196, 255; 106, 90, 205; 64, 196, 255; 230, 123, 184; 228, 108, 10; 255, 226, 0] % used to plot Smith 5ICNs

%ColorMap=[0, 128,0; 106, 196, 255; 230, 123, 184; 64, 196, 255; 228,
%108, 10;  255, 255, 0; 205, 0, 0] % plot the negClusters of univariate analysis ME
%ColorMap=[0, 128,0;  51, 83, 255; 106, 90, 205; 64, 196, 255; 230, 123, 184; 228, 108, 10;  255, 255, 0] % plot the poscluster of univariate analysis ME

%ColorMap=[ 51, 83, 255; 106, 90, 205; 64, 196, 255; 255, 230, 0; 238, 129,
%0]; % plot the overlap of all approaches

% modified Afni colormap used to plot the CWASinteraction followup iFC analysis
% ColorMap=[1,1,0;1,0.8,0;1,0.4118,0;1,0,0;0,0,1;0,0.4118,1;0,0.8,1;0,1,1;];
% ColorMap=flipdim(ColorMap,1);

%ColorMap=[64, 224, 208; 106, 90, 205; 30, 144, 255; 230, 93, 184; 221, 0, 0]; % this is for CWAS results < 4 clusters. the cluster numbers were recoded as half neg and half pos, so the plot can be symmetric.
%colorMap=[64, 196, 255; 106, 90, 205; 0, 128,0; 30, 144, 255; 228, 108, 10; 230, 93, 184; 221, 0, 0]; % this is for < 6 clusters

%ColorMap=[102, 60, 123;228, 108, 10;0, 128,0;0, 0, 255;255, 0,
%0] % plot univariate AgexDT effect
%ColorMap=ColorMap/255;

surfaceMapOutputDir = imgInputDir;
numImg=length(DirImg)


PicturePrefix='';

ClusterSize=0;

SurfaceMapSuffix='_SurfaceMap.jpg';


ConnectivityCriterion=18;

[BrainNetViewerPath, fileN, extn] = fileparts(which('BrainNet.m'));

SurfFileName=[BrainNetViewerPath,filesep,'Data',filesep,'SurfTemplate',filesep,'BrainMesh_ICBM152_smoothed.nv'];

viewtype='MediumView';



for i=1:numImg
    InputName = [imgInputDir,filesep,DirImg(i).name];
    
    OutputName = [surfaceMapOutputDir,filesep, DirImg(i).name(1:end-4),SurfaceMapSuffix];
    
    H_BrainNet = rest_CallBrainNetViewer(InputName,NMin,PMin,ClusterSize,ConnectivityCriterion,SurfFileName,viewtype,ColorMap,NMax,PMax);
    
    eval(['print -r300 -djpeg -noui ''',OutputName,''';']);
end

