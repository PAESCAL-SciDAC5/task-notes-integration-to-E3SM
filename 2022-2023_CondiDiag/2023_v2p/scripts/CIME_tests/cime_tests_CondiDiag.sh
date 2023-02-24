#! /bin/bash
#======================================================================================
# This script was created in the spirit of performing a "super-BFB" suite of tests
# to verify a new stealth feature in EAM. It is assumed we will test the latest
# commit on the corresponding feature branch against the commit on master that the
# feature branch is based off.
#
# The script will
#  - clone the master commit and the branch into local directories, 
#  - run the e3sm_atm_developer test suite with both code versions and compare them, then
#  - run a new test suite to exercise the new feature implemented on the branch.
#
# This specific script tests the CondiDiag1.1 code implemented on top of commit 860eb7b 
# of the E3SM code. If you are attempting to repeat that action, then the script
# should work out of the box.
#
# History:
#   Test strategy chosen by Wuyin Lin and Hui Wan, 2023-02
#   First version of the script written by Hui Wan, 2023-02.
#======================================================================================

do_fetch_master_code=true
do_fetch_branch_code=true
do_generate_baseline=true
do_compr_to_baseline=true
do_run_new_testsuite=true

readonly code_root=${HOME}"/codes/CondiDiag1.1_test-"`date "+%Y%m%d-%H%M%S"`
readonly code_repo="git@github.com:PAESCAL-SciDAC5/E3SM-fork.git"

readonly master_hash="860eb7b"
readonly master_name="master_"${master_hash}
readonly baseline_name=${master_name}

readonly branch_dir="CondiDiag1.1_in_EAMv2p"
readonly branch="huiwanpnnl/atm/"${branch_dir}

mkdir -p ${code_root}
echo "Codes will be cloned into "${code_root}

#---------------------------------
# Clone baseline code from repo
#---------------------------------
if [ "${do_fetch_master_code,,}" == "true" ]; then

   cd ${code_root}
   git clone ${code_repo} ${master_name}
     
   # Checkout the master hash to be used as reference
     
   cd ${master_name}
   git checkout -b ${master_name} ${master_hash}
   git submodule update --init --recursive

fi

#---------------------------
# Clone test code from repo
#---------------------------
if [ "${do_fetch_branch_code,,}" == "true" ]; then

   cd ${code_root}
   git clone -b ${branch} --recursive ${code_repo} ${branch_dir}
     
fi

#----------------------------------------------------------------------
# Run test suite using the baseline code and generate baseline results
#----------------------------------------------------------------------
if [ "${do_generate_baseline,,}" == "true" ]; then

   cd ${code_root}/${master_name}/cime/scripts
   ./create_test e3sm_atm_developer -g -b ${baseline_name} --wait

fi

#----------------------------------------------------------------------
# Run test suite using the test code and compare results with baseline
#----------------------------------------------------------------------
if [ "${do_compr_to_baseline,,}" == "true" ]; then

   cd ${code_root}/${branch_dir}/cime/scripts
   ./create_test e3sm_atm_developer -c -b ${baseline_name} --wait

fi

#----------------------------------------------
# Run a new test suite to test the new feature
#----------------------------------------------
if [ "${do_run_new_testsuite,,}" == "true" ]; then

   cd ${code_root}/${branch_dir}/cime/scripts
   ./create_test eam_condidiag --wait

fi
