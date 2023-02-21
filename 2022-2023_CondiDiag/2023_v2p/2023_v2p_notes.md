# 1. Port CondiDiag1.0


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

# 3. Port Dec-2022 bug fix for branch runs

This is to make sure the simulation won't abort if a user requests new CondiDiag output when doing a branch run.

# 4. Port CAPE budget decomposition

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

  Scripts can be founds in [`scripts/dCAPE_decomp/`](scripts/dCAPE_decomp/)
