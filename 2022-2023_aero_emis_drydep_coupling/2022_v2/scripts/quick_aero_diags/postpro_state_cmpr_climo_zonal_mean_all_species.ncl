  itime    = 0

  species_category = 1 ; aerosols
  species_category = 2 ; gases

  if (species_category.eq.1) then
     species_longname = (/"O3","H2O2","H2SO4","SO2","DMS","SOAG"/)
     species          = species_longname
     plotFileName     = "state_cmpr_all_gases"
  else
  if (species_category.eq.2) then
     species_longname = (/"Dust","Sea salt","MOA","BC","POA","Sulfate","SOA"/)
     species          = (/"dst","ncl","mom","bc","pom","so4","soa"/)
     plotFileName     = "state_cmpr_all_aerosols"
  else
     print("Unknown species_category. Abort.")
  end if
  end if

  ;-----------------------------------
  ; Paths to and names of climo files
  ;-----------------------------------
  expname  = (/"baseline_4b21b5_F2010","aerosol_F2010"/)
  checkout = (/"master","aerosol"/)
  FilePath = "/compyfs/wanh895/scidac4_int/"+checkout+"/"+expname+"/climo/"
  FileName = expname+"_ANN_201001_201412_climo.nc"

  ;-------------
  ; Color maps
  ;-------------
  state_colormap = "WhiteBlueGreenYellowRed"
   diff_colormap = "nrl_sirkes"

  ;-----------------------------
  ; For plotting
  ;-----------------------------
  ncol = 3  ; (1) revised model, (2) revised - original, (3) relative diff.

  nrow = dimsizes(species)
  plot = new( (/nrow,ncol/),"graphic" )
  wks  = gsn_open_wks("pdf",plotFileName)

  res = True
  res@gsnFrame = False
  res@gsnDraw  = False

  res@cnFillOn       = True
  res@cnLinesOn      = False
  res@cnLineLabelsOn = False

  res@tmXTOn = False
  res@tmYROn = False

  FontHeightF = 0.02 *0.35
  res@gsnStringFontHeightF = FontHeightF *1.2
  res@tiXAxisFontHeightF   = FontHeightF *0.9 
  res@tiYAxisFontHeightF   = FontHeightF *0.9

  res@lbOrientation        = "vertical"
  res@lbLabelFontHeightF   = FontHeightF *0.8

  vpWthF_crs = 0.18
  vpHgtF_crs = vpWthF_crs *0.55
  res@vpWidthF  = vpWthF_crs 
  res@vpHeightF = vpHgtF_crs

  res@gsnLeftStringOrthogonalPosF = 0.035
  res@gsnRightStringOrthogonalPosF = 0.035

  ;-----------------------------
  ; Panel lay out
  ;-----------------------------
  col_idx = (/"(a","(b","(c"/)
 ;col_lbl = (/"revised model","revised - original","relative diff."/)
  col_lbl = (/"revised","revised - baseline","relative diff."/)
  row_lbl = species_longname

  ;-----------------------------
  ; open data file
  ;-----------------------------
  nexp = dimsizes(FileName)
  File = addfiles(FilePath+FileName,"r")

  lat = File[0]->lat
  lon = File[0]->lon
  lev = File[0]->lev
  lev@long_name = "Norminal Pressure (hPa)"

