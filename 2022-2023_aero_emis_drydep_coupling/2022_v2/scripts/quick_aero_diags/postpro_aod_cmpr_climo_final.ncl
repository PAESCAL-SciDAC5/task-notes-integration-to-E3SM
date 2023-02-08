  l_map_zoom = True
  l_map_zoom = False

  itime    = 0

  expname  = (/"baseline_4b21b5_F2010","aerosol_F2010"/)
  checkout = (/"master","aerosol"/)
  FilePath = "/compyfs/wanh895/scidac4_int/"+checkout+"/"+expname+"/climo/"
  FileName = expname+"_ANN_201001_201412_climo.nc"


  chkpt      = (/"ALL","DUST","SS","BC","POM","SOA"/)
  inc_fac    = (/1,1,1,1,1,1/)
  QoI_prefix = chkpt
  QoI_prefix = ""
   


  nchkpt = dimsizes(chkpt)
  label  = chkpt 

  QoI_name = "AOD"

  inc_suff = ""  ; or "" for state
  unit     = "kg m~S~-2~N~ s~S~-1~N~"
  cnLevels = (/ -1e-8,-5e-9, -1e-9, -5e-10,-1e-10,-5e-11, 5e-11, 1e-10,5e-10, 1e-9,  5e-9,  1e-8 /) 

  if (l_map_zoom) then
     cnLevels = cnLevels *0.1
  end if

  col_idx = (/"(a","(b","(c"/)
 ;col_lbl = (/"revised model","revised - original","relative diff."/)
  col_lbl = (/"revised","revised - baseline","relative diff."/)
  row_lbl = QoI_name+" "+label 

  glbavg = new( nchkpt, "float" )

  ;-------------------------------------
  ; constants used for unit conversion
  ;-------------------------------------
  pi             = 3.14159265358979323846  ; from E3SM
  earth_radius   = 6.37122e6               ; from E3SM
  earth_sfc_area = 4.*pi*earth_radius^2

  kg2Tg  = 1e-9
  sec2yr = 86400.*365

  ;-----------------------------
  ; for plotting
  ;-----------------------------
  plot = new( (/nchkpt,3/),"graphic" )
  wks  = gsn_open_wks("pdf","aod_cmpr")
  gsn_define_colormap(wks,"testcmap")

  res = True
  res@gsnFrame = False
  res@gsnDraw  = False


  res@mpFillOn = False


  res@mpProjection   = "Robinson"
  res@mpOutlineOn = True ; turn on outline

  if (l_map_zoom) then
  res@mpLimitMode = "LatLon"
  res@mpMinLatF = 20
  res@mpMinLatF = 40
  res@mpMaxLatF = 75           ; choose subregion           
  res@mpMinLonF = -130
  res@mpMaxLonF = -60

  res@mpDataBaseVersion = "MediumRes" ; select database
  res@mpOutlineBoundarySets = "USStates" ; outline nothing but those areas specified below
 ;res@mpOutlineBoundarySets = "AllBoundaries" 
  res@mpOutlineBoundarySets = "National" 
 ;res@mpOutlineBoundarySets = "NoBoundaries" ; outline nothing but those areas specified below
  res@mpOutlineSpecifiers = (/"Alberta","Saskatchewan","British Columbia","Manitoba", \
                              "Quebec","Ontario","Prince Edward Island","Northwest Territories", \
                              "Yukon Territory","Newfoundland","Labrador","Nova Scotia", \
                              "New Brunswick"/)

  res@mpPerimOn            = True 

  else

  res@mpDataBaseVersion    = "LowRes"       ; better map outlines
  res@mpPerimOn            = False          ; turn off map perimeter

  end if



  res@mpGridAndLimbOn      = True           ; turn on limb and grid lines
  res@mpGridLineColor      = -1             ; ...but don't draw grid lines...
  res@mpFillDrawOrder      = "PostDraw"     ; draw map fill last
  res@mpGeophysicalLineColor = "black"

  res@mpFillOn    = False                       ; turn map fill off
  res@mpOutlineOn = True                        ; turn the map outline on

  res@cnFillOn    = True                        ; turn on color fill
  res@cnLinesOn   = False                       ; turn off the contour lines
  res@cnLineLabelsOn = False                    ; turn the line labels off

  res@gsnStringFontHeightF = 0.023
 ;res@tiMainFontHeightF    = 0.025

  res@tmXTOn = False
  res@tmYROn = False

  res@lbOrientation = "vertical"
  res@lbLabelFontHeightF = res@gsnStringFontHeightF * 0.75
  res@pmLabelBarHeightF   = 0.41       ; default is taller
 ;res@pmLabelBarWidthF    = 0.1        ; default is shorter
 ;res@pmLabelBarOrthogonalPosF = 0.15
 ;res@pmLabelBarParallelPosF = 0.6



  ;-----------------------------
  ; open data file
  ;-----------------------------
  nexp = dimsizes(FileName)
  File = addfiles(FilePath+FileName,"r")

  area = tofloat(File[0]->area)
  lat  = File[0]->lat
  lon  = File[0]->lon
