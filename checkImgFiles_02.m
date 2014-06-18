clear
clc

subListFile='/home/data/Projects/BIRD/data/combinedSubList.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
subList=cell2mat(subList{1})

t=0;
q=0;
for i=1:length(subList)
    sub=subList(i, 1:9);
    file1=['/home/data/Incoming/DiscSci/NIFTI/BOLD/', char(sub), '/REST_645.nii.gz'];
    
    file2=['/home/data/Incoming/DiscSciR4/mmilham/NIFTI/', char(sub), '/Study30-001/REST_645.nii.gz'];
    if exist(file1, 'file') || exist(file2, 'file')
        t=t+1;
    else
        
        q=q+1;
        subMissing(q,:)=sub;
    end
end