;=======================================
; Loop through different species
;=======================================
do irow = 0,nrow-1

  isp = irow
  ;----------------------------
  ; History variables to read 
  ;----------------------------
 ;load "./mam4_species_and_modes.ncl" ; variable QoI_name becomes a list of tracer names for this species
  QoI_name = (/"Mass_"+species(irow)/)
  nqoi = dimsizes(QoI_name)

  ;----------------------------
  ; Contour levels
  ;----------------------------
        qLevels_ref = (/1e-10,2e-10,5e-10,1e-9,2e-9,5e-9,1e-8,2e-8,5e-8,1e-7/) 
    qDiffLevels_ref = (/-5e-8,-1e-8,-5e-9,-1e-9,-5e-10,5e-10,1e-9,5e-9,1e-8,5e-8/) 

  if (any( species(irow).eq.(/"dst","ncl"/) )) then  
        qLevels =     qLevels_ref 
    qDiffLevels = qDiffLevels_ref 
  end if
  if (any( species(irow).eq.(/"mom","bc","pom","SOAG","SO2","H2O2"/) )) then  
        qLevels =     qLevels_ref * 1e-2
    qDiffLevels = qDiffLevels_ref * 1e-2
  end if
  if (species(irow).eq."so4" .or. species(irow).eq."soa") then  
        qLevels =     qLevels_ref * 1e-1
    qDiffLevels = qDiffLevels_ref * 1e-1
  end if
  if (any( species(irow).eq.(/"DMS"/) )) then  
        qLevels =     qLevels_ref * 1e-3
    qDiffLevels = qDiffLevels_ref * 1e-3
  end if
  if (any( species(irow).eq.(/"H2SO4"/) )) then  
        qLevels =     qLevels_ref * 1e-5
    qDiffLevels = qDiffLevels_ref * 1e-5
  end if
  if (any( species(irow).eq.(/"O3"/) )) then  
        qLevels =     qLevels_ref * 100.
    qDiffLevels = qDiffLevels_ref * 100.
  end if

  ;----------------------------
  ; Read 3d mixing ratio fields
  ;----------------------------
  inc_fac = 1.

  do iqoi = 0,nqoi-1

    varname = QoI_name(iqoi)

    if (iqoi.eq.0) then ; read the first QoI
       var3d_0 = File[0]->$varname$(itime,:,:,:)*inc_fac
       var3d_1 = File[1]->$varname$(itime,:,:,:)*inc_fac

    else ; accumulate values 
       var3d_0 = var3d_0 + File[0]->$varname$(itime,:,:,:)*inc_fac
       var3d_1 = var3d_1 + File[1]->$varname$(itime,:,:,:)*inc_fac
    end if

  end do 

  var3d_0!0 = "lev"
  var3d_0!1 = "lat"
  var3d_0!2 = "lon"
  var3d_0&lev = lev
  var3d_0&lat = lat
  var3d_0&lon = lon

  var3d_1!0 = "lev"
  var3d_1!1 = "lat"
  var3d_1!2 = "lon"
  var3d_1&lev = lev
  var3d_1&lat = lat
  var3d_1&lon = lon

  res@tmYRMode = "Automatic"
  res@trYLog   = False
  res@trYMinF  = 100. 
  res@trYMaxF  = 1000.

  ;----------------------------------------
  ; Calculate zonal mean
  ;----------------------------------------
  var2d_0 = dim_avg_Wrap(var3d_0)
  var2d_1 = dim_avg_Wrap(var3d_1)

 ;res@tiXAxisString = "Latitude"

  ;----------------------
  ; plot new results 
  ;----------------------

   icol = 0
   res@cnFillPalette        = state_colormap
   res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
   res@cnLevels             = qLevels 
   res@gsnLeftString        = "~F22~"+col_idx(icol)+(irow+1)+") "+row_lbl(irow)
   res@gsnRightString       = col_lbl(icol) 
   plot(irow,icol) = gsn_csm_pres_hgt(wks,var2d_1,res)    
   delete(res@cnLevels)

   res@cnFillPalette  = diff_colormap 
  ;-------------------------
  ; calculate and plot diff
  ;-------------------------
   icol = 1
   diff = var2d_1
   diff = var2d_1 - var2d_0
   res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
   res@cnLevels             = qDiffLevels 
   res@gsnLeftString        = "~F22~"+col_idx(icol)+(irow+1)+") "+row_lbl(irow)
   res@gsnRightString       = col_lbl(icol) 
   plot(irow,icol) = gsn_csm_pres_hgt(wks,diff,res)    
   delete(res@cnLevels)
     
  ;----------------------------------
  ; calculate and plot relative diff
  ;----------------------------------
   icol = 2 
  
   denom = where(abs(var2d_0).ge.1E-36, var2d_0, -999.)
   denom@_FillValue = -999.
   reldiff = var2d_1 
   reldiff = (var2d_1 - var2d_0)/denom

   res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
   res@cnLevels             = (/-1.5,-1,-0.5,-0.3,-0.1,0.1,0.3,0.5,1,1.5/)
   res@gsnLeftString        = "~F22~"+col_idx(icol)+(irow+1)+") "+row_lbl(irow)
   res@gsnRightString       = col_lbl(icol) 
   plot(irow,icol) = gsn_csm_pres_hgt(wks,reldiff,res)    
   delete(res@cnLevels)

   delete([/var2d_1,var2d_0,diff,denom,reldiff/])

delete(QoI_name)
end do

  resP = True
  resP@gsnMaximize = True
  resP@gsnPanelYWhiteSpacePercent = 5
  resP@gsnPanelXWhiteSpacePercent = 3 
  gsn_panel(wks,ndtooned(plot),(/nrow,ncol/),resP)

