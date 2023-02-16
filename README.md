# Integrating PAESCAL codes to E3SM

## Recent updates

  CondiDiag (including the dCAPE decomposition) has been ported to a 2023-02-12
  commit from E3SM's master branch. The commit is very close to maint-2.1.

  To clone the code, use the following command

```
  git clone -b huiwanpnnl/atm/CondiDiag1.1_in_EAMv2p --recursive git@github.com:PAESCAL-SciDAC5/E3SM-fork.git
``` 

  Sample run scripts and postprocessing scripts can be found [here](2022-2023_CondiDiag/2023_v2p/scripts/)


## Notes on our integration efforts

- 2022-2023, [aerosol emission-dry-deposition coupling](2022-2023_aero_emis_drydep_coupling/aero_emis_drydep_coupling_notes.md)

## Useful links

### E3SM policies and procedures

- Code review and new feature process: [E3SM Confluence page](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/3438608385/E3SM+Code+Review+and+New+Feature+Process) and [Mark Taylor's presentation](https://www.youtube.com/watch?v=08iD2wGuVDg)
- Branch, tag, and version name conventions: [link to E3SM Confluence](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/2523172/Branch+Tag+and+Version+name+conventions)

### E3SM documentation

- Development getting started guide: [link to E3SM Confluence](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/1868455/Development+Getting+Started+Guide)
- Testing documentation: [link to E3SM Confluence](https://acme-climate.atlassian.net/wiki/spaces/DOC/pages/17006925/Testing)
- Test types: 3-letter acrynoms and what they mean: [link to CIME repo](https://github.com/ESMCI/cime/blob/master/CIME/SystemTests/README)
- [Comprehensive test suites](info/doc_e3sm_test_suites.md)


