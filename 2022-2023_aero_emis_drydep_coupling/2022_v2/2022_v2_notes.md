This page contains notes from summer 2022 on testing a revised coupling of aerosol emission and dry deposition in E3SMv2.

------

# Revised aerosol process coupling

## Motivation

In EAMv1 and v2, the surface emission of aerosols and gas species is applied (i.e., the tracer mixing ratios in the state variable are updated) after the subroutine `clubb_surface` in `tphysac`. This is done before dry removal. The resolved transport and turbulent mixing are calculated after dry removal. This sequence of calculation, used in combination with sequential operator splitting, is problematic for aerosol species with strong surface emission sources as this numerical scheme leads to 

* overestimated dry removal
* underestimated turbulent transport

and consequently

* underestimated long-range transport
* overly short dust aerosol lifetime

The problem is particularly severe when the bottom layer in EAM is thin.

As a quick, easy, and effective (although not perfect) solution to this numerical issue, we propose a revised coupling scheme in which the mixing ratio update corresponding to surface emission is moved to the location before the cloud macro-microphysics subcycles in `tphysbc`. For aerosols, this means surface emissions are applied after dynamics and before turbulent mixing, which can be interpreted as using parallel splitting between the emissions and dry removal.

Results from EAMv1 show that this revision 

* substantially increases the simulated global mean dust lifetime when using 72 vertical levels,
* substantially reduces the sensitivity of the dust lifetime to vertical resolution,

both of which are desirable changes.


## Code

Branch [`huiwanpnnl/atm/aerosol_process_coupling`](https://github.com/E3SM-Project/E3SM/tree/huiwanpnnl/atm/aerosol_process_coupling)

Modifications to v2:

* A new namelist variable `cflx_cpl_opt` was added.
  * 1 = standard v2 (default)
  * 2 = revised coupling

* The subroutine `clubb_surface` in `clubb_intr.F90` was split into two parts:
  * The calculation of ustar and the Obukhov length remains in `clubb_surface`.
  * The calculation of tracer mixing ratio tendencies using `cam_in%clfx` was moved to a new subroutine `cflx_tend` in a new file `cflx.F90`

* Old versus new coupling in the revised code
  * By default, `cflx_cpl_opt = 1`, the new subroutine `cflx_tend` is called immediately after `clubb_surface`, followed by a `call physics_update(...)`. This reproduces the standard EAMv2 results (BFB).
  * With `cflx_cpl_opt = 2`, the call of `cflx_tend` and the corresponding `call physics_update(...)` are moved to right before the cloud macro-microphysics subcycles in `tphysbc`.

## BFB testing

Short 2x5-day simulation with a restart after day 5:

* Run script: [`run_3_cflx_cpl_opt_1.sh`](https://github.com/huiwanpnnl/scidac_integration/blob/main/scripts/aerosol_process_coupling/run_3_cflx_cpl_opt_1.sh)

* Run directory on Compy: `/compyfs/wanh895/scidac4_int/aerosol/cflx_cpl_opt_1/tests/XS_2x5_ndays/run/`

* The following text in `atm.log` indicates that the original coupling scheme in EAMv2 was used:
`phys_ctl_readnl: cflx_cpl_opt =            1`

* The following line in `atm.log` indicates that the results are BFB identical to those from the master:
`nstep, te      481   0.26201811523625607E+10   0.26201826682369900E+10   0.83831016650550192E-04   0.98521053591103759E+05`

* For reference, the corresponding line from the baseline (hash `4b21b5` from May 19, 2022) is 
`nstep, te      481   0.26201811523625607E+10   0.26201826682369900E+10   0.83831016650550192E-04   0.98521053591103759E+05`

* If `cflx_cpl_opt = 2`, the line becomes 
  ` nstep, te      481   0.26203722892147989E+10   0.26203737999446177E+10   0.83546702557270257E-04   0.98520825327654529E+05`

## Five-year atmosphere simulation

### Case setup shared with the reference simulation

* Compset: `F2010`
* Resolution: `ne30pg2_EC30to60E2r2`
* `CASE_GROUP = v2.LR.SciDAC4-PNNL`
* Hybrid run with an AMIP reference case provided by Wuyin Lin:

```
readonly MODEL_START_TYPE="hybrid"  
readonly START_DATE="0001-01-01"

readonly GET_REFCASE=TRUE
readonly RUN_REFDIR="/compyfs/linw288/E3SMv2/v2.LR.amip_0101/rest/2010-01-01-00000"
readonly RUN_REFCASE="v2.LR.amip_0101"
readonly RUN_REFDATE="2010-01-01"
```
 * PE layout: 640 tasks (640/40 = 16 nodes)

### Sensitivity experiment

* Case name: `aerosol_F2010` 
* Revised coupling turned on using `cflx_cpl_opt = 2` in `user_nl_eam`
* Run script: [`run_cflx_cpl_opt_2_F2010_climate.sh`](https://github.com/huiwanpnnl/scidac_integration/blob/main/scripts/aerosol_process_coupling/run_cflx_cpl_opt_2_F2010_climate.sh)
* Run dir: `/compyfs/wanh895/scidac4_int/aerosol/aerosol_F2010/run/`
* Climo files: `/compyfs/wanh895/scidac4_int/aerosol/aerosol_F2010/climo/`
* Baseline (default coupling)
  * climo files: `/compyfs/wanh895/scidac4_int/master/baseline_4b21b5_F2010/climo/`
  * run dir: `/compyfs/wanh895/scidac4_int/master/baseline_4b21b5_F2010/run/`
* E3SM_Diags output: [comparison with baseline](https://compy-dtn.pnl.gov/wanh895/E3SM/v2.LR.SciDAC4-PNNL/aerosol_vs_baseline_4b21b5_F2010/e3sm_diags/180x360_aave/aerosol_vs_baseline_4b21b5_F2010_2010-2014/viewer/)


### Key results

All numbers and plots shown below are _5-year averages_.

#### Global mean

|                | Dust burden | Dust emission  | Dust lifetime |
|----------------|-------------|----------------|---------------|
| Baseline       | 23.0 Tg     | 3888.8 Tg/year | 2.2 day |
| Revised        | 31.9 Tg     | 4005.6 Tg/year | 2.9 day |
| Relative diff. | +39%        | +3%            | +35%    |
|                | **Sea salt burden** | **Sea salt emission**  | **Sea salt lifetime** |
| Baseline       | 5.4 Tg          | 2533.2 Tg/year | 0.8 day |
| Revised        | 8.5 Tg          | 2517.8 Tg/year | 1.2 day |
| Relative diff. | +57%            | -3%            | +58%    |

#### Zonal mean aerosol mass mixing ratios

![Zonal mean mixing ratios](figures/aerosol_zonal_mean_mixing_ratio.png)

#### AOD

![AOD](figures/aerosol_AOD.png)


## Coupled simulation

## Nudged atmosphere simulations for analyzing aerosol effects
