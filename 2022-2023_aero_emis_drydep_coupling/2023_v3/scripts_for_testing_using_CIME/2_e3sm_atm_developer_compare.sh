#! /bin/bash

master_name="v3atm_master_202302"
baseline_name="baseline_"${master_name}

branch_dir="v3atm_master_202302_with_clfx_new_imp"

# Go to the cloned E3SM code
cd ~/codes/scidac4_int/${branch_dir}/

# Run test suite and generate baseline
cd cime/scripts/
./create_test e3sm_atm_developer \
              --compare --baseline-name ${baseline_name} \
              --baseline-root /compyfs/${UESER}/e3sm_scratch/ \
              --wait
