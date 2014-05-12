
preprocessDate=1_24_14
subList="/home/data/Projects/BIRD/data/final110sub.txt" 

# create DC mask
cmd4="3dMean -prefix /home/data/Projects/BIRD/mask/meanStandFunMask_110sub.nii.gz /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/noGSR/FunImg/standFunMask_*.nii.gz"
echo $cmd4
eval $cmd4

3dcalc -a /home/data/Projects/BIRD/mask/meanStandFunMask_110sub.nii.gz -expr 'step(a-0.899)' -prefix /home/data/Projects/BIRD/mask/meanStandFunMask_110sub_90pct.nii.gz


preprocessDate=1_24_14
subList="/home/data/Projects/BIRD/data/final110sub.txt" 

for sub in `cat $subList`; do

3dcalc -a /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/FunImg_3mm_fwhm6_900TRs/normFunImg_${sub}_3mm_fwhm6_masked.nii[16..899] -expr 'a' -prefix /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/compCor/FunImg_3mm_fwhm6_884TRs/normFunImg_${sub}_3mm_fwhm6_masked.nii -datum float
#3dresample -dxyz 3.0 3.0 3.0 -prefix /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/noGSR/FunImg_3mm/normFunImg_${sub}_3mm.nii -inset /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/noGSR/FunImg/normFunImg_${sub}.nii.gz

done

preprocessDate=1_24_14
subList="/home/data/Projects/BIRD/data/final110sub.txt" 

for sub in `cat $subList`; do
3dcalc -a /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/noGSR/DegreeCentrality/DegreeCentrality_${sub}_MNI_fwhm6.nii.gz -expr 'a' -prefix /home/data/Projects/BIRD/results/CPAC_zy1_24_14_reorganized/noGSR/DegreeCentrality/DegreeCentrality_${sub}_MNI_fwhm6.nii
done


ata

3dcalc -a PNAS_Smith09_rsn10.nii[0] -b PNAS_Smith09_rsn10.nii[1] -c PNAS_Smith09_rsn10.nii[2] -d PNAS_Smith09_rsn10.nii[3] -e PNAS_Smith09_rsn10.nii[6] -f PNAS_Smith09_rsn10.nii[7] -g PNAS_Smith09_rsn10.nii[8] -expr 'step(a-3)*(-4)+step(b-3)*(-3)+step(c-3)*(-2)+step(d-3)*(-1)+step(e-3)+step(f-3)*2+step(g-3)*3' -prefix PNAS_Smith09_7ICNcmb.nii.gz


3dcalc -a PNAS_Smith09_rsn10.nii[0] -d PNAS_Smith09_rsn10.nii[3] -e PNAS_Smith09_rsn10.nii[6] -f PNAS_Smith09_rsn10.nii[7] -g PNAS_Smith09_rsn10.nii[8] -expr 'step(a-3)*(-2)+step(d-3)*(-1)+step(e-3)+step(f-3)*2+step(g-3)*3' -prefix PNAS_Smith09_5ICNcmb.nii.gz


3dcalc -a /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_DualRegression0_T2_Z_neg.nii.gz -b /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_DualRegression3_T2_Z_pos.nii.gz -c /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_DualRegression6_T2_Z_pos.nii.gz -d /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_DualRegression7_T2_Z_pos.nii.gz -e /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_DualRegression8_T2_Z_pos.nii.gz -expr 'equals(a,1)*(-2)+equals(b, 1)*(-1)+equals(c, 2)+equals(d, 1)*2+equals(e, 1)*3' -prefix /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_DualRegression_predictors.nii.gz


3dcalc -a /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWASME_ROI1_T1_Z_neg.nii.gz -b /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWASME_ROI2_T1_Z_neg.nii.gz -c /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWASME_ROI3_T1_Z_neg.nii.gz -d /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWASME_ROI3_T1_Z_pos.nii.gz -e /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWASME_ROI3_T1_Z_pos.nii.gz -f /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWASME_ROI4_T1_Z_neg.nii.gz -expr 'equals(a,1)*(-2)+equals(b, 3)*(-1)+equals(c, 2)+equals(d, 1)+equals(e, 3)+equals(f, 1)*2' -prefix /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWAS-iFC_predictors.nii.gz

3dcalc -a /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWAS-iFC_predictors.nii.gz -b /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWASME_ROI3_T1_Z_pos.nii.gz -expr 'a+equals(b,3)' -prefix /home/data/Projects/Zhen/BIRD/mask/ROImasksME/cluster_mask_CWAS-iFC_predictors_new.nii.gz

