
smooth=6
subList="/home/data/Projects/Zhen/BIRD/data/final61_86sub.txt"
dataDir="/home/data/Projects/Zhen/BIRD/results/newAnalysis/identifyFeatureOn86Sub/compCor/FunImg"
maskDir="/home/data/Projects/Zhen/BIRD/mask/CWASMask_compCor_NewAnalysis"

## 1. spatial normalize the derivatives
standard_template=/home/data/Projects/Zhen/commonCode/MNI152_T1_3mm_brain.nii.gz
anatDir=/home/data/Projects/Zhen/BIRD/results/newAnalysis/identifyFeatureOn86Sub/compCor/T1Img
greyMatterMask=/home/data/Projects/Zhen/commonCode/MNI152_T1_GREY_3mm_25pc_mask.nii.gz

	
for sub in `cat $subList`; do

	echo --------------------------
	echo running subject ${sub}
	echo --------------------------

	# Applywarp
	cd ${dataDir}

	WarpTimeSeriesImageMultiTransform 4 FunImg_${sub}.nii.gz normFunImg_${sub}_3mm.nii.gz -R ${standard_template} ${anatDir}/anat2MNIWarp_${sub}.nii.gz ${anatDir}/anat2MNIAffine_${sub}.txt ${anatDir}/fun2anatAffine_${sub}.txt
	3dmerge -1blur_fwhm 6.0 -doall -prefix ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii.gz ${dataDir}/normFunImg_${sub}_3mm.nii.gz 
	3dcalc -a ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii.gz -b ${greyMatterMask} -expr 'a*b' -prefix ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii.gz
	3dcalc -a ${dataDir}/normFunImg_${sub}_3mm.nii.gz -b ${greyMatterMask} -expr 'a*b' -prefix ${dataDir}/normFunImg_${sub}_3mm_masked.nii.gz
done


## 2. create the group mask
for sub in `cat $subList`; do

cmd1="fslmaths ${dataDir}/normFunImg_${sub}_3mm_masked.nii.gz -Tstd -bin ${maskDir}/stdMask_${sub}_3mm"
echo $cmd1
eval $cmd1
done

subIncludedList="subIncludedList.txt"
for sub in `cat $subList`; do
echo "${maskDir}/stdMask_${sub}_3mm.nii.gz" >> $subIncludedList
done

a=$(cat $subIncludedList)

cmd1="3dMean -prefix ${maskDir}/stdMask_86sub_3mm_compCor.nii.gz $a"
echo $cmd1
eval $cmd1

3dcalc -a ${maskDir}/stdMask_86sub_3mm_compCor.nii.gz -expr 'step(a-0.99999)' -prefix ${maskDir}/stdMask_86sub_3mm_compCor_100prct.nii.gz

rm -rf $subIncludedList

## 3. create filepath for all subject
sublistFile="/home/data/Projects/Zhen/BIRD/data/subCWASFunImgFilePath_86sub.txt"
rm -rf $sublistFile
for sub in `cat $subList`; do
echo "${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii.gz" >> $sublistFile 
done
