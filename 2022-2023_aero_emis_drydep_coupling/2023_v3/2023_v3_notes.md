
# Code branch

  [`huiwanpnnl/atm/aerosol-process-coupling-202302`](https://github.com/E3SM-Project/v3atm/tree/huiwanpnnl/atm/aerosol-process-coupling-202302) in the [`E3SM-Project/v3atm` repo](https://github.com/E3SM-Project/v3atm)

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

## Checking out master and create baseline results

```
ssh compy
cd ~/codes/scidac4_int/
git clone --recursive git@github.com:E3SM-Project/v3atm.git v3atm_master_202302
```

Reference simulation `custom-10_1x10_ndays`:

- Script: `~/gitProjects/s5_integration_notes/2022-2023_aero_emis_drydep_coupling/2023_v3/scripts_for_manual_testing/run_0_master.sh`.
- Results: `/compyfs/wanh895/scidac4_int/v3atm_master_202302/master_202302/tests/custom-10_1x10_ndays/run/`


## New branch

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

Push to origin
```
git push -u origin huiwanpnnl/atm/aerosol-process-coupling-202302
```

## "Super-BFB" testing of the new branch

### Manual testing

Script dir: `/qfs/people/wanh895/gitProjects/s5_integration_notes/2022-2023_aero_emis_drydep_coupling/2023_v3/scripts_for_manual_testing/`

Run `run_cflx_cpl_opt_1.sh` 3 times using
- `readonly run='custom-10_1x10_ndays'`
- `readonly run='custom-30_1x10_ndays'`
- `readonly run='custom-10_2x5_ndays'`

Then use script `check_BFB.bash` to check results:
```
c3724469e0e4af3715e0e22dce3dce10  atm_custom-10_1x10_ndays.txt  # master
c3724469e0e4af3715e0e22dce3dce10  atm_custom-10_1x10_ndays.txt  # branch
c3724469e0e4af3715e0e22dce3dce10  atm_custom-10_2x5_ndays.txt   # branch
c3724469e0e4af3715e0e22dce3dce10  atm_custom-30_1x10_ndays.txt  # branch
```

Run `run_cflx_cpl_opt_2.sh` 3 times using
- `readonly run='custom-10_1x10_ndays'`
- `readonly run='custom-30_1x10_ndays'`
- `readonly run='custom-10_2x5_ndays'`

Then use script `check_BFB.bash` to check results:
```
2deca819b7f9911b64229ee60ce1aed5  atm_custom-10_1x10_ndays.txt
2deca819b7f9911b64229ee60ce1aed5  atm_custom-10_2x5_ndays.txt
2deca819b7f9911b64229ee60ce1aed5  atm_custom-30_1x10_ndays.txt
```

