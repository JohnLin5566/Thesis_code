pro dn2dem_map_pos,map,dem,chisq,edem=edem,elogt=elogt,$
  temps=temps,nbridges=nbridges,do_mapreg=do_mapreg,mapreg=mapreg,pos=pos,$
  tresp=tresp,emcalc=emcalc,doallpix=doallpix,$
  tcont=tcont,DNperT=DNperT,reg_tweak=reg_tweak,$
  sys_err=sys_err, err_max=err_max, sat_lvl=sat_lvl
  
  ; Current version last updated 30-Oct-2012
  ; Full details below but quick examples of code running
  ; assumes input is map stucture ordered by the 6 AIA coronal filters (94,131,171,193,211,335)
  
  
  ; 25-May-2012 IGH - Created the bridge version of the code
  ; 03-Jul-2012 IGH - modified weighting of L (see demmap_broen.pro)
  ; 03-Jul-2012 IGH - returns DN_reg map for comparison to initial data maps
  ; 27-Jul-2012 IGH - added option to return EM [cm^-5] instead of DEM [cm^-5 K^_1]
  ; 12-Nov-2012 IGH - added option to return DN contribution per T (see info below)
  ; 12-Nov-2012 IGH - added option to supply own response function
  ; 12-Nov-2012 IGH - added option to use aia_bp_estimate_error.pro to calculate errors
  ; 16-Nov-2012 IGH - removed bug abee from last version
  ; 18-Nov-2012 IGH - based on dn2dem_map.pro but only does DEM for "good" pixels
  ;                                       (based on err_max and sat_lvl)
  ;                 - added option of systematic error (constant fraction of signal)
  ;                   [make larger if negative solutions]
  ; 20-Jun-2013 IGH - added reg_tweak (desired chisq^2 of solution) as optional input
  ;                  [make larger if negative solutions]
  ; 20-Jun-2013 IGH - new version based on dn2dem_map2.pro
  ;                 - If pos=1 (by default) then uses denmap_broen_pos.pro so that it
  ;                   iterates until gets posive dem (or gives up) by increasing reg_tweak (chisq)
  ;                 - Optional inputs:
  ;                         max_iter (number of iteration to try before giving up)
  ;                         rgt_fact (factor to increase reg_tweak by each iteration)
  ;                         [so max reg_tweak used would be reg_tweak*rgt_fact^max_iter]
  ; 6-Aug-2013 IGH  - modified so that err_max check done before adding sys_err
  ;                 - added do_mapreg so only calculates mapreg when=1
  ; 30-Oct-2013 IGH - modified how the error is calculated now closer to aia_bp_estimate_error.pro
  ;                 - removed /abee to use aia_bp_estimate_error
  ;                 - /doallpix flags added to ignore err_max and sat_lvl options
  ;                   (i.e. does all pixels irrespective of quality)
  
  ;-------------------------------------------------------------------------------------
  ; INPUTS;
  ; map       - map stucture ordered by the 6 AIA coronal filters ;i.e.
  ;              IDL> for i=0, 5 do print,map[i].id
  ;              SDO AIA_4 94
  ;              SDO AIA_1 131
  ;              SDO AIA_3 171
  ;              SDO AIA_2 193
  ;              SDO AIA_2 211
  ;              SDO AIA_1 335
  ;              with map.data in units of DN/px
  ;
  ;              This can be generated in many ways, such as from level 1 files:
  ;              f=findfile('*.fits')
  ;              aia_prep,f,-1,ind,data
  ;              reord=sort(ind.wavelngth)
  ;              IDL> print[reord],ind.wavelnth
  ;                        94         131         171         193         211         335
  ;              index2map,ind[reord],data[*,*,reord],map_in
  ;              sub_map,map_in,map,xrange=[-100,100],yrange=[-100,100]
  ;
  ;OPTIONAL INPUTS;
  ; temps     - array with edges of temperature bins
  ; nbridges  - (default 1) number of bridge/cpu cores to use <  !CPU.HW_NCPU
  ; tresp     - AIA temperature response structure of just the filters matching the input data
  ;              structure with: tresp.logte(ntt), tresp.all(ntt,nf) and tresp.channels(nf)
  ; emcalc    - returns in the output (dem, edem) as EM [cm^-5] not DEM [cm^-5 K^_1]
  ; tcont     - returns into DNperT(x,y,T,f)=R(x,y,*,f)*DEMREG(x,y,T)
  ;                   useful for working out what part of DEM contributes to DN in each filter
  ; sys_err   - systematic error which is fraction of DN/s/px (default 0) used instead of abee
  ; doallpix  - ignore err_max and sat_lvl and just do all the pixels
  ; err_max   - maximum value of error/data (1/SNR) accepetable (default 1/3)
  ; sat_lvl   - above this value consider pixel saturated and don't use (default 1.5e4)
  ; do_mapreg - do you want the regularized AIA maps produced? (default 0)
  
  ;
  ; OUTPUTS:
  ;   dem         - fltarr(nx,ny,nt) with DEM result per pixel (or EM if emcalc chosen)
  ;   chisq       - fltarr(nx,ny) chisq of DEM results per pixel
  ;   edem        - fltarr(nx,ny,nt) vertical error in DEM per pixel
  ;   elogt       - fltarr(nx,ny,nt) horizontal error per pixel
  ;   mapreg      - AIA maps of what the reg DEM produces per pixel
  ;   DNperT      - fltarr(nx,ny,nt,nf) contribution to DN in each filter as function of T
  ;
  ; *****Note that if this is run in the delevopment environment the bridge status is outputted
  ; to the source terminal, not the DE prompt.
  ;
  
  
  if (n_elements(temps) lt 7) then temps=[0.5,1,1.5,2,3,4,6,8,11,14,19,25,32]*1e6
  logT0=get_edges(alog10(temps),/mean)
  nt=n_elements(logt0)
  
  if (n_elements(abee) lt 1) then abee=0
  if (n_elements(err_max) lt 1) then err_max=1/3.
  if (n_elements(sat_lvl) lt 1) then sat_lvl=1.5e4
  if (n_elements(sys_err) lt 1) then sys_err=0
  if (n_elements(do_mapreg) lt 1) then do_mapreg=0
  if (n_elements(reg_tweak) lt 1) then reg_tweak=1.0
  if (n_elements(pos) lt 1) then pos=1
  if keyword_set(pos) then bcode='demmap_broen_pos' else bcode='demmap_broen2'
  
  if (n_elements(max_iter) lt 1) then max_iter=10
  if (n_elements(rgt_fact) lt 1) then rgt_fact=1.5
  
  tstart=systime(1)
  
  na=n_elements(map[0].data[*,0])*1.
  nb=n_elements(map[0].data[0,*])*1.
  nf=n_elements(map.data[0,0])
  
  dd=map.data*1.
  dur=map.dur
  ; puts the data in DN/s as maps in DN
  for i=0, nf-1 do dd[*,*,i]=dd[*,*,i]/dur[i]
  
  ; workout the error on the data
  ed=fltarr(na,nb,nf)
  gains=[18.3,17.6,17.7,18.3,18.3,17.6]
  dn2ph=gains*[94,131,171,193,211,335]/3397.
  rdnse=[1.14,1.18,1.15,1.20,1.20,1.18]
  ; error in DN/s/px
  for i=0, nf-1 do begin
    shotnoise=sqrt(dn2ph[i]*abs(dd[*,*,i])*dur[i])/dn2ph[i]
    ed[*,*,i]=sqrt(rdnse[i]^2.+shotnoise^2.)/dur[i]
  endfor
  
  good=bytarr(na,nb)
  if keyword_set(doallpix) then begin
    ; do all the pixels irrespective of their "quality"
    ; well except for negative ones.
    for i=0,na-1 do begin
      for j=0,nb-1 do begin
        idgd=where(dd[i,j,*] gt 0.,ngd)
        if (ngd eq 6) then good[i,j]=1 else good[i,j]=0
      endfor
    endfor
  endif else begin
    ; don't want saturated or low snr
    for i=0,na-1 do begin
      for j=0,nb-1 do begin
        idgd=where(ed[i,j,*]/dd[i,j,*] lt err_max and dd[i,j,*]*dur lt sat_lvl $
          and dd[i,j,*] gt 0.,ngd)
        if (ngd eq 6) then good[i,j]=1 else good[i,j]=0
      endfor
    endfor
  endelse
  
  dopx=where(good eq 1,ndopx)
  
  ; no point doing this if no good pixels
  if (ndopx gt 0) then begin
  
    gd_ind2d=array_indices(good,dopx)
    
    ddgd=dblarr(ndopx,nf)
    edgd=dblarr(ndopx,nf)
    demgd=fltarr(ndopx,nt)
    chisqgd=fltarr(ndopx)
    edemgd=fltarr(ndopx,nt)
    elogtgd=fltarr(ndopx,nt)
    dn_reggd=fltarr(ndopx,nf)
    
    for i=0, nf-1 do begin
      dd_temp=reform(dd[*,*,i])
      ed_temp=reform(ed[*,*,i])
      ddgd[*,i]=dd_temp[dopx]
      ; add in the systematic error now
      edgd[*,i]=ed_temp[dopx]+sys_err*dd_temp[dopx]
    endfor
    
    ;######## are you providing the tresp or do I have to calculate it? ###############
    if datatype(tresp,1) ne 'Structure' then begin
    
      resp_file=file_search('aia_resp_chi.dat')
      if strlen(resp_file) eq 0 then begin
        eff=aia_get_response(/temperature,/dn,/chiantifix,/evenorm)
        save,file='aia_resp_chi.dat',eff
      endif else  begin
        restore,file='aia_resp_chi.dat'
      endelse
      
      ; Don't want 304 from the default response
      idc=[0,1,2,3,4,6]
      logT25=eff.logte
      Rmatrix25=eff.all[*,idc]
    endif else begin
      logT25=tresp.logte
      Rmatrix25=tresp.all
    endelse
    
    ; finds the DEM at the midpoint of the temperature bins in LOG10 space
    
    TR=dblarr(nt,nf)
    for i=0, nf-1 do TR(*,i)=interpol(Rmatrix25(*,i), logT25, logT0)
    
    dem=fltarr(na,nb,nt)
    chisq=fltarr(na,nb)
    edem=fltarr(na,nb,nt)
    elogt=fltarr(na,nb,nt)
    dn_reg=fltarr(na,nb,nf)
    
    logT=logT0
    dlogT=logT[1:nT-1]-logT[0:nT-2]
    dlogT=[dlogT,dlogT[nt-2]*0.5]
    ltt=min(logt)+(max(logt)-min(logt))*findgen(51)/(51-1.0)
    RMatrix=dblarr(nT,nF)
    RMatrixin=dblarr(nT,nF)
    
    ;######## sort out the whole integration over T not logT ################
    for i=0, nF-1  do RMatrix[*,i]=TR[*,i]*10d^logT*alog(10d^dlogT)
    RMatrix=RMatrix*1d20
    ;####### Calculate initial constraint matrix #############################
    L=fltarr(nT,nT)
    Lorg=L
    for i=0, nT-1 do Lorg[i,i]=1.0/sqrt(dlogT[i])
    
    nmu=42; but of course
    ;##################### loop over the data #############################
    ;###############################################################
    ;###############################################################
    tnow=systime(1)
    ;###############################################################
    max_threads=!CPU.HW_NCPU
    
    if (n_elements(nbridges) ne 1) then nbridges=1
    nbridges=nbridges < max_threads
    mt_obj = objarr(nbridges)
    npts=long(ndopx);long(na)
    if nbridges gt 1 then begin
      start_i = LINDGEN(nbridges) * npts / nbridges
      stop_i  = [start_i[1:*] - 1L, npts-1]
    endif else begin
      start_i = 0L
      stop_i  = npts-1
    endelse
    
    cd,current=cwd
    
    ; set everything up
    for i=0, nbridges-1 do begin
    
      ddin=ddgd[start_i[i]:stop_i[i],*]
      edin=edgd[start_i[i]:stop_i[i],*]
      num_chunk=stop_i[i]-start_i[i]+1
      
      outname='';'out_'+string(1000+i,format='(i4)')+'.txt'
      mt_obj[i] = OBJ_NEW('IDL_IDLBridge',output=outname)
      mt_obj[i]->Execute,'cd,"'+cwd+'"'
      mt_obj[i]->Execute, '.r demmap_broen'
      
      mt_obj[i]->SetVar,'ddin',ddin
      mt_obj[i]->SetVar,'edin',edin
      mt_obj[i]->SetVar,'RMatrix',Rmatrix
      mt_obj[i]->SetVar,'Lorg',Lorg
      mt_obj[i]->SetVar,'logt',logt
      mt_obj[i]->SetVar,'i',i
      mt_obj[i]->SetVar,'reg_tweak',reg_tweak
      mt_obj[i]->SetVar,'max_iter',max_iter
      mt_obj[i]->SetVar,'rgt_fact',rgt_fact
      
      ; then run the code on each child process
      mt_obj[i]->Execute,bcode+$
        ',ddin,edin,RMatrix,Lorg,logt,i,demout,chisqout,edemout,elogtout,dn_reg,reg_tweak='$
        +strcompress(string(reg_tweak),/rem)$
        +',max_iter='+strcompress(string(max_iter),/rem)$
        +',rgt_fact='+strcompress(string(rgt_fact),/rem)$
        ,/nowait
    endfor
    
    busy=1
    stat=intarr(nbridges)
    ; wait till everything is finished
    while(busy ne 0) do begin
    
      for i=0, nbridges-1 do stat[i]=mt_obj[i]->Status()
      ; change the test to until completed instead of when idle?
      busy=total(stat)
      ; don't want testing status all the time
      if (busy ne 0) then wait,0.1
    endwhile
    
    tend=systime(1)
    print,'nbridges: ',string(nbridges,format='(i3)'),' gives ',$
      string((na*nb*1.)/(tend-tnow),format='(f9.1)'), ' DEM/s'
      
    ; get the results from the child processes
    for i=0, nbridges-1 do begin
      demgd[start_i[i]:stop_i[i],*]=mt_obj[i]->GetVar('demout')
      chisqgd[start_i[i]:stop_i[i],*]=mt_obj[i]->GetVar('chisqout')
      edemgd[start_i[i]:stop_i[i],*]=mt_obj[i]->GetVar('edemout')
      elogtgd[start_i[i]:stop_i[i],*]=mt_obj[i]->GetVar('elogtout')
      dn_reggd[start_i[i]:stop_i[i],*]=mt_obj[i]->GetVar('dn_reg')
    endfor
    
    for i=0, nbridges-1 do obj_destroy, mt_obj[nbridges-1-i]
    
    ; put the gd pixels back into the full maps
    for i=0, ndopx-1 do begin
      idx=gd_ind2d[0,i]
      idy=gd_ind2d[1,i]
      dem[idx,idy,*]=demgd[i,*]
      edem[idx,idy,*]=edemgd[i,*]
      elogt[idx,idy,*]=elogtgd[i,*]
      dn_reg[idx,idy,*]=dn_reggd[i,*]
      chisq[idx,idy]=chisqgd[i]
    endfor
    
    ;###############################################################
    ;###############################################################
    ;###############################################################
    if keyword_set(Tcont) then begin
      ;############ Create DNperT maps ######################################
      ; Total over T for each DNperT(x,y,f)=dem_reg signal in that filter and postion
      DNperT=fltarr(na,nb,nt,nf)
      for i=0,na-1 do begin
        for j=0,nb-1 do begin
          for k=0,nf-1 do begin
            DNperT(i,j,*,k)=Rmatrix[*,k]*dem[i,j,*]
          endfor
        endfor
      endfor
    endif
    
    ;########### Put final DEM and eDEM in proper units #########################
    dem=float(dem*1e20)
    edem=float(edem*1e20)
    elogt=float(elogt/(2.0*sqrt(2.*alog(2.))))
    chisq=float(chisq)
    
    if keyword_set(emcalc) then begin
      lgt=alog10(temps)
      nt=n_elements(lgt)-1
      dlgT=lgt[1:nt]-lgt[0:nt-1]
      factor=nt*10d^lgt*alog(10d^dlgt)
      for i=0, nt-1 do dem[*,*,i]=dem[*,*,i]*factor[i]
      for i=0, nt-1 do edem[*,*,i]=edem[*,*,i]*factor[i]
    endif
    
    ;############ Create DN reg maps ? ######################################
    if keyword_set(do_mapreg) then begin
      mapreg=map
      mapreg.data=dn_reg
      ; sort out that dn_reg in units of DN/s but maps in DN
      for i=0, nf-1 do mapreg[i].data=mapreg[i].data*mapreg[i].dur
      mapreg.id=mapreg.id+'; REG'
    endif
    
  endif else begin
    print, 'No "good pixels"!'
  endelse
  
end



