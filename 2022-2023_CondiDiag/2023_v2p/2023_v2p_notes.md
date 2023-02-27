# Code

Branch [huiwanpnnl/atm/CondiDiag1.1_in_EAMv2p](https://github.com/PAESCAL-SciDAC5/E3SM-fork/tree/huiwanpnnl/atm/CondiDiag1.1_in_EAMv2p) in PAESCAL's [E3SM fork](https://github.com/PAESCAL-SciDAC5/E3SM-fork).

# Desing document

See [webpage](https://acme-climate.atlassian.net/wiki/spaces/NGDAP/pages/3691741185/CondiDiag1.1+integration) on E3SM's Confluence.

# PR

ADD LINK HERER

---

# Work log

## 1. Porting the code

### 1.1 CondiDiag1.0

(Commit: [51a100a](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/51a100a80e0f6a2d957c32ada835e1d371e84b37))

**Core contents**

- Add namelist variables in `components/eam/bld/namelist_files/namelist_definition.xml`

- Copy from a 202205 port the subdir `components/eam/src/physics/cam/`:
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

**Checkpoints and dummy arguments**

- `components/eam/src/physics/cam/physpkg.F90`
- `components/eam/src/physics/cam/clubb_intr.F90`

**Restart**

- `components/eam/src/physics/cam/restart_physics.F90`
- `components/eam/src/control/cam_restart.F90`
- `components/eam/src/control/cam_comp.F90`

**Miscellaneous**

- `components/eam/src/control/cam_history_support.F90`:
   - increase value of parameter `fieldname_len` from 24 to 34.
- `components/eam/src/control/runtime_opts.F90`:
   - add `call cnd_diag_readnl(nlfilename)`

**Testing**

  Run and postprocess the 3 use case examples in the CondiDiag1.0 paper,
  plus a simple CAPE budget analysis (without decomposition).
  Run scripts and postprocessing scripts can be found in the [scripts directory](./scripts/use_cases/).

### 1.2 Porting the Dec-2022 bug fix for branch runs

(Commit: [17876ba](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/17876ba3b940aa011e37b62a66143fb88f89ce6d))

This is to make sure the simulation won't abort if a user requests new CondiDiag output when doing a branch run.

### 1.3 Porting dCAPE decomposition

**Preparation**

  To be on the safe side, 
  - change `dcapemx` in `zm_conv.F90` from a module variable to a local variable or a dummy argument; 
  - add intent(in/out/inout) for various dummy arguments of `buoyan_dilute`.

(Commits: [4967d24](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/4967d241491a68165e3dd8cd03e3bba3b7b63cb9) and [2917987](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/2917987e4c4dc516d9576bda754f1a096bf0cb60))

**Xiaoliang's method of decomposing dCAPE**

   - dCAPE  = CAPE( new parcel, new environment ) - CAPE( old parcel, old environment )
   - dCAPEp = CAPE( new parcel, new environment ) - CAPE( old parcel, new environment )
   - dCAPEe = CAPE( old parcel, new environment ) - CAPE( old parcel, old environment )

   The dCAPE calculation and decomposition is calculated in subroutine `compute_cape_diags` in `components/eam/src/physics/cam/misc_diagnostics.F90`.
   
   (Last commit: [1afac6a](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/1afac6afb4cf60d9f6f742100e98aa25456175d6))
   
**Testing**

  Do a 1-month run and write out monthly and daily averages. The run script and postprocessing script can be found in [`scripts/user_cases/dCAPE_decomp/`](scripts/use_cases/dCAPE_decomp/). 

# 2. "Super-BFB" testing

## 2.1 Our method

Wuyin, Hui, and Jianfeng met on 2023-02-22 and chose the following strategy:

1. Create a baseline for the `e3sm_atm_developer` test suites using `master`, then run the same test suite using the feature branch and compare with the baseline to verify that all tests pass.
2. Add a new test suite `eam_condidiag` that contains some `ERP` and `SMS_D` tests with the new feature turned on. Verify that all tests pass.

Note that step 2 requires 

- defining new "testmods" that turn on CondiDiag, and 
- creating an `eam_condidiag` test suite in `cime_config/tests.py`.

These are done in commits 
[d1ad6c6](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/d1ad6c6d5633a2875fd2fddeebe452b080ca6eb4) and
[2868de3](https://github.com/PAESCAL-SciDAC5/E3SM-fork/commit/2868de3ccfd55b8d2e80ff8969e5293bbf882feb).

The `eam_condidiag` test suite is defined as

```
    "eam_condidiag" : {
        "tests"   : (
            "SMS_D_Ln5.ne4_oQU240.F2010",
            "SMS_D_Ln5.ne4_oQU240.F2010.eam-condidiag_dcape",
            "ERP_Ld3.ne4_oQU240.F2010.eam-condidiag_dcape",
            "ERP_Ld3.ne4_oQU240.F2010.eam-condidiag_rhi",
            )
        },
```

- Results of the two `SMS_D` tests can be manaully compared for the global statistics in `atm.log` to verify that turning on CondiDiag does not change the simulation results.
- `ERP...eam-condidiag_dcape` exercises CondiDiag's dCAPE decomposition capability. This test might fail if the `buoyan_dilute` subroutine in the ZM deep convection parameterization has been changed but the `compute_cape_diags` subroutine in CondiDiag is not updated accordingly.
- `ERP_...eam-condidiag_rhi` exercises both the budget analysis and conditional sampling capabilities in CondiDiag.

## 2.2 Our script

The script [`cime_tests_CondiDiag.sh`](scripts/cime_tests/cime_tests_CondiDiag.sh) clones `master` and the feature branch, then do the tests described above.


## 2.3 Test results with the feature turned off

Commands for checking the results of comparison with baseline:

```
cd /compyfs/wanh895/e3sm_scratch/TEST_CondiDiag1.1_in_EAMv2p_20230226-184544/
./cs.status.20230226_193344_9otkrz | grep BASELINE
```

Results:

```
    PASS ERP_Ln18.ne4_oQU240.F2010.compy_intel BASELINE baseline_master_860eb7b_20230226-184544:
    PASS ERS_D.ne4_oQU240.F2010.compy_intel.eam-hommexx BASELINE baseline_master_860eb7b_20230226-184544:
    PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 BASELINE baseline_master_860eb7b_20230226-184544:
    PASS ERS_Ld3.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS_D_Ln5.ne4_oQU240.F2010.compy_intel BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_pg2 BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2 BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS_Ln5.ne4pg2_oQU480.F2010.compy_intel.eam-thetahy_sl_pg2_ftype0 BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS_Ln9.ne4_oQU240.F2010.compy_intel.eam-outfrq9s BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS.ne4_oQU240.F2010.compy_intel.eam-cosplite BASELINE baseline_master_860eb7b_20230226-184544:
    PASS SMS_R_Ld5.ne4_ne4.FSCM-ARM97.compy_intel.eam-scm BASELINE baseline_master_860eb7b_20230226-184544:
```


## 2.4 Test results with the feature turned on

Commands:

```
cd /compyfs/wanh895/e3sm_scratch/TEST_CondiDiag1.1_in_EAMv2p_20230226-184544/
./cs.status.20230226_200056_a1j9zl | grep Overall
```

Summary of results:

```
  ERP_Ld3.ne4_oQU240.F2010.compy_intel.eam-condidiag_dcape (Overall: PASS) details:
  ERP_Ld3.ne4_oQU240.F2010.compy_intel.eam-condidiag_rhi (Overall: PASS) details:
  SMS_D_Ln5.ne4_oQU240.F2010.compy_intel (Overall: PASS) details:
  SMS_D_Ln5.ne4_oQU240.F2010.compy_intel.eam-condidiag_dcape (Overall: PASS) details:
```

Global statistics from the two `SMS_D` tests:

```
 nstep, te        6   0.25849911590488310E+10   0.25849847059015503E+10  -0.89220353777641015E-04   0.98518592706630399E+05
 nstep, te        6   0.25849911590488310E+10   0.25849847059015503E+10  -0.89220353777641015E-04   0.98518592706630399E+05
```
