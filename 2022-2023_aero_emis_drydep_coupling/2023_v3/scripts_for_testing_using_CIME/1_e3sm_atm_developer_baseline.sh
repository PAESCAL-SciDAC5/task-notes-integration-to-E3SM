#! /bin/bash

master_name="v3atm_master_202302"
baseline_name="baseline_"${master_name}

# Go to the cloned E3SM code

cd ~/codes/scidac4_int/${master_name}/

# Run test suite and generate baseline.
#
# By default on Compy, 
#  - the test output will be in /compyfs/${USER}/e3sm_scratch/, and 
#  - the baseline will be copied to /compyfs/e3sm_baselines/intel/${baseline_name}
#
# The --wait flag asks create_test to wait for all tests in the suite to finish 
# and then report the final outcome rather than exit and give the "PEND" status 
# while some tests are still running.

cd cime/scripts/
./create_test e3sm_atm_developer -g -b ${baseline_name} --wait
