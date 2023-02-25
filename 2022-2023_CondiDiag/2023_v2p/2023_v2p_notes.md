# 1. Porting CondiDiag1.0


### 1.1 Core contents

- Add namelist variables in `components/eam/bld/namelist_files/namelist_definition.xml`

- Copy from 202205 port, subdir `components/eam/src/physics/cam/`
  - `conditional_diag.F90`
  - `conditional_diag_main.F90`
  - `conditional_diag_output_utils.F90`
  - `conditional_diag_restart.F90`
  - `misc_diagnostics.F90`

- Make sure the number of allowed checkpoints are set to the same large value of 250 at the following places:
  - `conditional_diag.F90`
     - `integer, parameter :: nchkpt_max       = 250`
  - `namelist_definition.xml`
     - `<entry id="qoi_chkpt" type="char*10(250)"  category="history"`
     - `<entry id="chkpt_x_dp" type="integer(250)"  category="history"` 

- Make `buoyan_dilute` and `limcnv` public in `zm_conv.F90`

### 1.2 Checkpoints and dummy arguments

- `components/eam/src/physics/cam/physpkg.F90`
- `components/eam/src/physics/cam/clubb_intr.F90`

### 1.3 Restart

- `components/eam/src/physics/cam/restart_physics.F90`
- `components/eam/src/control/cam_restart.F90`
- `components/eam/src/control/cam_comp.F90`

### 1.4 Misc

- `components/eam/src/control/cam_history_support.F90`:
   - increase value of parameter `fieldname_len` from 24 to 34.
- `components/eam/src/control/runtime_opts.F90`:
   - add `call cnd_diag_readnl(nlfilename)`

### 1.5 Testing

  Run and postprocess the 3 use case examples in the CondiDiag1.0 paper,
  plus a simple CAPE budget analysis (without decomposition).
  Run scripts and postprocessing scripts can be found in the [scripts directory](./scripts/).

# 3. Porting Dec-2022 bug fix for branch runs

This is to make sure the simulation won't abort if a user requests new CondiDiag output when doing a branch run.

# 4. Porting dCAPE decomposition

## 4.0 Preparation

  To be on the safe side, 
  - change `dcapemx` in `zm_conv.F90` from a module variable to a local variable or a dummy argument; 
  - add intent(in/out/inout) for various dummy arguments of `buoyan_dilute`.

## 4.1 Xiaoliang's method of decomposing dCAPE

   - dCAPE  = CAPE( new parcel, new environment ) - CAPE( old parcel, old environment )
   - dCAPEp = CAPE( new parcel, new environment ) - CAPE( old parcel, new environment )
   - dCAPEe = CAPE( old parcel, new environment ) - CAPE( old parcel, old environment )

   The dCAPE calculation and decomposition is calculated in subroutine `compute_cape_diags` in `components/eam/src/physics/cam/misc_diagnostics.F90`.
   
## 4.2 Testing 

  The run script and postprocessing script can be found in [`scripts/dCAPE_decomp/`](scripts/dCAPE_decomp/). Sample run produces a 1-month average.

# 5. "Super-BFB" testing

## 5.1 Our method

Wuyin, Hui, and Jianfeng met on 2023-02-22 and chose the following stratege:

1. Create a baseline for the `e3sm_atm_developer` test suites using `master`, then run the same test suite using the new branch and compare with the baseline to verify that all tests pass.
2. Add a new test suite `eam_condidiag` that contains a few `ERP` and `SMS_D` tests with the new feature turned on. Verify that all tests pass.

Note that step 2 requires 

- defining new "testmods" that turn on CondiDiag, and 
- creating a `eam_condidiag` test suite in `cime_config/tests.py`.

These are done in commit [d1ad6c](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/d1ad6c6d5633a2875fd2fddeebe452b080ca6eb4).

Here is how the new test suite looks like:

```
    "eam_condidiag" : {
        "tests"   : (
            "SMS_D_Ln5.ne4_oQU240.F2010.eam-condidiag_dcape",
            "ERP_Ld3.ne4_oQU240.F2010.eam-condidiag_dcape",
            "ERP_Ld3.ne4_oQU240.F2010.eam-condidiag_rhi",
            )
        },
```

## 5.2 Our script

[`cime_tests_CondiDiag.sh`](scripts/cime_tests/cime_tests_CondiDiag.sh)

## 5.3 Test results with the stealth feature turned off

Commands for checking the outcome of comparison with baseline:

```
cd /compyfs/wanh895/e3sm_scratch/TEST_CondiDiag1.1_20230224-100506
./cs.status.20230224_111134_1ssykv | grep BASELINE
```

Results:

```
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel BASELINE baseline_master_860eb7b_20230224-100506:
    PASS ERS_D.ne4_oQU240.F2010.compy_intel.eam-hommexx BASELINE baseline_master_860eb7b_20230224-100506:
    PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 BASELINE baseline_master_860eb7b_20230224-100506:
    PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_pg2 BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS_Ln9.ne4_oQU240.F2010.compy_intel.eam-outfrq9s BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS.ne4_oQU240.F2010.compy_intel.eam-cosplite BASELINE baseline_master_860eb7b_20230224-100506:
    PASS SMS_R_Ld5.ne4_ne4.FSCM-ARM97.compy_intel.eam-scm BASELINE baseline_master_860eb7b_20230224-100506:
```


## 4.4 Test results with the stealth feature turned on

Commands:

```
cd /compyfs/wanh895/e3sm_scratch/TEST_CondiDiag1.1_20230224-100506
./cs.status.20230224_114641_gnfqd6 | grep Overall
```

Summary of results:

```
  ERP_Ld3.ne4_oQU240.F2010.compy_intel.eam-condidiag_dcape (Overall: PASS) details:
  ERP_Ld3.ne4_oQU240.F2010.compy_intel.eam-condidiag_rhi (Overall: PASS) details:
  SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-condidiag_dcape (Overall: PASS) details:
```
