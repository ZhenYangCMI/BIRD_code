

preprocessDate='2_22_14'

for covType in noGSR; do

# full/path/to/site/subject_list
subject_list=/home/data/Projects/Colibazzi/data/subClean_step2_98sub.txt

### 2. smooth the normalized derivatives

	#for measure in ReHo fALFF DualRegression DegreeCentrality skewness; do
for measure in DegreeCentrality ; do
	dataDir=/home/data/Projects/Colibazzi/results/CPAC_zy${preprocessDate}_reorganized/${covType}/${measure}

		for sub in `cat $subject_list`; do

			echo --------------------------
			echo running subject ${sub}
			echo --------------------------

			cd ${dataDir}
			if [[ ${measure} = "skewness" ]]; then
			3dmerge -1blur_fwhm 6.0 -doall -prefix ${measure}_${sub}_MNI_fwhm6.nii ${measure}_${sub}_MNI.nii
			elif [[ ${measure} = "DegreeCentrality" ]]; then
			3dmerge -1blur_fwhm 8.0 -doall -prefix ${measure}_${sub}_MNI_fwhm8.nii ${measure}_${sub}.nii.gz
			else
			3dmerge -1blur_fwhm 6.0 -doall -prefix ${measure}_${sub}_MNI_fwhm6.nii ${measure}_${sub}_MNI.nii.gz
			fi

		done
	done
done


