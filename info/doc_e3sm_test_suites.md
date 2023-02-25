
# Introduction

CIME test suites are collections of individual tests defined in [`cime_config/tests.py`](https://github.com/E3SM-Project/E3SM/blob/master/cime_config/tests.py). Test suites allow the use of a single command like
```
./created_test ${SUITE_NAME}
```
to run multiple tests without having to issue one `create_test` command for each test.

# Test suite examples

```
    "e3sm_atm_developer" : {
        "inherit" : ("eam_theta_pg2"),
        "tests"   : (
            "ERP_Ln18.ne4_oQU240.F2010",
            "SMS_Ln9.ne4_oQU240.F2010.eam-outfrq9s",
            "SMS.ne4_oQU240.F2010.eam-cosplite",
            "SMS_R_Ld5.ne4_ne4.FSCM-ARM97.eam-scm",
            "SMS_D_Ln5.ne4_oQU240.F2010",
            "SMS_Ln5.ne4pg2_oQU480.F2010",
            "ERS_D.ne4_oQU240.F2010.eam-hommexx"
            )
        },
```

```
    "eam_theta_pg2" : {
        "share"    : True,
        "time"     : "02:00:00",
        "tests"    : (
                 "SMS_Ln5.ne4pg2_oQU480.F2010.eam-thetahy_pg2",
                 "SMS_Ln5.ne4pg2_oQU480.F2010.eam-thetahy_sl_pg2",
                 "ERS_Ld3.ne4pg2_oQU480.F2010.eam-thetahy_sl_pg2",
                 "SMS_Ln5.ne4pg2_oQU480.F2010.eam-thetahy_sl_pg2_ftype0",
                 "ERS_Ld3.ne4pg2_oQU480.F2010.eam-thetahy_sl_pg2_ftype0",
                 )
    },
```

## Testmods

Note that the `.eam-...` strings occuring after compset names are the so-called "testmods", which specify namelist changes or `xmlchange` commands needed for the tests, see [explanation here](doc_testmods.md).

## Test suite usage

To run the `e3sm_atm_developer` suite and compare results with a baseline named `master` stored in the computer system's baseline area (e.g., `/compyfs/e3sm_baselines/${COMPILER}` on compy), use

```
cd ${CODE_ROOT}/cime/scripts
./create_test e3sm_atm_developer --compare -b master
```

## The "super-BFB" test suite

The "super-BFB" test suite is still being developed by the E3SM team. Here is [a sample script](../2022-2023_CondiDiag/2023_v2p/scripts/cime_tests/cime_tests_CondiDiag.sh) we developed for PAESCAL before an official method is announced.

