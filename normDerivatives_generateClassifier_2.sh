


for covType in noGSR; do

# full/path/to/site/subject_list
subject_list=/home/data/Projects/Zhen/BIRD/generalizeClassifier/data/65AdultsWithBIRDAndImg_final.txt

### 1. spatial normalize the derivatives
standard_template=/home/data/Projects/Zhen/commonCode/MNI152_T1_3mm_brain.nii.gz
anatDir=/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/${covType}/T1Img

	#for measure in ReHo fALFF DualRegression skewness; do
for measure in DualRegression; do
	dataDir=/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/${covType}/${measure}

		for sub in `cat $subject_list`; do

			echo --------------------------
			echo running subject ${sub}
			echo --------------------------

			# Applywarp
			cd ${dataDir}

			if [[ ${measure} = "skewness" ]]; then
			WarpTimeSeriesImageMultiTransform 4 ${measure}_${sub}.nii ${measure}_${sub}_MNI.nii -R ${standard_template} ${anatDir}/anat2MNIWarp_${sub}.nii.gz ${anatDir}/anat2MNIAffine_${sub}.txt ${anatDir}/fun2anatAffine_${sub}.txt
			else
			WarpTimeSeriesImageMultiTransform 4 ${measure}_${sub}.nii.gz ${measure}_${sub}_MNI.nii.gz -R ${standard_template} ${anatDir}/anat2MNIWarp_${sub}.nii.gz ${anatDir}/anat2MNIAffine_${sub}.txt ${anatDir}/fun2anatAffine_${sub}.txt
			fi

		done
	done
done


### 2. smooth the normalized derivatives
covType=noGSR
subject_list=/home/data/Projects/Zhen/BIRD/generalizeClassifier/data/65AdultsWithBIRDAndImg_final.txt

#for measure in ReHo fALFF DualRegression DegreeCentrality skewness; do
for measure in DualRegression DegreeCentrality ; do
	dataDir=/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/${covType}/${measure}

		for sub in `cat $subject_list`; do

			echo --------------------------
			echo running subject ${sub}
			echo --------------------------

			cd ${dataDir}
			if [[ ${measure} = "skewness" ]]; then
			3dmerge -1blur_fwhm 6.0 -doall -prefix ${measure}_${sub}_MNI_fwhm6.nii ${measure}_${sub}_MNI.nii
			elif [[ ${measure} = "DegreeCentrality" ]]; then
			3dmerge -1blur_fwhm 6.0 -doall -prefix ${measure}_${sub}_MNI_fwhm6.nii ${measure}_${sub}.nii.gz
			else
			3dmerge -1blur_fwhm 6.0 -doall -prefix ${measure}_${sub}_MNI_fwhm6.nii ${measure}_${sub}_MNI.nii.gz
			fi

		done
done

### 3. resample DC and DR results to 2mm to be consistent with previous analysis. Note that this is still different from previous analysis which the DC and DR registration and calculation is in 2mm
subject_list=/home/data/Projects/Zhen/BIRD/generalizeClassifier/data/65AdultsWithBIRDAndImg_final.txt

for measure in DualRegression DegreeCentrality ; do 
    for sub in `cat $subject_list`; do
    3dresample -master /home/data/Projects/Zhen/commonCode/MNI152_T1_2mm_brain.nii.gz -prefix /home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/noGSR/${measure}/${measure}_${sub}_MNI_fwhm6_2mm.nii -inset /home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/noGSR/${measure}/${measure}_${sub}_MNI_fwhm6.nii
    done
done


### 4. split the dual regression and reorgnize the files 

subject_list=/home/data/Projects/Zhen/BIRD/generalizeClassifier/data/65AdultsWithBIRDAndImg_final.txt
for covType in noGSR; do

dataDir=/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/${covType}/DualRegression

	for sub in `cat $subject_list`; do

		echo --------------------------
		echo running subject ${sub}
		echo ---------------------
		cd ${dataDir}
		fslsplit DualRegression_${sub}_MNI_fwhm6_2mm.nii DualRegression_${sub}_MNI_fwhm6_

		for comp in 0 1 2 3 4 5 6 7 8 9; do
			mkdir -p /home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/${covType}/DualRegression${comp}
			3dcalc -a DualRegression_${sub}_MNI_fwhm6_000${comp}.nii.gz -expr 'a' -prefix /home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/${covType}/DualRegression${comp}/DualRegression${comp}_${sub}_MNI_fwhm6.nii
		done
	done
done




### 5. CWAS setup
smooth=6
subject_list=/home/data/Projects/Zhen/BIRD/generalizeClassifier/data/65AdultsWithBIRDAndImg_final.txt
standard_template=/home/data/Projects/Zhen/commonCode/MNI152_T1_3mm_brain.nii.gz
anatDir=/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/compCor/T1Img
dataDir=/home/data/Projects/Zhen/BIRD/generalizeClassifier/outPut/compCor/FunImg
	
for sub in `cat $subject_list`; do

	echo --------------------------
	echo running subject ${sub}
	echo --------------------------

	# Applywarp
	cd ${dataDir}

	WarpTimeSeriesImageMultiTransform 4 FunImg_${sub}.nii.gz normFunImg_${sub}_3mm.nii.gz -R ${standard_template} ${anatDir}/anat2MNIWarp_${sub}.nii.gz ${anatDir}/anat2MNIAffine_${sub}.txt ${anatDir}/fun2anatAffine_${sub}.txt
	3dmerge -1blur_fwhm 6.0 -doall -prefix ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii.gz ${dataDir}/normFunImg_${sub}_3mm.nii.gz 
	3dcalc -a ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}.nii.gz -b /home/data/Projects/Zhen/commonCode/MNI152_T1_GREY_3mm_25pc_mask.nii.gz -expr 'a*b' -prefix ${dataDir}/normFunImg_${sub}_3mm_fwhm${smooth}_masked.nii.gz
	3dcalc -a ${dataDir}/normFunImg_${sub}_3mm.nii.gz -b /home/data/Projects/Zhen/commonCode/MNI152_T1_GREY_3mm_25pc_mask.nii.gz -expr 'a*b' -prefix ${dataDir}/normFunImg_${sub}_3mm_masked.nii.gz
done

