;-----------------------------------------------------------
; Post-processing script for CAPE budget analysis.
; Hui Wan, 2021
;-----------------------------------------------------------

  ; two run-time options

  plot_decomp_as_percentage = True    ; plot dCAPEe/dCAPE and dCAPEp/dCAPE in % 
  plot_decomp_as_percentage = False   ; plot dCAPEe and dCAPEp (unit: J/kg)

  ;--------------------------------------------------------------------------------
  ; EAM history output
  ;--------------------------------------------------------------------------------
  FilePath = "/compyfs/wanh895/scidac5/CondiDiag1.1_in_EAMv2p/CondiDiag_dCAPE_decomp/tests/XS_1x1_nmonths/run/"
  FileName = "CondiDiag_dCAPE_decomp.eam.h0.0001-01.nc" 

  ;-------------------------------------------------
  ; Varialbes and checkpoints to plot
  ;-------------------------------------------------
  cnd_lbl  = "cnd01_"

  label    = (/"CLUBB+MG2", "radiation","After-coupling physics","dynamics","deep Cu"/)
  chkpt    = (/"STCLD",     "RAD",      "PACEND",                "DYNEND",  "DEEPCU"/)
  nchkpt = dimsizes(chkpt)

  QoI_name = (/"CAPE","dCAPE","dCAPEp","dCAPEe"/)
  nqoi   = dimsizes(QoI_name)

  ;-----------------------------
  ; For plotting
  ;-----------------------------
  plot_file_name = "dCAPE_decomp_maps"
  if (plot_decomp_as_percentage) then
     plot_file_name = plot_file_name + "_percentage"
  end if

  wks  = gsn_open_wks("pdf",plot_file_name)
  gsn_define_colormap(wks,"testcmap")

  plot   = new( (/nchkpt,nqoi/),"graphic" )
  glbavg = new( (/nqoi,nchkpt/), "float" )

  ;----------------------------
  res = True
  res@gsnFrame = False
  res@gsnDraw  = False

  res@mpProjection         = "Robinson"
  res@mpDataBaseVersion    = "LowRes"
  res@mpGridAndLimbOn      = True           ; turn on limb and grid lines
  res@mpGridLineColor      = -1             ; ...but don't draw grid lines...
  res@mpPerimOn            = False          ; turn off map perimeter
  res@mpFillDrawOrder      = "PostDraw"     ; draw map fill last
  res@mpGeophysicalLineColor = "gray"

  res@mpFillOn    = False                       ; turn map fill off
  res@mpOutlineOn = True                        ; turn the map outline on
  res@cnFillOn    = True                        ; turn on color fill
  res@cnLinesOn   = False                       ; turn off the contour lines
  res@cnLineLabelsOn = False                    ; turn the line labels off

  res@gsnStringFontHeightF = 0.02
  res@tiMainFontHeightF    = 0.025

  res@lbOrientation            = "vertical"
  res@lbLabelFontHeightF       = res@gsnStringFontHeightF * 0.8
 ;res@pmLabelBarWidthF         = 0.1
  res@pmLabelBarHeightF        = 0.41
 ;res@pmLabelBarOrthogonalPosF = 0.15
 ;res@pmLabelBarParallelPosF   = 0.6

  ;--------------------------------------
  ; open data file, read and unpack data
  ;--------------------------------------
  File = addfile( FilePath+FileName,"r")

  area = tofloat(File->area)
  lat  = File->lat
  lon  = File->lon

  res@sfXArray = lon
  res@sfYArray = lat

  ncol       = dimsizes(lon)
  varname    = "cnd01_"+QoI_name(0)+"_"+chkpt(0)
  datafptype = typeof(File->$varname$)

  qoi = new( (/nqoi,nchkpt,ncol/),datafptype )
  qoi@_FillValue = -999.

  do ichkpt = 0,nchkpt-1 ; different atm. processes

     iqoi = 0

     varname = cnd_lbl+"CAPE_"+ chkpt(ichkpt)
     qoi(iqoi,ichkpt,:)  = (/File->$varname$(0,:)/)
     glbavg(iqoi,ichkpt) = sum(qoi(iqoi,ichkpt,:)*area)/sum(area)

     ;-------------------------------------------------------------------------
     ; In the current version of CondiDiag, dCAPE, dCAPEp, dCAPEe are packed
     ; in a single 3D array called dCAPE in EAM's history out put.
     ; Here we unpack the data for each checkpoint.
     ;-------------------------------------------------------------------------
     varname = cnd_lbl+"dCAPE_"+ chkpt(ichkpt)

     do iqoi = 1,3
        qoi(iqoi,ichkpt,:)  = (/File->$varname$(0,iqoi-1,:)/)
        glbavg(iqoi,ichkpt) = sum(qoi(iqoi,ichkpt,:)*area)/sum(area)
     end do

     ;---------------------------------------------------------------------------------------------
     ; If plotting the dCAPE decomposition in percentages, calculate dCAPEe/dCAPE and dCAPEp/dCAPE
     ;---------------------------------------------------------------------------------------------
     if (plot_decomp_as_percentage) then
        do iqoi = 2,3

           tmp = where( abs(qoi(1,ichkpt,:)).gt.2., qoi(1,ichkpt,:), -999. )  ; mask out zeros
           tmp@_FillValue = -999.

           qoi(iqoi,ichkpt,:)  = qoi(iqoi,ichkpt,:)/tmp *100.
           glbavg(iqoi,ichkpt) = glbavg(iqoi,ichkpt)/glbavg(1,ichkpt) *100.

        end do
     end if

  end do ; ichkpt 

  ;-----------------------------------------------------------
  ; Plot data
  ;-----------------------------------------------------------
  do iqoi = 0,nqoi-1     ; QoI loop

        ;-----------------------------------------------------------
        ; Set contour levels (different for CAPE and dCAPE)
        ;-----------------------------------------------------------
        if (iqoi.eq.0) then   ; CAPE

           add_string = QoI_name(iqoi)+" (J/kg) after "
           res@cnLevelSelectionMode = "ManualLevels"
           res@cnMinLevelValF =  30.
           res@cnMaxLevelValF =  300.
           res@cnLevelSpacingF = 30.

        else 
        if (iqoi.gt.1 .and. plot_decomp_as_percentage) then   ; percentages

           add_string = QoI_name(iqoi)+"/"+QoI_name(1)+" (%), "
           res@cnLevelSelectionMode = "ExplicitLevels"
           res@cnLevels = (/-1,-0.8,-0.6,-0.4,-0.2,-0.05,0.05,0.2,0.4,0.6,0.8,1/)*100.

        else  ; dCAPE, dCAPEp, and dCAPEe

           add_string = QoI_name(iqoi)+" (J/kg) due to "
           res@cnLevelSelectionMode = "ExplicitLevels"
           res@cnLevels = (/-100,-50,-20,-10,-5,-2,2,5,10,20,50,100/)

        end if
        end if

        ;----------------------------------------------------
        ; Make contour plot
        ;----------------------------------------------------
        do ichkpt = 0,nchkpt-1 ; different atm. processes

           ; title string labels the variable to be plotted and its unit

           res@tiMainString = add_string + label(ichkpt)

           ; center string gives the global average

           res@gsnCenterString = "glbavg: "+sprintf("%6.1f",glbavg(iqoi,ichkpt))
           if (iqoi.gt.1 .and. plot_decomp_as_percentage ) then
              res@gsnCenterString = res@gsnCenterString + "%"
           else
              res@gsnCenterString = res@gsnCenterString + " J/kg"
           end if

           ; make contour plot
           plot(ichkpt,iqoi) = gsn_csm_contour_map(wks,qoi(iqoi,ichkpt,:),res)    

        end do

        ; print global averages to screen for sanity check

        print(QoI_name(iqoi)+", global mean = "+glbavg(iqoi,:)+" after "+chkpt)
        print("")

        delete(res@cnLevels)
     end do 

     ;-----------------------------------------------------------------
     ; Create paneled plot: different atm. processes in different rows
     ;-----------------------------------------------------------------
     resP = True
     resP@gsnMaximize = True
     resP@gsnPanelYWhiteSpacePercent = 8 

     nplotcols = 4
     gsn_panel(wks,ndtooned(plot(:,:)),(/nchkpt,nplotcols/),resP)

     ;------------------------------------------------------------------------------------------------
     ; sanity check: dCAPE vs (dCAPEp + dCAPEe) -- they should match when we use Xiaoliang's formulae
     ;------------------------------------------------------------------------------------------------

     print("sanity check for dCAPE: "+chkpt+" "+glbavg(1,:)+" vs "+(glbavg(2,:)+glbavg(3,:)))

