close all
clear all
clc

dataDir='/home/data/Projects/distressToleronce/data/'

javaaddpath('poi_library/poi-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-3.8-20120326.jar');
javaaddpath('poi_library/poi-ooxml-schemas-3.8-20120326.jar');
javaaddpath('poi_library/xmlbeans-2.3.0.jar');
javaaddpath('poi_library/dom4j-1.6.1.jar');
javaaddpath('poi_library/stax-api-1.0.1.jar');

[number,txt,raw]=xlsread([dataDir, 'crossCollapsetest_20140122_ageBIRD.xlsx'],'allSub');
[r,c]=size(number);
[rt,xt]=size(raw);

%headlines=rt-r;
headlines=1;
% for i=1:headlines-1
%     str1='A';
%     linenumber=sprintf('%s%d',str1,i);
%     xlwrite('tmp.xlsx', raw(i,:), 'sheet1',linenumber); 
% end


% code a matrix to hold the cell number in excel (A-AA AB...-BA BB...)
atoz=cell(27,26);

for i=1:26
    atoz{1,i}=char(i+64);
end

for i=2:27
    for j=1:26
        atoz{i,j}=[char(i+63),char(j+64)];
    end
end

temp=0;
len_count=0;
col_count=0;

%select all the columns which you need, remember to change the column names to avoid the same name for different columns

s={'queried_ursi','successfully_completed2','V1_BIR_01','V1_BIR_2','V1_BIR_3','V1_BIR_4','V1_BIR_5','V1_BIR_6',...
'V1_BIR_7','V1_BIR_8','V1_BIR_9','V1_BIR_10','V1_BIR_11','V1_BIR_12', 'V1_BIR_13','V1_BIR_14','V1_BIR_15', 'V2_AGE_04'};
[srow,scol]=size(s);
for i=1:scol
    for j=1:xt
         if strcmp(raw{headlines,j},s{1,i}) 
            col_count=col_count+1;
            if rem(col_count,26)==0
                acol=atoz{floor(col_count/26)-1,26};
            else
                acol=atoz{floor(col_count/26)+1,rem(col_count,26)};
            end
            colnumber=sprintf('%s%d',acol,headlines);
            xlwrite([dataDir, 'tmp.xlsx'],raw(headlines:rt,j),'sheet1',colnumber);
            break;
        end
    end
end

readRange={['A1:', acol, num2str(rt)]}

[fnumber,ftxt,fraw]=xlsread([dataDir, 'tmp.xlsx'], char(readRange));
[fr,fc]=size(fnumber);
[frt,fxt]=size(fraw);


%if fs == dels, delete the case
% fs={'V1_BIR_4'};
% dels={30};
% [fsrow,fscol]=size(fs);
% del_count=0;
% for i=1:fscol
%     for j=1:fxt
%         if strcmp(fraw{headlines,j},fs{1,i})
%             for k=(headlines+1):frt
%                 if sum(isnan(fraw{k,j}))||(sum(ischar(dels{1,i})) && strcmp(fraw{k,j},dels{1,i})) || (~sum(ischar(dels{1,i})) && sum((fraw{k,j}==dels{1,i})))                        
%                     if del_count==0
%                         del_count=del_count+1;
%                         delrow(del_count)= k;
%                     else
%                         for m=1:del_count
%                             if ~ismember(k,delrow)
%                                 del_count=del_count+1;
%                                 delrow(del_count)=k;
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end

%if fs2 ~= dels2, delete the case
fs2={'successfully_completed2'};
dels2={'Y'};
[fsrow,fscol]=size(fs2);
del_count=0;
for i=1:fscol
    for j=1:fxt
        if strcmp(fraw{headlines,j},fs2{1,i})
            for k=(headlines+1):frt
                if sum(isnan(fraw{k,j}))||(sum(ischar(dels2{1,i})) && ~strcmp(fraw{k,j},dels2{1,i})) || (~sum(ischar(dels2{1,i})) && sum((fraw{k,j}~=dels2{1,i})))                        
                    if del_count==0
                        del_count=del_count+1;
                        delrow(del_count)= k;
                    else
                        for m=1:del_count
                            if ~ismember(k,delrow)
                                del_count=del_count+1;
                                delrow(del_count)=k;
                            end
                        end
                    end
                end
            end
        end
    end
end

%if franges is > or < than a range, then delete the case
% franges={'V1_BIR_3','V1_BIR_4'};  
% delranges={100,70};
% [frsrow,frscol]=size(franges);
% for i=1:frscol
%     for j=1:fxt
%         if strcmp(fraw{headlines,j},franges{1,i})
%             for k=(headlines+1):frt
%                 if (sum(isnan(fraw{k,j})))||(sum(ischar(fraw{k,j})))||(~sum(ischar(delranges{1,i})) && (fraw{k,j}<delranges{1,i}))
%                     if del_count==0
%                         del_count=del_count+1;
%                         delrow(del_count)=k;
%                     else
%                         for m=1:del_count
%                             if ~ismember(k,delrow)
%                                 del_count=del_count+1;
%                                 delrow(del_count)=k;
%                             end
%                         end
%                     end
%                 end
%             end
%         end
%     end
% end


delrow=sort(delrow);
cancelwrite=1;
linewrite=0;
for i=1:frt
    if (cancelwrite<=length(delrow)) && (i==delrow(cancelwrite))
        cancelwrite=cancelwrite+1;
    else
        linewrite=linewrite+1;
        str1='A';
        linenumber=sprintf('%s%d',str1,linewrite);
        xlwrite([dataDir, 'organized.xlsx'],fraw(i,:),'master',linenumber);
    end
end

delete([dataDir, 'tmp.xlsx']) 
