


  climoFile = (/"/compyfs/wanh895/scidac4_int/aerosol/20220519.v2.LR.bi-grid.amip.cflx_cpl_opt_2.compy/post/atm/180x360_aave/clim/30yr/20220519.v2.LR.bi-grid.amip.cflx_cpl_opt_2.compy_ANN_198501_201412_climo.nc"/)

  ncase = dimsizes(climoFile)

  SFName = (/"SF"  \; surface emission
            ,"TBF" \; turbulent dry deposition
            ,"GVF" \; grav. settinging
            ,"SFWET" \; wet deposition
            /)
  SFFctr = (/1,1,1,-1/)
  nSF    = dimsizes(SFName)

  burden = new( (/ncase/), "double" )
  aod    = new( (/ncase/), "double" )
  SFlux  = new( (/ncase,nSF/), "double" )
  lifet  = new( (/ncase/), "double" )

 ;BurdenName = "BURDENDUST"
 ;AODName    = "AODDUST"
 ;modeName  = (/"dst_a1","dst_a3"/)

  BurdenName= "BURDENSEASALT"
  AODName    = "AODSS"
  modeName = (/"ncl_a1","ncl_a2","ncl_a3"/)

  nmode = dimsizes(modeName)

  gravit = 9.80616
  rEarth = 6371000.

  do icase = 0,ncase-1

     File = addfile(climoFile(icase),"r")
     area = File->area

     ;------------------------
     ; Burden 
     ;------------------------
     burden2d = File->$BurdenName$(0,:,:)
     burden(icase) = sum(burden2d*area) * rEarth^2

     aod2d = File->$AODName$(0,:,:)
     aod(icase) = sum(aod2d*area)/sum(area) 

     ;------------------------
     ; Surface fluxes
     ;------------------------
     do iSF = 0,nSF-1

        varname = modeName(0)+SFName(iSF)
        SF  = File->$varname$(0,:,:)
        do ii = 1,nmode-1
           varname = modeName(ii)+SFName(iSF)
           SF = SF + File->$varname$(0,:,:)
        end do
        SFlux (icase,iSF) = sum(SF*area) * rEarth^2 * SFFctr(iSF)

     end do

     ;================================
     ; global mean
     ;================================
     lifet (icase) = burden(icase)/SFlux(icase,0)/86400.

     ;-- sanity check ---
     ;ps_glbavg = sum( dim_sum_n( dp, 0 ) *area)/sum(area) 
     ;print(ps_glbavg)
     ;--------------------

 end do

 do icase = 0,ncase-1

    print("Burden = "+sprintf("%5.1f",burden(icase)/1e9)+" Tg ")
    print("AOD    = "+sprintf("%f",aod(icase))+"")

    do iSF = 0,nSF-1
    print(SFName(iSF)+" = "+sprintf("%7.1f",SFlux(icase,iSF)/1e9*86400*365)+" Tg/year  ")
    end do

    print("Lifetime = "+sprintf("%3.1f",lifet(icase))+" day")
 end do

