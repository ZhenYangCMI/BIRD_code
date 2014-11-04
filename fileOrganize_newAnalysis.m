clear
clc

subListFile='/home/data/Projects/Zhen/BIRD/data/tmp.txt';
subList1=fopen(subListFile);
subList=textscan(subList1, '%s', 'delimiter', '\n')
subList=cell2mat(subList{1});
numSub=length(subList)

funImgName='dsc_1_rest_645';

% orgnize the CPAC processed data.

%covTypeList={'noGSR', 'compCor'};
covTypeList={'noGSR'};

for j=1:length(covTypeList)
    covType=char(covTypeList{j})
    
    destinationDir=['/home/data/Projects/Zhen/BIRD/results/newAnalysis/identifyFeatureOn86Sub/', covType, '/'];
    
    if strcmp(covType, 'compCor')
        pipeline='_compcor_ncomponents_5_selector_pc10.linear1.wm0.global0.motion1.quadratic1.gm0.compcor1.csf0';
    elseif strcmp(covType, 'noGSR')
        pipeline='_compcor_ncomponents_5_selector_pc10.linear1.wm1.global0.motion1.quadratic1.gm0.compcor0.csf1';
    elseif strcmp(covType, 'GSR')
        pipeline='_compcor_ncomponents_5_selector_pc10.linear1.wm1.global1.motion1.quadratic1.gm0.compcor0.csf1';
    end
    
    mkdir ([destinationDir, 'T1Img'])
    mkdir ([destinationDir, 'FunImg'])
    mkdir ([destinationDir, 'ReHo'])
    mkdir ([destinationDir, 'VMHC'])
    mkdir ([destinationDir, 'fALFF'])
    %mkdir ([destinationDir, 'DegreeCentrality'])
    mkdir ([destinationDir, 'DualRegression'])
    
    t=0;
    missingSub=[];
    for i=1:numSub
        sub=subList(i, 1:9);
        disp(['Working on ', sub])
        
        subDir=['/data2/rockland_sample_preprocessing/rest_645_preproc/output/pipeline_rockland_sample_rest_645/', sub];
             
 if ~strcmp(sub, 'M10945411') &&  ~strcmp(sub, 'M10955568')  % these two subjects missing the wm+csf output         
        if exist(subDir, 'dir')
            
            anat=[subDir, '/mni_normalized_anatomical/ants_deformed.nii.gz'];
            anat2MNIAffine=[subDir, '/ants_affine_xfm/ants_Affine.txt']; % anat to mni
            anat2MNIWarp=[subDir, '/anatomical_to_mni_nonlinear_xfm/ants_Warp.nii.gz'];
            
            % change the path and file name according to the fun image file
            % name
            fun2anatAffine=['/data2/rockland_sample_preprocessing/rest_645_preproc/working/resting_preproc_', sub, '/_scan_', funImgName, '/fsl_reg_2_itk_0/affine.txt'];
            
            funNative=[subDir, '/functional_freq_filtered/_scan_', funImgName, '/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/', pipeline, '/_bandpass_freqs_0.01.0.1/bandpassed_demeaned_filtered.nii.gz'];
            fun=[subDir, '/functional_mni/_scan_', funImgName, '/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/', pipeline, '/_bandpass_freqs_0.01.0.1/bandpassed_demeaned_filtered_wtsimt.nii.gz'];  % functional already in MNI space, only need to smooth and resample before run CWAS
            meanFun=[subDir, '/mean_functional_in_mni/_scan_', funImgName, '/rest_645_calc_resample_volreg_calc_tstat_wimt.nii.gz']; % mean funImg in MNI
            standFunMask=[subDir, '/functional_brain_mask_to_standard/_scan_', funImgName, '/rest_645_calc_resample_volreg_brain_mask_ero_wimt.nii.gz'];
            
            ReHo=[subDir, '/reho_to_standard_smooth/_scan_', funImgName, '/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/', pipeline, '/_bandpass_freqs_0.01.0.1/_fwhm_6/ReHo_wimt_maths.nii.gz'];
            VMHC=[subDir, '/vmhc_z_score/_scan_', funImgName, '/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/', pipeline, '/_bandpass_freqs_0.01.0.1/_fwhm_6/bandpassed_demeaned_filtered_maths_wtsimt_tcorr_calc.nii.gz'];
            fALFF=[subDir, '/falff_to_standard_smooth/_scan_', funImgName, '/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/', pipeline, '/_hp_0.01/_lp_0.1/_fwhm_6/rest_645_calc_resample_volreg_brain_mask_ero_calc_wimt_maths.nii.gz'];
            DegreeCentrality=['/data2/rockland_sample_preprocessing/rest_645_preproc/output/pipeline_rockland_sample_rest_645/', sub, '/centrality_outputs/_scan_', funImgName, '/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/', pipeline, '/_bandpass_freqs_0.01.0.1/_mask_MNI152_T1_3mm_brain_mask/degree_centrality_binarize.nii.gz'];
            DualRegression=[subDir, '/dr_tempreg_maps_stack/_scan_', funImgName, '/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/', pipeline, '/_bandpass_freqs_0.01.0.1/_spatial_map_PNAS_Smith_rsn_ten/temp_reg_map.nii.gz'];
            %
            
            copyfile(anat, [destinationDir, 'T1Img/normT1_', sub, '.nii.gz'])
            copyfile(anat2MNIAffine, [destinationDir, 'T1Img/anat2MNIAffine_', sub, '.txt'])
            copyfile(anat2MNIWarp, [destinationDir, 'T1Img/anat2MNIWarp_', sub, '.nii.gz'])
            copyfile(fun2anatAffine, [destinationDir, 'T1Img/fun2anatAffine_', sub, '.txt'])
            %
            copyfile(funNative, [destinationDir, 'FunImg/FunImg_', sub, '.nii.gz'])
            copyfile(fun, [destinationDir, 'FunImg/normFunImg_', sub, '.nii.gz'])
            copyfile(meanFun, [destinationDir, 'FunImg/normMeanFun_', sub, '.nii.gz'])
            copyfile(standFunMask, [destinationDir, 'FunImg/standFunMask_', sub, '.nii.gz'])
            copyfile(ReHo, [destinationDir, 'ReHo/ReHo_', sub, '.nii.gz'])
            copyfile(VMHC, [destinationDir, 'VMHC/VMHC_', sub, '.nii.gz'])
            copyfile(fALFF, [destinationDir, 'fALFF/fALFF_', sub, '.nii.gz'])
            %copyfile(DegreeCentrality, [destinationDir, 'DegreeCentrality/DegreeCentrality_', sub, '.nii.gz'])
            copyfile(DualRegression, [destinationDir, 'DualRegression/DualRegression_', sub, '.nii.gz'])
%             
        else
            t=t+1;
            disp (['sub ', sub, 'dose not exist.'])
            missingSub{t,1}=sub;
        end
        end
    end
end


