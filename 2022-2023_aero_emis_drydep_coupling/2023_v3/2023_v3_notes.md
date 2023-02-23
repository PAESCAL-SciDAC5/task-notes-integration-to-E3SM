
# Code branch

  [`huiwanpnnl/atm/aerosol-process-coupling-202302`](https://github.com/E3SM-Project/v3atm/tree/huiwanpnnl/atm/aerosol-process-coupling-202302) in the [`E3SM-Project/v3atm`](https://github.com/E3SM-Project/v3atm) repo.

# Design document and testing results

  See [webpage](https://acme-climate.atlassian.net/wiki/spaces/NGDAP/pages/3684466689/Aerosol+process+coupling+integration) on E3SM's Confluence.

# PR 

  ADD LINK HERE

----------

# Work log

After considering and exploring several possibilities, I now try to follow Wuyin's suggestion
to 
- create a new branch in the `v3atm` repo off its current master 
(which was sync'ed with E3SM master by Wuyin on 2023-02-17), then 
- cherry-pick my changes made to `NGD_v3atm`.

## 1. Checking out master and creating reference results

```
ssh compy
cd ~/codes/scidac4_int/
git clone --recursive git@github.com:E3SM-Project/v3atm.git v3atm_master_202302
```

Reference simulation `custom-10_1x10_ndays`:

- Script: `~/gitProjects/s5_integration_notes/2022-2023_aero_emis_drydep_coupling/2023_v3/scripts_for_manual_testing/run_0_master.sh`.
- Results: `/compyfs/wanh895/scidac4_int/v3atm_master_202302/master_202302/tests/custom-10_1x10_ndays/run/`


## 2. New branch

```
ssh compy
cd ~/codes/scidac4_int/
git clone --recursive git@github.com:E3SM-Project/v3atm.git v3atm_master_202302_with_clfx_new_imp
cd v3atm_master_202302_with_clfx_new_imp
git checkout -b huiwanpnnl/atm/aerosol-process-coupling-202302
```

Start cherry-picking

```
#-------------
# 1st commit
#-------------
git cherry-pick 256766f98da757509879bacc2a09bb7bdaec5e8e
git log  # check commit message
git commit --amend   # revise commit message

#-------------
# 2nd commit
#-------------
git cherry-pick 316b4246ba57c0b90dc21a937ef12f448d78ec68

# resolve conflicts
vi  components/eam/src/physics/cam/physpkg.F90

# commit
git add components/eam/src/physics/cam/physpkg.F90
git commit  # the old commit message will be automatically loaded

#-------------
# 3rd commit
#-------------
git cherry-pick 6010e78daf0c45397c4fe125acf38141c9cb1e6c
```

Push to origin:

```
git push -u origin huiwanpnnl/atm/aerosol-process-coupling-202302
```

## 3. Manual "Super-BFB" testing of the new branch


Scripts:

- On Compy: `/qfs/people/wanh895/gitProjects/s5_integration_notes/2022-2023_aero_emis_drydep_coupling/2023_v3/scripts_for_manual_testing/`
- On GitHub: see [here](https://github.com/PAESCAL-SciDAC5/task-notes-integration-to-E3SM/tree/main/2022-2023_aero_emis_drydep_coupling/2023_v3/scripts_for_manual_testing).

Run `run_cflx_cpl_opt_1.sh` three times using

- `readonly run='custom-10_1x10_ndays'`
- `readonly run='custom-30_1x10_ndays'`
- `readonly run='custom-10_2x5_ndays'`

Then edit variable `test_dir` in script `check_BFB.bash` and run the script to check the results. The results are

```
c3724469e0e4af3715e0e22dce3dce10  atm_custom-10_1x10_ndays.txt  # master
c3724469e0e4af3715e0e22dce3dce10  atm_custom-10_1x10_ndays.txt  # branch
c3724469e0e4af3715e0e22dce3dce10  atm_custom-10_2x5_ndays.txt   # branch
c3724469e0e4af3715e0e22dce3dce10  atm_custom-30_1x10_ndays.txt  # branch
```

Run `run_cflx_cpl_opt_2.sh` three times using

- `readonly run='custom-10_1x10_ndays'`
- `readonly run='custom-30_1x10_ndays'`
- `readonly run='custom-10_2x5_ndays'`

Then edit variable `test_dir` in script `check_BFB.bash` and run the script to check the results. The results are

```
2deca819b7f9911b64229ee60ce1aed5  atm_custom-10_1x10_ndays.txt
2deca819b7f9911b64229ee60ce1aed5  atm_custom-10_2x5_ndays.txt
2deca819b7f9911b64229ee60ce1aed5  atm_custom-30_1x10_ndays.txt
```

# 4. "Super-BFB" testing using `create_test`

Wuyin, Hui, and Jianfeng met on 2023-02-22 and chose the following stratege:

1. Create a baseline for the `e3sm_atm_developer` test suites using `master`, then run the same test suite using the new branch and compare with the baseline to verify that all tests pass.
2. Add a new test suite `e3sm_atm_stealth` that contains a `ERP` and an `SMS_D` with the new feature turned on. Verify that both tests pass.

Note that step 2 requires 

- defining a new "testmod" (which is named in this case `eam-cflx_cpl_2`), and 
- creating/updating the `e3sm_atm_stealth` test suite in `cime_config/tests.py` and adding the `ERP` and `SMS_D` tests with the string `.eam-cflx_cpl_2` appended.

These are done in commit [4d91f6](https://github.com/E3SM-Project/v3atm/commit/4d91f61a79f71b6b96466abde06ba439c01d1a81).

## 4.1 Stealth feature turned off

Scripts:

- [`1_e3sm_atm_developer_baseline.sh`](./scripts_for_testing_using_CIME/1_e3sm_atm_developer_baseline.sh)
- [`2_e3sm_atm_developer_compare.sh`](./scripts_for_testing_using_CIME/2_e3sm_atm_developer_compare.sh)

Results from the comparison:

```
/compyfs/wanh895/e3sm_scratch/cs.status.20230223_130504_dsz319 | grep BASELINE
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel BASELINE baseline_v3atm_master_202302:
    PASS ERS_D.ne4_oQU240.F2010.compy_intel.eam-hommexx BASELINE baseline_v3atm_master_202302:
    PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 BASELINE baseline_v3atm_master_202302:
    PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 BASELINE baseline_v3atm_master_202302:
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel BASELINE baseline_v3atm_master_202302:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel BASELINE baseline_v3atm_master_202302:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_pg2 BASELINE baseline_v3atm_master_202302:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 BASELINE baseline_v3atm_master_202302:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 BASELINE baseline_v3atm_master_202302:
    PASS SMS_Ln9.ne4_oQU240.F2010.compy_intel.eam-outfrq9s BASELINE baseline_v3atm_master_202302:
    PASS SMS.ne4_oQU240.F2010.compy_intel.eam-cosplite BASELINE baseline_v3atm_master_202302:
    PASS SMS_R_Ld5.ne4_ne4.FSCM-ARM97.compy_intel.eam-scm BASELINE baseline_v3atm_master_202302:
```


## 4.2 Stealth feature turned on

Script: [`3_e3sm_atm_stealth_tests.sh`](./scripts_for_testing_using_CIME/3_e3sm_atm_stealth_tests.sh)

Summary of results:

```
PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 RUN
PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 RUN
test-scheduler took 1537.8152439594269 seconds
```

To see more detailed results, use

```
/compyfs/wanh895/e3sm_scratch/cs.status.20230223_130551_bfgg7l
```
