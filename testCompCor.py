from CPAC.nuisance import calc_compcor_components
import nibabel as nb
import numpy as np
import scipy
from scipy import signal

# Paths and options

subjectList = np.loadtxt("/home/data/Projects/Zhen/BIRD/data/final110sub.txt", dtype=str)
#subjectList = ['M10996445', 'M10902019']
#subjectList = ['M10996582']
global_cor_allSub = []
wm_cor_allSub = []
csf_cor_allSub = []
gm_cor_allSub = []

for subject in subjectList:
    print subject
    csf_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/csf_signals.npy" % subject
    wm_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/wm_signals.npy" % subject
    gm_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/gm_signals.npy" % subject
    data_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/func_preproc_0/_scan_rest_rest_645/func_normalize/REST_645_calc_resample_volreg_calc_maths.nii.gz" % subject
    nComponents=5
    #motion_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/fristons_parameter_model_0/_scan_rest_rest_645/calc_friston/fristons_twenty_four.1D" % subject
    # Load data, wm, csf
    nii = nb.load(data_file)
    data = nii.get_data().astype(np.float64)
    
    global_mask = (data != 0).sum(-1) != 0
    wm_sigs = np.load(wm_sig_file)
    csf_sigs = np.load(csf_sig_file)
    gm_sigs = np.load(gm_sig_file)

    # Generate global,wm,csf time-series
    global_ts = data[global_mask].mean(0)
    wm_ts = wm_sigs.mean(0)
    csf_ts = csf_sigs.mean(0)
    gm_ts = gm_sigs.mean(0)

    # detrend the tissue signal
    global_ts = scipy.signal.detrend(global_ts, type='linear')  
    wm_ts = scipy.signal.detrend(wm_ts, type='linear')  
    csf_ts_ts = scipy.signal.detrend(csf_ts, type='linear')  
    gm_ts = scipy.signal.detrend(gm_ts, type='linear')  


    # Calculate CompCor
    #comps = calc_compcor_components(data, nComponents, wm_sigs, csf_sigs)
    wmcsf_sigs = np.vstack((wm_sigs, csf_sigs))

    # 1. detrending for each voxel across time
    print 'Detrending and centering data'
    Y = scipy.signal.detrend(wmcsf_sigs, axis=1, type='linear').T
    
    # 2. remove the voxels with zero variance
    Y_std=Y.std(0)
    std_shape=np.shape(Y_std)
    t=0
    index=[]
    for x in range(0,std_shape[0]-1):
        if Y_std[x] == 0:
            index.append(x)
            t=t+1
            #print 'deleting from Y, column %d' % x
    print t
    print index
    Y = np.delete(Y,index,1)  
     
    # 3. demean and variance normalization     
    Yc = Y - np.tile(np.array(Y.mean(0)).reshape(1,Y.shape[1]), (Y.shape[0],1))
    #Yc = Yc / np.tile(np.array(Y.std(0)).reshape(1,Y.shape[1]), (Y.shape[0],1))

    # 4. svd
    print 'Calculating SVD decomposition of Y*Y\''
    U, S, Vh = np.linalg.svd(np.dot(Yc, Yc.T))
    comps = U[:,:nComponents]  
    compFile = "/home/data/Projects/Zhen/BIRD/testCompCor/newCode/compsOnlyDemean_%s.csv" % subject
    np.savetxt(compFile, comps, delimiter=",")

    # Compute similarities
    global_cor = np.corrcoef(global_ts.T, comps.T)[0,1:]
    wm_cor = np.corrcoef(wm_ts.T, comps.T)[0,1:]
    csf_cor = np.corrcoef(csf_ts.T, comps.T)[0,1:]
    gm_cor = np.corrcoef(gm_ts.T, comps.T)[0,1:]

    # Save the correlation for all subjects
    global_cor_allSub.append(global_cor)
    wm_cor_allSub.append(wm_cor)
    csf_cor_allSub.append(csf_cor)
    gm_cor_allSub.append(gm_cor)

    # write the correlations for all subjects as a csv file
#np.savetxt("/home/data/Projects/Zhen/BIRD/testCompCor/newCode/globalDetrend_5PC.csv", global_cor_allSub, delimiter=",")
#np.savetxt("/home/data/Projects/Zhen/BIRD/testCompCor/newCode/wmDetrend_5PC.csv", wm_cor_allSub, delimiter=",")
#np.savetxt("/home/data/Projects/Zhen/BIRD/testCompCor/newCode/csfDetrend_5PC.csv", csf_cor_allSub, delimiter=",")
#np.savetxt("/home/data/Projects/Zhen/BIRD/testCompCor/newCode/gmDetrend_5PC.csv", gm_cor_allSub, delimiter=",")

#np.savetxt("/home/data/Projects/Zhen/BIRD/testCompCor/newCode/wmcsfsigs_M109.csv", wmcsf_sigs, delimiter=",")

# Load everything
#everything = np.loadtxt("/data/Projects/CoRR/preproc/working/resting_preproc_0003056_session_1/nuisance_0/_scan_rest_1_rest/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/_compcor_ncomponents_5_selector_pc10.linear1.wm0.global0.motion1.quadratic0.gm0.compcor1.csf0/residuals/motion_compcor_constant_linear.csv")