; lon  = where(lon.le.180., lon, lon - 360.)

 ;res@sfXArray = lon
 ;res@sfYArray = lat

  ;---------------------------
  ; for drawing a lat-lon box
  ;---------------------------
  dum  = new( (/nchkpt,4/),graphic)  

  ;---------------------

  print("")
  do ichkpt = 0,nchkpt-1

      varname = QoI_prefix(ichkpt)+QoI_name+chkpt(ichkpt)+inc_suff

      var2d_0 = File[0]->$varname$(itime,:,:)*inc_fac(ichkpt)
      var2d_1 = File[1]->$varname$(itime,:,:)*inc_fac(ichkpt)


      var2d_1!0 = "lat"
      var2d_1!1 = "lon"
      var2d_1&lat = lat
      var2d_1&lon = lon

        icol = 0
        res@gsnLeftString  = "~F22~"+col_idx(icol)+(ichkpt+1)+") "+row_lbl(ichkpt)
        res@gsnRightString = col_lbl(icol)

        res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
        res@cnLevels = (/0.01,0.02,0.05,0.1,0.2,0.5,1/)
       ;res@cnMinLevelValF =  0.1
       ;res@cnMaxLevelValF =  1.0
       ;res@cnLevelSpacingF = 0.1

        plot(ichkpt,icol) = gsn_csm_contour_map(wks,var2d_1,res)    

        icol = 1
        res@gsnLeftString  = "~F22~"+col_idx(icol)+(ichkpt+1)+") "+row_lbl(ichkpt)
        res@gsnRightString = col_lbl(icol)

       ;res@cnLevelSelectionMode = "ManualLevels"   ; set explicit contour levels
       ;res@cnMinLevelValF = -0.2
       ;res@cnMaxLevelValF =  0.2
       ;res@cnLevelSpacingF = 0.02
        delete(res@cnLevels)
        res@cnLevels = (/-0.2,-0.1,-0.05,-0.02,-0.01,0.01,0.02,0.05,0.1,0.2/)

        diff = var2d_1
        diff = var2d_1 - var2d_0
        plot(ichkpt,icol) = gsn_csm_contour_map(wks,diff,res)    


        delete(res@cnLevels)
        res@cnLevels = (/-1.0,-0.5,-0.3,-0.1,0.1,0.3,0.5,1.0/) 

        icol = 2
        res@gsnLeftString  = "~F22~"+col_idx(icol)+(ichkpt+1)+") "+row_lbl(ichkpt)
        res@gsnRightString = col_lbl(icol)

        denom = where(abs(var2d_0).ge.1E-13, var2d_0, -999.)
        denom@_FillValue = -999.

        reldiff = var2d_1 
        reldiff = (var2d_1 - var2d_0)/denom
        plot(ichkpt,icol) = gsn_csm_contour_map(wks,reldiff,res)    

        delete(res@cnLevels)

       ;-----
       l_plot_box = False
       if (l_plot_box) then
       respoly                  = True                      ; polyline mods desired
       respoly@gsLineColor      = "red"                     ; color of lines
       respoly@gsLineThicknessF = 2.0                       ; thickness of lines

       do ii = 0,3
         dum(ichkpt,ii)=gsn_add_polyline(wks,plot(ichkpt),xpts(ii:ii+1),ypts(ii:ii+1),respoly)      
       end do 
       end if

  end do

  resP = True
 ;resP@gsnMaximize = True
  resP@gsnPanelYWhiteSpacePercent = 8 
 ;resP@gsnPanelMainFontHeightF = res@gsnStringFontHeightF*0.3
  gsn_panel(wks,ndtooned(plot),(/nchkpt,3/),resP)


