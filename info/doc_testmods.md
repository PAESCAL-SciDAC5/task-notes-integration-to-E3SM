
"Testmods" refers to the namelist changes and `xmlchange` commands to be included when executing the `create_test` command. Here is the explanation from the [CIME user guide](https://esmci.github.io/cime/versions/master/html/users_guide/testing.html#group-testmods).


## Wuyin's `20tr_v3atm` example


Let's assume we want to introduce a modification to a default EAM run and  refer to the modification as `20tr_v3atm`. Here are the steps needed:

1. Go to `components/eam/cime_config/testdefs/testmods_dirs/eam/` and create a subdirectory `20tr_v3atm/`.
2. If namelist changes are needed, create a `user_nl_eam` file under `20tr_v3atm/`.
3. If `xmlchange` commands are needed, create a `shell_command` file under `20tr_v3atm/` and put the commands.
4. Issue  the `create_test` command with the string `.eam-20tr_v3atm` appended to the testname, e.g.,
`PET_Ln9.ne30pg2_EC30to60E2r2.F20TR_chemUCI-Linozv3.chrysalis_intel.eam-20tr_v3atm`
