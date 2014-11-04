import nibabel as nb
import numpy as np
import matplotlib.pyplot as plt
import scipy
from scipy import signal

# Paths and options

#subjectList = np.loadtxt("/home/data/Projects/Zhen/BIRD/data/final110sub.txt", dtype=str)
#cor_tissueSig_allSub = []
subjectList = ["M10914047"]
print subjectList

for subject in subjectList:
    print subject
    csf_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/csf_signals.npy" % subject
    wm_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/wm_signals.npy" % subject
    gm_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/gm_signals.npy" % subject
    data_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/func_preproc_0/_scan_rest_rest_645/func_normalize/REST_645_calc_resample_volreg_calc_maths.nii.gz" % subject
    
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

    x = range(0,900,1)
    plt.plot(x, global_ts, '-b', label='global')
    plt.plot(x, wm_ts, '-r', label='wm')
    #plt.plot(x, csf_ts, '-k', label='csf')
    plt.plot(x, gm_ts, '-c', label='gm')
   
    plt.show()
    #plt.savefig('test.png')


    # Compute similarities
    global_wm = np.corrcoef(global_ts.T, wm_ts.T)[0,1:]
    global_csf = np.corrcoef(global_ts.T, csf_ts.T)[0,1:]
    global_gm = np.corrcoef(global_ts.T, gm_ts.T)[0,1:]
    wm_csf = np.corrcoef(wm_ts.T, csf_ts.T)[0,1:]
    wm_gm=np.corrcoef(wm_ts.T, gm_ts.T)[0,1:]
    csf_gm=np.corrcoef(csf_ts.T, gm_ts.T)[0,1:]
    all_cor=np.hstack((global_wm, global_csf, global_gm, wm_csf, wm_gm, csf_gm))

# save the correlation for all subjects
    cor_tissueSig_allSub.append(all_cor)
    print cor_tissueSig_allSub
    # write the correlations for all subjects as a csv file
#np.savetxt("/home/data/Projects/Zhen/BIRD/testCompCor/cor_tissueSig_allSub.csv", cor_tissueSig_allSub, delimiter=",")


