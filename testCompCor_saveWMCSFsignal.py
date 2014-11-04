
import nibabel as nb
import numpy as np
import scipy
from scipy import signal

# Paths and options

subjectList = np.loadtxt("/home/data/Projects/Zhen/BIRD/data/final110sub.txt", dtype=str)
#subjectList = ['M10996445', 'M10902019']

wm_cor_allSub = []
csf_cor_allSub = []


for subject in subjectList:
    print subject
    csf_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/csf_signals.npy" % subject
    wm_sig_file="/home/data/Projects/Zhen/BIRD/results/working/resting_preproc_%s/nuisance_0/_scan_rest_rest_645/_csf_threshold_0.96/_gm_threshold_0.7/_wm_threshold_0.96/tissue_masks/wm_signals.npy" % subject
      
    wm_sigs = np.load(wm_sig_file)
    csf_sigs = np.load(csf_sig_file)
    
    # Generate global,wm,csf time-series
   
    wm_ts = wm_sigs.mean(0)
    csf_ts = csf_sigs.mean(0)

    wmcsf_sigs = np.vstack((wm_sigs, csf_sigs))

    outFile = "/home/data/Projects/Zhen/BIRD/testCompCor/newCode/wmCSF_%s.csv" % subject
    np.savetxt(outFile, wmcsf_sigs, delimiter=",")


