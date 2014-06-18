# generate subfilePath and mask the data with the CWAS mask

smooth=6
preprocessDate=1_24_14
subList="/home/data/Projects/BIRD/data/final110sub.txt" 

## 1. resample and smooth the functional data 
mkdir /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/FunImg_3mm_fwhm${smooth}
outputDir="/home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/FunImg_3mm_fwhm${smooth}"
echo $outputDir
sublistFile="/home/data/Projects/BIRD/data/subFunImgFilePath_110sub.txt"
rm -rf $sublistFile
for sub in `cat $subList`; do

3dresample -dxyz 3.0 3.0 3.0 -prefix ${outputDir}/normFunImg_${sub}_3mm.nii -inset /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/FunImg/normFunImg_${sub}.nii.gz
3dmerge -1blur_fwhm 6.0 -doall -prefix ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii ${outputDir}/normFunImg_${sub}_3mm.nii 
3dcalc -a ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii -b /home2/data/Projects/workingMemory/mask/MNI152_T1_GREY_3mm_25pc_mask.nii.gz -expr 'a*b' -prefix ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii
rm -rf ${outputDir}/normFunImg_${sub}_3mm.nii ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii
done

## 2. create the subject data path file
for sub in `cat $subList`; do
echo "${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii" >> $sublistFile
done


## 3. create the group mask
for sub in `cat $subList`; do

cmd="fslmaths ${outputDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii -Tstd -bin /home/data/Projects/BIRD/mask/CWAS/stdMask_${sub}"
echo $cmd
eval $cmd

done

numSub=110
subList="/home/data/Projects/BIRD/data/final${numSub}sub.txt" 
maskDir="/home/data/Projects/BIRD/mask"
subIncludedList=${maskDir}/tmp_subIncludedList.txt
rm -rf $subIncludedList

for sub in `cat $subList`; do
echo "${maskDir}/CWAS_900TRs/stdMask_${sub}.nii.gz" >> $subIncludedList
done
a=$(cat $subIncludedList)

cmd1="3dMean -prefix ${maskDir}/stdMask_${numSub}sub_compCor.nii.gz $a"
echo $cmd1
eval $cmd1

3dcalc -a /home/data/Projects/BIRD/mask/stdMask_${numSub}sub_compCor.nii.gz -expr 'step(a-0.99999)' -prefix /home/data/Projects/BIRD/mask/stdMask_${numSub}sub_compCor_100prct.nii.gz

rm -rf $subIncludedList
# This may give you an empty mask
#3dcalc -a /home/data/Projects/BIRD/mask/stdMask_110sub_compCor.nii.gz -expr 'equals(a,1)' -prefix /home/data/Projects/BIRD/mask/stdMask_110sub_compCor_100prct.nii.gz

#3dcalc -a /home/data/Projects/workingMemory/mask/CPACpreprocessing/CWAS_${covType}/stdMask_68sub.nii -expr 'step(a-0.899)' -prefix /home/data/Projects/workingMemory/mask/CPACpreprocessing/CWAS_${covType}/stdMask_68sub_90percent.nii

