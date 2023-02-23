
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

# 4. "Super-BFB" testing using CIME's `create_test` command

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

(Note that the `--wait` flag was used in the script linked above to ask `create_test` to wait for tests to finish and report the final outcome shown below rather than give the "PEND" status since some tests are still running.)

```
Waiting for tests to finish
PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/ERP_Ln18.ne4_oQU240.F2010.compy_intel.C.20230223_105511_e5gfvy
PASS ERS_D.ne4_oQU240.F2010.compy_intel.eam-hommexx RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/ERS_D.ne4_oQU240.F2010.compy_intel.eam-hommexx.C.20230223_105511_e5gfvy
PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2.C.20230223_105511_e5gfvy
PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0.C.20230223_105511_e5gfvy
PASS SMS.ne4_oQU240.F2010.compy_intel.eam-cosplite RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS.ne4_oQU240.F2010.compy_intel.eam-cosplite.C.20230223_105511_e5gfvy
PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.C.20230223_105511_e5gfvy
PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.C.20230223_105511_e5gfvy
PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_pg2 RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_pg2.C.20230223_105511_e5gfvy
PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2.C.20230223_105511_e5gfvy
PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0.C.20230223_105511_e5gfvy
PASS SMS_Ln9.ne4_oQU240.F2010.compy_intel.eam-outfrq9s RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS_Ln9.ne4_oQU240.F2010.compy_intel.eam-outfrq9s.C.20230223_105511_e5gfvy
PASS SMS_R_Ld5.ne4_ne4.FSCM-ARM97.compy_intel.eam-scm RUN
    Case dir: /compyfs/wanh895/e3sm_scratch/SMS_R_Ld5.ne4_ne4.FSCM-ARM97.compy_intel.eam-scm.C.20230223_105511_e5gfvy
test-scheduler took 1846.777936220169 seconds
```

To see more details of the test results, use

```
cd /compyfs/wanh895/e3sm_scratch
./cs.status.20230223_105511_e5gfvy
```


## 4.2 Stealth feature turned on

Script: [`3_e3sm_atm_stealth_tests.sh`](./scripts_for_testing_using_CIME/3_e3sm_atm_stealth_tests.sh)

Results:

```
  ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 (Overall: PASS) details:
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 CREATE_NEWCASE
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 XML
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SETUP
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SHAREDLIB_BUILD time=765
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 MODEL_BUILD time=1077
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SUBMIT
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 RUN time=134
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 COMPARE_base_rest
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 MEMLEAK insuffiencient data for memleak test
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SHORT_TERM_ARCHIVER
  SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 (Overall: PASS) details:
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 CREATE_NEWCASE
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 XML
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SETUP
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SHAREDLIB_BUILD time=469
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 MODEL_BUILD time=289
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SUBMIT
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 RUN time=92
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 MEMLEAK insuffiencient data for memleak test
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-cflx_cpl_2 SHORT_TERM_ARCHIVER
```
