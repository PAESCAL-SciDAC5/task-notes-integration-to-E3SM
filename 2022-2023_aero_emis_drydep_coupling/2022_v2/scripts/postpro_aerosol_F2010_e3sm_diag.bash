#!/bin/bash


# Running on compy 

#SBATCH  --job-name=d_aerosol
#SBATCH  --account=esmd
#SBATCH  --nodes=1
#SBATCH  --output=aerosol_F2010_e3sm_diag.o%j
#SBATCH  --exclusive
#SBATCH  --time=02:00:00
#SBATCH  --qos=regular
#SBATCH  --partition=slurm
###SBATCH  --partition=short


# Load E3SM unified environment for compy
source /share/apps/E3SM/conda_envs/load_latest_e3sm_unified_compy.sh

# Cases and paths 

readonly CASE_GROUP="v2.LR.SciDAC4-PNNL"
readonly www="/compyfs/www/${USER}/E3SM/${CASE_GROUP}"

readonly CASE_CTRL="baseline_4b21b5_F2010"
readonly CASE_TEST="aerosol_F2010"

readonly SHORTNAME_CTRL="Baseline"
readonly SHORTNAME_TEST="Aerosol_process_coupling"

readonly CLIMO_DIR_CTRL="/compyfs/${USER}/scidac4_int/master/${CASE_CTRL}/climo"
readonly CLIMO_DIR_TEST="/compyfs/${USER}/scidac4_int/aerosol/${CASE_TEST}/climo"


Y1="2010"
Y2="2014"

ref_Y1="2010"
ref_Y2="2014"

run_type="model_vs_model"
tag="${SHORTNAME_TEST}_vs_${CASE_CTRL}"
results_dir=${tag}_${Y1}-${Y2}

# To load custom E3SM Diags environment, comment out line above using 
# and uncomment lines below

#module load anaconda3/2019.03
#source /share/apps/anaconda3/2019.03/etc/profile.d/conda.sh
#conda activate e3sm_diags_env_dev

# Turn on debug output if needed
debug=False
if [[ "${debug,,}" == "true" ]]; then
  set -x
fi

# Make sure UVCDAT doesn't prompt us about anonymous logging
export UVCDAT_ANONYMOUS_LOG=False

# Script dir
cd .

# Get jobid
id=${SLURM_JOBID}

# Update status file
STARTTIME=$(date +%s)
echo "RUNNING ${id}" > e3sm_diag_${tag}.status

# Create temporary workdir
workdir=`mktemp -d tmp.${id}.XXXX`
cd ${workdir}

# Create local links to input climo files (test model)
mkdir -p climo_test
cd climo_test
cp -s ${CLIMO_DIR_TEST}/${CASE_TEST}_*_${Y1}??_${Y2}??_climo.nc .
cd ..

# Create local links to input climo files (ref model)
mkdir -p climo_ref
cd climo_ref
cp -s ${CLIMO_DIR_CTRL}/${CASE_CTRL}_*_${ref_Y1}??_${ref_Y2}??_climo.nc .
cd ..

# Run E3SM Diags
echo
echo ===== RUN E3SM DIAGS model_vs_model =====
echo

# Prepare configuration file
cat > e3sm.py << EOF
import os
import numpy
from e3sm_diags.parameter.core_parameter import CoreParameter
from e3sm_diags.run import runner

param = CoreParameter()

# Model
param.test_data_path = 'climo_test'
param.test_name = '${CASE_TEST}'
param.short_test_name = '${SHORTNAME_TEST}'

# Reference
param.reference_data_path = 'climo_ref'
param.ref_name = '${CASE_CTRL}'
param.short_ref_name = '${SHORTNAME_CTRL}'

# Output dir
param.results_dir = '${results_dir}'

# Additional settings
param.run_type = 'model_vs_model'
param.diff_title = 'Difference'
param.output_format = ['png']
param.output_format_subplot = ['pdf']
param.multiprocessing = True
param.num_workers = 24

# Optionally, swap test and reference model
if False:
    param.test_data_path, param.reference_data_path = param.reference_data_path, param.test_data_path
    param.test_name, param.ref_name = param.ref_name, param.test_name
    param.short_test_name, param.short_ref_name = param.short_ref_name, param.short_test_name

# Run
runner.sets_to_run = ['lat_lon', 'zonal_mean_xy', 'zonal_mean_2d', 'polar', 'cosp_histogram', 'meridional_mean_2d']
runner.run_diags([param])

EOF

# Run diagnostics
time python e3sm.py
if [ $? != 0 ]; then
  cd ..
  echo 'ERROR (1)' > e3sm_diag_${tag}.status
  exit 1
fi

# Copy output to web server
echo
echo ===== COPY FILES TO WEB SERVER =====
echo

# Create top-level directory
f=${www}/${tag}/e3sm_diags/180x360_aave
mkdir -p ${f}
if [ $? != 0 ]; then
  cd ..
  echo 'ERROR (2)' > e3sm_diag_${tag}.status
  exit 1
fi



# Copy files
rsync -a --delete ${results_dir} ${www}/${tag}/e3sm_diags/180x360_aave/
if [ $? != 0 ]; then
  cd ..
  echo 'ERROR (3)' > e3sm_diag_${tag}.status
  exit 1
fi



# Delete temporary workdir
cd ..
if [[ "${debug,,}" != "true" ]]; then
  rm -rf ${workdir}
fi

# Update status file and exit

ENDTIME=$(date +%s)
ELAPSEDTIME=$(($ENDTIME - $STARTTIME))

echo ==============================================
echo "Elapsed time: $ELAPSEDTIME seconds"
echo ==============================================
echo 'OK' > e3sm_diag_${tag}.status
exit 0
