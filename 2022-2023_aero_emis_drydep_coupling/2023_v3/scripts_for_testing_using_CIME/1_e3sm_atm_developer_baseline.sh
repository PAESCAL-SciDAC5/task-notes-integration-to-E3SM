#! /bin/bash

master_name="v3atm_master_202302"
baseline_name="baseline_"${master_name}

# Go to the cloned E3SM code
cd ~/codes/scidac4_int/${master_name}/

# Run test suite and generate baseline
cd cime/scripts/
./create_test e3sm_atm_developer \
              --generate --baseline-name ${baseline_name} \
              --baseline-root /compyfs/${UESER}/e3sm_scratch/${baseline_name} \
              --wait
