# Integrating PAESCAL codes to E3SM

This is the landing page of PAESAL's task team working on integration with the E3SM project. For questions and comments, please contact

- Wuyin Lin (Brookhaven National Laboratory)
- Hui Wan (Pacific Northwest National Laboratory)
- Jianfeng Li (Pacific Northwest National Laboratory)

---

## News

### *February 2023: CondiDiag1.1 ported to E3SMv2.1*

  CondiDiag version 1.1, which contains the basic functionalities described in [Wan et al. (2022)](https://gmd.copernicus.org/articles/15/3205/2022/) *plus* the dCAPE decomposition designed by Xiaoliang Song and Guangzhang, has been ported to a 2023-02-12 commit from E3SM's master branch (which is very similar to tag `maint-2.1`).

The code can be cloned using the following command
```
  git clone -b huiwanpnnl/atm/CondiDiag1.1_in_EAMv2p --recursive git@github.com:PAESCAL-SciDAC5/E3SM-fork.git
``` 

Sample run scripts and postprocessing scripts can be found [here](2022-2023_CondiDiag/2023_v2p/scripts/)

---
## Our code integration efforts

- 2022-2023, [aerosol emission-dry-deposition coupling](2022-2023_aero_emis_drydep_coupling/aero_emis_drydep_coupling_notes.md)
- 2022-2023, [CondiDiag1.1](2022-2023_CondiDiag/)


---
## Notes

### Code testing using CIME

- `create_test` - [basics, examples, and quick lookups](info/doc_create_test.md)
- Using [comprehensive test suites](info/doc_e3sm_test_suites.md)
- How to modify test settings by specifying ["testmods"](info/doc_testmods.md) 


### E3SM policies, procedures, and documentation

- Code review and new feature process: [E3SM Confluence page](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/3438608385/E3SM+Code+Review+and+New+Feature+Process) and [Mark Taylor's presentation](https://www.youtube.com/watch?v=08iD2wGuVDg)
- Branch, tag, and version name conventions: [link to E3SM Confluence](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/2523172/Branch+Tag+and+Version+name+conventions)
- Development getting started guide: [link to E3SM Confluence](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/1868455/Development+Getting+Started+Guide)
- Testing documentation: [link to E3SM Confluence](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/17006925/Testing)

