
#--------------------------------------------------------------------
# Baseline (before my change)
test_dir="/compyfs/wanh895/scidac4_int/v3atm_master_202302/master_202302/tests/"

# After implementing cflx_cpl_opt = 1, 2 ; default (cflx_cpl_opt = 1)
#test_dir="/compyfs/wanh895/scidac4_int/v3atm_master_202302_with_clfx_new_imp/cflx_opt_1_202302/tests/"

#----------------------------------------------------------------------
## After implementing cflx_cpl_opt = 1, 2 ; setting cflx_cpl_opt = 2
#------
## test_dir=""
#------

cd $test_dir
for test in custom*_*_ndays
do
  gunzip -c ${test}/run/atm.log.*.gz | grep '^ nstep, te ' | uniq > atm_${test}.txt
done

md5sum atm_*_ndays.txt
