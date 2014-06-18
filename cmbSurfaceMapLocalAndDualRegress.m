
% This script will combine individual surface map for into one panel for both full and separate models

clear
clc
close all
%%%Get the Surface maps
preprocessDate='1_24_14'

map='easythresh_110sub'; % easythresh unthresh

%approachList={'localMeasure', 'gRAICAR1', 'gRAICAR2'}; % localMeasure or gRAICAR
approachList={'localMeasure'}

OutputUpDir = ['/home/data/Projects/BIRD/figs/'];
for m=1:length(approachList)
    approach=char(approachList{m})
    
    if strcmp(approach, 'localMeasure')
        measureList={'ReHo', 'DegreeCentrality','fALFF', 'VMHC', 'CWAS'};
        %measureList={'ReHo', 'DegreeCentrality','fALFF', 'VMHC'};
    elseif strcmp(approach, 'gRAICAR1')
        measureList={'DualRegression0', 'DualRegression1', 'DualRegression2', 'DualRegression3', 'DualRegression4'};
    else
        measureList={'DualRegression5', 'DualRegression6', 'DualRegression7', 'DualRegression8', 'DualRegression9'};
    end
    
    numMeasure=length(measureList)
    numRow=length(measureList);
    BackGroundColor = uint8([255*ones(1,1,3)]);
    
    img=[];
    t=0;
    
    for i=1:numRow
        
        row=char(measureList{i})
        
        if  strcmp(row, 'CWAS')
            effectList={'age_demeanByDT_group.ni', 'DT_group_name.ni', 'age_demean.ni'};
        else
            effectList={'T3', 'T2', 'T1'};
        end
        
        
        numCol=length(effectList);
        
        for j=1:numCol
            col=char(effectList{j})
            t=t+1
            if strcmp(map, 'unthresh')
                if strcmp(row, 'CWAS')
                    img{t,1} = {sprintf('/home/data/Projects/BIRD/figs/%s/zstats_%s_SurfaceMap.jpg', row, col)};
                else
                    img{t,1} = {sprintf('/home/data/Projects/BIRD/figs/unthresh/%s_%s_Z_SurfaceMap.jpg', row, col)};
                end
            else
                if strcmp(row, 'CWAS')
                    img{t,1} = {sprintf('/home/data/Projects/BIRD/figs/easythresh_110sub/thresh_%s_%s_SurfaceMap.jpg', row, col)};
                else
                    img{t,1} = {sprintf('/home/data/Projects/BIRD/figs/easythresh_110sub/thresh_%s_%s_Z_cmb_SurfaceMap.jpg', row, col)};
                end
            end
        end
    end
    
    
    for k=1: numRow*numCol
        fileRead=char(img{k})
        imdata(:, :, :, k)=imread(fileRead);
    end
    
    % define the size of the row, the column, and the whole picture
    UnitRow = size(imdata,1); % this num should be corresponding to the size(imdata, 1)
    
    UnitColumn = size(imdata,2); % this num should be corresponding to the size(imdata, 2)
    
    imdata_All = repmat(BackGroundColor,[UnitRow*numRow,UnitColumn*numCol,1]);
    
    
    k=0
    for m=1:numRow
        for n=1:numCol
            k=k+1
            imdata_All (1+(m-1)*UnitRow:m*UnitRow,1+(n-1)*UnitColumn:n*UnitColumn,:) = imdata(:, :, :, k);
        end
    end
    
    figure
    image(imdata_All)
    axis off          % Remove axis ticks and numbers
    axis image        % Set aspect ratio to obtain square pixels
    OutJPGName=[OutputUpDir, approach, '_', map, '.jpg'];
    eval(['print -r300 -djpeg -noui ''',OutJPGName,''';']);
    
end



