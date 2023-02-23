#! /bin/bash

master_name="v3atm_master_202302"
baseline_name="baseline_"${master_name}

branch_dir="v3atm_master_202302_with_clfx_new_imp"

# Go to the cloned E3SM code
cd ~/codes/scidac4_int/${branch_dir}/

# Run test suite and compare with baseline.
#
# By default on Compy, 
#  - the test output will be in /compyfs/${USER}/e3sm_scratch/, and 
#  - the baseline are read from /compyfs/e3sm_baselines/intel/${baseline_name}
#
# The --wait flag asks create_test to wait for all tests in the suite to finish 
# and then report the final outcome rather than exit and give the "PEND" status 
# while some tests are still running.


cd cime/scripts/
./create_test e3sm_atm_developer -c -b ${baseline_name} --wait
