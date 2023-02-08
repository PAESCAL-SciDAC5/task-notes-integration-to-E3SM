#!/bin/bash


# Running on compy 

#SBATCH  --job-name=p_aerosol
#SBATCH  --account=esmd
#SBATCH  --nodes=4
#SBATCH  --output=aerosol_climo.o%j
#SBATCH  --exclusive
#SBATCH  --time=02:00:00
#SBATCH  --qos=regular
#SBATCH  --partition=slurm
####SBATCH  --partition=short


# Load E3SM unified environment for compy
source /share/apps/E3SM/conda_envs/load_latest_e3sm_unified_compy.sh

# Paths

readonly CHECKOUT="aerosol"
readonly CASE_NAME="aerosol_F2010"
readonly CASE_ROOT="/compyfs/${USER}/scidac4_int/${CHECKOUT}/${CASE_NAME}"
readonly CASE_RUN_DIR=${CASE_ROOT}/run
readonly YEAR_START=2010
readonly YEAR_END=2014

# Turn on debug output if needed
debug=false
debug=true
if [[ "${debug,,}" == "true" ]]; then
  set -x
fi

# Script dir
cd .

# Get jobid
id=${SLURM_JOBID}

# Update status file
STARTTIME=$(date +%s)
echo "RUNNING ${id}" > climo.status

# Create temporary workdir
workdir=`mktemp -d tmp.${id}.XXXX`
cd ${workdir}

# Generate climo files
ncclimo -n '-x' -v ANRAIN,ANSNOW,AQRAIN,AQSNOW \
--no_amwg_link \
-p mpi \
-a sdd \
-c ${CASE_NAME} \
-s ${YEAR_START} -e ${YEAR_END} \
-i ${CASE_RUN_DIR} \
-r /qfs/people/zender/data/maps/map_ne30pg2_to_cmip6_180x360_aave.20200201.nc \
-o clim \
-O clim_rgr \
-m eam


if [ $? != 0 ]; then
  cd ..
  echo 'ERROR (1)' >> climo.status
  exit 1
fi

# Move regridded climo files to final destination
{
  dest=${CASE_ROOT}/climo
  mkdir -p ${dest}
  mv clim_rgr/*.nc ${dest}
}
if [ $? != 0 ]; then
  cd ..
  echo 'ERROR (2)' >> climo.status
  exit 2
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
echo 'OK' >> climo.status
exit 0
