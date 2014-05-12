
smooth=6
NRtype=compcor
subList="/home/data/Projects/Zhen/BIRD/data/final110sub.txt"
dataDir="/home/data/Projects/Zhen/BIRD/results/CPAC_zy1_24_14_reorganized/${NRtype}/FunImgCWAS"
maskDir="/home/data/Projects/Zhen/BIRD/mask/CWASMask_${NRtype}"
preprocessDate='1_24_14'


## 3. create filepath for all subject
sublistFile="/home/data/Projects/Zhen/BIRD/data/subCWASFunImgFilePath_110sub_${NRtype}.txt"
rm -rf $sublistFile
for sub in `cat $subList`; do
echo "${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii.gz" >> $sublistFile 
done
