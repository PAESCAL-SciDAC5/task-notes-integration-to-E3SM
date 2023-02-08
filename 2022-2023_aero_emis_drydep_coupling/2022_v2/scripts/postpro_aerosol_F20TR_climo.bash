#!/bin/bash -fe

#--------------------------------------------------------------------------
# Notes by Hui Wan @PNNL, July-August 2022:
#
# This simple script is based on Chris Terai's advice from 7/20/2022.
#
# We load the E3SM Unified environment on Compy, 
# then use zppy to process years 1985-2014 of an AMIP simulation and 
# compare the mean climate agaist the observations and the CMIP6 model ensemble.
#  
# The .cfg file for box plot and Taylor diagram was adapted from a template provided by Qi Tang and Jill Zhang from LLNL.
# The .cfg file for more diags was adapted from Chris Terai's example.
#-----------------------------------------------------------------------------
 

source /share/apps/E3SM/conda_envs/load_e3sm_unified_1.6.0_compy.sh
zppy -c	zppy.post.20220519.v2.LR.bi-grid.amip.cflx_cpl_opt_2.compy.model_vs_obs_1985-2014_box_plot_and_Taylor.cfg
zppy -c zppy.post.20220519.v2.LR.bi-grid.amip.cflx_cpl_opt_2.compy.model_vs_obs_1985-2014_more_diags.cfg
