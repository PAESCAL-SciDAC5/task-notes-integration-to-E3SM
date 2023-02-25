#! /bin/bash
#======================================================================================
# This script was created in the spirit of performing a "super-BFB" suite of tests
# on a new stealth feature in EAM. It is assumed we will test the latest
# commit on the feature branch against the commit on master that the feature branch
# was based off.
#
# The script will
#  - clone master and the feature branch into local directories, 
#  - run the e3sm_atm_developer test suite with both branch and compare, and then
#  - run a new test suite to exercise the stealth feature.
#
# The script tests the implementation of CondiDiag1.1 on top of commit 860eb7b of 
# the E3SM code, using the supercomputer Compy at PNNL.
#
#  - If you would like to do exactly the same, this script should work out of the box;
#  - If you would like to do the same tests but use a different computer, then
#    ${test_root} needs to be revised.
#
# Caveat: if you use this script in small steps (i.e., by turning the "do_..." switches 
#         on or off and executing the script multiple times), please note that 
#         ${test_id} is used for specifying the location of the cloned codes and 
#         the name of the baseline to be generated/used.
#         So, you might need to choose a new string for ${test_id} OR track down 
#         what was used in previous executions of this script, depending on the 
#         specific situation.
#
# History:
#   Test strategy chosen by Wuyin Lin and Hui Wan, 2023-02
#   First version of script written by Hui Wan, 2023-02.
#======================================================================================

do_fetch_master_code=true
do_fetch_branch_code=true
do_generate_baseline=true
do_compr_to_baseline=true
do_run_new_testsuite=true

#---------------------------------

 readonly test_id=`date "+%Y%m%d-%H%M%S"`      # use a new time tag
#readonly test_id="20230224-100506"            # use an old time tag

# Code to be cloned and tested

readonly code_repo="git@github.com:PAESCAL-SciDAC5/E3SM-fork.git"

readonly branch_shortname="CondiDiag1.1_in_EAMv2p"
readonly branch_longname="huiwanpnnl/atm/"${branch_shortname}

readonly master_hash="860eb7b"

# Test suites to be run

std_testsuite="e3sm_atm_developer"  # Script will do baseline comparison for this suite
new_testsuite="eam_condidiag"       # Script will run this suite w/o baseline comparison

# Local directories

readonly test_root="/compyfs/${USER}/e3sm_scratch/TEST_"${branch_shortname}"_"${test_id}

readonly code_root=${test_root}"/codes/"
readonly branch_code_dir=${branch_shortname}
readonly master_code_dir="master_"${master_hash}

readonly baseline_name="baseline_master_"${master_hash}"_"${test_id}

mkdir -p ${code_root}
echo "Cloned codes can be found in "${code_root}

#---------------------------------
# Clone reference code from repo
#---------------------------------
if [ "${do_fetch_master_code,,}" == "true" ]; then

   cd ${code_root}
   git clone ${code_repo} ${master_code_dir}
     
   # Checkout the commit on master to be used as reference
     
   cd ${master_code_dir}
   git checkout -b "master_"${master_hash} ${master_hash}
   git submodule update --init --recursive

fi

#---------------------------
# Clone test code from repo
#---------------------------
if [ "${do_fetch_branch_code,,}" == "true" ]; then

   cd ${code_root}
   git clone -b ${branch_longname} --recursive ${code_repo} ${branch_code_dir}
     
fi

#----------------------------------------------------------------------
# Run test suite using the reference code and generate results baseline
#----------------------------------------------------------------------
# The test output will be placed in ${test_root} under subdirectories
# with ".G." in their names. The results will also be copied to a subdir 
# named ${baseline_name} in the computer system's baseline area; 
# on Compy, that means 
#   /compyfs/e3sm_baselines/intel/${baseline_name}.
#
# The --wait flag asks create_test to wait for all tests in the suite to finish 
# and then report the final outcome, rather than exit and give the "PEND" status 
# while some tests are still running.

if [ "${do_generate_baseline,,}" == "true" ]; then

   cd ${code_root}/${master_code_dir}/cime/scripts
   ./create_test ${std_testsuite} --generate -b ${baseline_name} --wait --output-root ${test_root}

fi

#----------------------------------------------------------------------
# Run test suite using the test code and compare results with baseline
#----------------------------------------------------------------------
# The test output will be placed in ${test_root} under subdirectories
# with ".C." in their names. The results will be compared to those in 
# the ${baseline_name} subdirectory in the computer system's baseline area; 
# on Compy, that means 
#   /compyfs/e3sm_baselines/intel/${baseline_name}.
#
# The --wait flag asks create_test to wait for all tests in the suite to finish 
# and then report the final outcome, rather than exit and give the "PEND" status 
# while some tests are still running.

if [ "${do_compr_to_baseline,,}" == "true" ]; then

   cd ${code_root}/${branch_code_dir}/cime/scripts
   ./create_test ${std_testsuite} --compare -b ${baseline_name} --wait --output-root ${test_root}

fi

#----------------------------------------------
# Run a new test suite to test the new feature
#----------------------------------------------
if [ "${do_run_new_testsuite,,}" == "true" ]; then

   cd ${code_root}/${branch_code_dir}/cime/scripts
   ./create_test ${new_testsuite} --wait --output-root ${test_root}

fi
