
# Introduction

CIME test suites are collections of individual tests defined in [`cime_config/tests.py`](https://github.com/E3SM-Project/E3SM/blob/master/cime_config/tests.py). We can use a single command
```
./created_test ${SUITE_NAME}
```
to run the entire collection without having to issue one `create_test` command for each test.

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

Note that the `.eam-...` strings occuring after the compset names are the so-called "testmods" used for specifying namelist changes or `xmlchange` commands needed for the tests, see [explanation here](doc_testmods.md).

## The "super-BFB" test suite


