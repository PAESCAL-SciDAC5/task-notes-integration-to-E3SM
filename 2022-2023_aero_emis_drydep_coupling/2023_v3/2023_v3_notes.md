
# Code branch

  [git push -u origin huiwanpnnl/atm/aerosol-process-coupling-202302](https://github.com/E3SM-Project/v3atm/tree/huiwanpnnl/atm/aerosol-process-coupling-202302)

# Design document and testing results

  ADD LINK HERE

# PR 

  ADD LINK HERE

----------

# Work log

  After considering and exploring several possibilities, I now try to follow Wuyin's suggestion
  to create a new branch in the `v3atm` repo off its current master (sync'ed with E3SM master
  by Wuyin), then cherry-pick my changes made to `NGD_v3atm`.

## Checking out master and create baseline results

```
ssh compy
cd ~/codes/scidac4_int/
git clone --recursive git@github.com:E3SM-Project/v3atm.git v3atm_master_202302

```

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
