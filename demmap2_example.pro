

ncols=20
nrows=20
nbridges=5

  ; Demo code that makes a synthetic AIA map using a Gaussian model DEM
  ; Then perform the regularization and compares the results
; 18-Nov-2012 IGH Example using dn2dem_map2.pro

  if n_elements(nbridges) eq 0 then nbridges=1
  if n_elements(ncols) eq 0 then ncols=5
  if n_elements(nrows) eq 0 then nrows=10

  
;  ############### Make the DEM model ############################
  d1=7d22
  m1=6.5
  s1=0.2
  
  temps=[0.5,1,1.5,2,3,4,6,8,11,14,19,25,32]*1e6
  
  logt0=alog10(temps)
  
;  resp_file=file_search('aia_resp_chi.dat')
;  if strlen(resp_file) eq 0 then begin
;    eff=aia_get_response(/temperature,/dn,/chiantifix,/evenorm)
;    save,file='aia_resp_chi.dat',eff
;  endif else  begin
    restore,file='aia_resp_chi.dat'
  ;endelse

  idc=[0,1,2,3,4,6]
  logT=eff.logte
  gdt=where (logt ge min(logt0) and logt le max(logt0),ngd)
  logt=logt[gdt]
  TRmatrix=eff.all[*,idc]
  TRmatrix=TRmatrix[gdt,*]
  root2pi=sqrt(2.*!PI)
  dem_mod=(d1/(root2pi*s1))*exp(-(logT-m1)^2/(2*s1^2))
  ;  ############### Make the synthetic data from the DEM model #############
  dn_mod=dem2dn(logT, dem_mod, TRmatrix)
  dn=dn_mod.dn
  ; ################ Mathe the map from the synthetic data ##############
  map=replicate(make_map(fltarr(ncols,nrows),dx=0.6,dy=0.6,yc=0.,xc=0.),6)
  map.dur=1.
  for i=0,ncols-1 do for j=0,nrows-1 do map.data[i,j]=dn
  
  ;test response input
;  ; simple example below
;  idc=[0,1,2,3,4,6]
;  tresp_in={channels:eff.channels[idc],logte:eff.logte,all:eff.all[*,idc]}
  
  ; ######## do the regularization ###########################
  ;abee doesn't do anything at the moment
  dn2dem_map_pos,map,dem,chisq,temps=temps,edem=edem,elogt=elogt, do_mapreg=1, $
   nbridges=nbridges,mapreg=mapreg,/tcont,DNperT=dpt,$
   sat_lvl=3e4,$ ; larger as just a test, don't use this value with real data!
   err_max=1/4. ,$; default is 1/3 (i.e. SNR of 3)
   sys_err=0.05 ; add a 5% systematic error (default is 0.)
   
  linecolors
  midt=get_edges(logt0,/mean)
  nt=n_elements(midt)
  !p.thick=2
  !p.charsize=1.5
  !p.multi=0
  yr=max(dem_mod)*[1e-3,1.5]
  
  ; just plot the DEM in the first pixel
  ; all other pixels will be identical in this test
    window,0,xsize=600,ysize=400
  plot,logt,dem_mod,yrange=yr,xrange=[5.5,7.6],xstyle=17,/ylog
  oplot,midt,dem[0,0,*],color=2,psym=-4
  mined=reform((dem[0,0,*]-edem[0,0,*]) > yr[0])
  maxed=reform((dem[0,0,*]+edem[0,0,*]) < yr[1])
  for i=0, nt-1 do oplot,midt[i]*[1,1],[mined[i],maxed[i]],color=2
  elmin=   (midt-elogt[0,0,*])
  elmax=(midt+elogt[0,0,*])
  for i=0, nt-1 do $
      oplot,[elmin[i] < logt0[i] ,elmax[i]>logt0[i+1]],dem[0,0,i]*[1,1],color=2
      
      
  titn=['94','131','171','193','211','335']+string(197b)
  window,1,xsize=600,ysize=400
  !p.multi=[0,3,2]
  for i=0, 5 do  plot,midt,dpt[0,0,*,i],$
          yrange=1.1*max(abs(dpt[0,0,*,i]))*[-1,1.],title=titn[i]+string(mapreg[i].data[0,0]),chars=2.0,$
           xrange=[5.5,7.6],xstyle=17,thick=3,xtitle=' log!D10!NT [K]',ytitle='DN s!U-1!N px!U-1!N'
      
  !p.multi=0

stop
end
