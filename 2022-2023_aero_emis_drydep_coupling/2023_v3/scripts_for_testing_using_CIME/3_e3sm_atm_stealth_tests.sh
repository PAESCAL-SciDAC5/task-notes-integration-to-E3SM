#! /bin/bash

branch_dir="v3atm_master_202302_with_clfx_new_imp"

# Go to the cloned E3SM code
cd ~/codes/scidac4_int/${branch_dir}/

# Run test suite 
cd cime/scripts/
./create_test e3sm_atm_stealth --wait
