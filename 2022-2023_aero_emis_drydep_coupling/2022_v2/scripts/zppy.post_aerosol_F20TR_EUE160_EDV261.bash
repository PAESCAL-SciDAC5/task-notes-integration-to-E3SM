#!/bin/bash -fe

#--------------------------------------------------------------------------
# Notes by Hui Wan @PNNL, July-August 2022:
#
# This simple script is based on Chris Terai's advice from 7/20/2022.
#
# We load the E3SM Unified environment on Compy, 
# then use zppy to process years 1985-2014 of an AMIP simulation.
#-----------------------------------------------------------------------------
 
source /share/apps/E3SM/conda_envs/load_e3sm_unified_1.6.0_compy.sh
zppy -c zppy.post.F20TR.1985-2014_EUE160_EDV261.cfg
