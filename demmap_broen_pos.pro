pro demmap_broen_pos,dd,ed,RMatrix,Lorg,logt,th_id,dem,chisq,edem,elogt,dn_reg,$
  reg_tweak=reg_tweak,max_iter=max_iter,rgt_fact=rgt_fact
  
  ; Each child process called by dn2dem_map which actually does the DEM calculation
  ; 25-May-2012 IGH
  ; 03-Jul-2012 IGH -  changed DEM weighting as to not used smoothed & sqrt version
  ; 03-Jul-2012 IGH - now returns dn_reg to be used to produce DN_reg maps
  ;18-Nov-2012 IGH - updated version of demmap_broen.pro but works with 2D (px vs ft)
  ;                                     instead of 3D (x,y,FT) input from fn2dem_map2.pro
  ;20-Jun-2013 IGH - added reg_tweak (desired chisq of solution) as optional input
  ;
  ;20-Jun-2013 IGH - new version based on demmap_broen2.pro
  ;                  Iterates until gets posive dem (or gives up) by increasing reg_tweak (chisq)
  ;                  Optional inputs:
  ;                         max_iter (number of iteration to try before giving up)
  ;                         rgt_fact (factor to increase reg_tweak by each iteration)
  ;                         [so max reg_tweak used would be reg_tweak*rgt_fact^max_iter]
  
  na=n_elements(dd[*,0])
  nf=n_elements(RMatrix[0,*])
  nt=n_elements(logt)
  dem=dblarr(na,nt)
  edem=dblarr(na,nt)
  elogt=dblarr(na,nt)
  RMatrixin=dblarr(nt,nf)
  kdag=dblarr(nf,nt)
  filter=dblarr(nf,nt)
  chisq=dblarr(na)
  kdagk=dblarr(nt,nt)
  dn_reg=dblarr(na,nf)
  
  dlogT=logT[1:nT-1]-logT[0:nT-2]
  dlogT=[dlogT,dlogT[nt-2]*0.5]
  ltt=min(logt)+(max(logt)-min(logt))*findgen(51)/(51-1.0)
  
  if (n_elements(reg_tweak) ne 1) then reg_tweak=1
  if (n_elements(max_iter) ne 1) then max_iter=10
  if (n_elements(rgt_fact) ne 1) then rgt_fact=1.5
  
  nmu=42 ; but of course
  
  for i=0, na-1 do begin
    L=Lorg
    dnin=reform(dd[i,*])
    ednin=reform(ed[i,*])
    
    RMatrixin[*,0]=RMatrix[*,0]/eDNin[0]
    RMatrixin[*,1]=RMatrix[*,1]/eDNin[1]
    RMatrixin[*,2]=RMatrix[*,2]/eDNin[2]
    RMatrixin[*,3]=RMatrix[*,3]/eDNin[3]
    RMatrixin[*,4]=RMatrix[*,4]/eDNin[4]
    RMatrixin[*,5]=RMatrix[*,5]/eDNin[5]
    
    dn=dnin/ednin
    edn=ednin/ednin
    
    if (dn[0] ne 0. and dn[1] ne 0. and dn[2] ne 0. and dn[3] ne 0. $
      and dn[4] ne 0. and dn[5] ne 0.) then begin
      
      ; reset the
      ndem=1
      piter=0
      rgt=reg_tweak
      
      ; ######## Still don't have a positive DEM_reg (or reached max_iter?) ########
      while(ndem gt 0 and piter lt max_iter) do begin
        ;################ Work out the 1st DEM_reg ###########################
        
        dem_inv_gsvdcsq,RMatrixin,L,Alpha,Betta,U,V,W
        dem_inv_reg_parameter_map,Alpha,Betta,U,W,DN,eDN,rgt,opt,nmu
        for kk=0, nf-1 do filter[kk,kk]=alpha[kk]/(alpha[kk]*alpha[kk]+$
          betta[kk]*betta[kk]*opt)
        kdag=W##matrix_multiply(U[0:nf-1,0:nf-1],filter,/atrans)
        DEM_reg=reform(kdag##dn)
        
        ;################ Use first DEM_reg to weight L ###########################
        ;################ Then calculate final DEM_reg ###########################
        
        DEM_reg=DEM_reg *(DEM_reg gt 0)+1e-4*max(DEM_reg)*(DEM_reg lt 0)
        DEM_reg=smooth(DEM_reg,3)
        for kk=0, nt-1 do L[kk,kk]=sqrt(dlogT[kk])/sqrt(abs(dem_reg[kk]))
        ; or is this a better with, with no smooth of DEM_reg??
        ;for kk=0, nt-1 do L[kk,kk]=sqrt(dlogT[kk])/abs(dem_reg[kk])
        dem_inv_gsvdcsq,RMatrixin,L,Alpha,Betta,U,V,W
        dem_inv_reg_parameter_map,Alpha,Betta,U,W,DN,eDN,rgt,opt,nmu
        
        ;################ Work out the inverse of K (Rmatrixin) ####################
        for kk=0, nf-1 do filter[kk,kk]=alpha[kk]/(alpha[kk]*alpha[kk]+$
          betta[kk]*betta[kk]*opt)
        kdag=W##matrix_multiply(U[0:nf-1,0:nf-1],filter,/atrans)
        
        ;################ Work out the final DEM_reg ####################
        
        DEM_reg=reform(kdag##dn)
        
        ; Is any of this solution negative?????
        nn=where(DEM_reg lt 0, ndem)
        rgt=rgt_fact*rgt
        piter=piter+1
        
      endwhile
      ;############ if positive or reached max_iter work rest out ############
      
      dem[i,*]=DEM_reg
      dn_reg0=reform(rmatrix##DEM_reg)
      dn_reg[i,*]=dn_reg0
      residuals=(dnin-dn_reg0)/ednin
      chisq[i]=total(residuals^2)/(nf)
      
      ;################ Do the error calcualtion ######################
      
      ; Error matrix for eDEM
      delxi2=matrix_multiply(kdag,kdag,/atrans)
      edem[i,*]=sqrt(diag_matrix(delxi2))
      
      ; Resolution matrix for elogt
      kdagk=kdag##rmatrixin
      
      for kk=0, nt-1 do begin
        rr=interpol(transpose(kdagk[kk,*]),logt,ltt)
        ; where is the row bigger than the half maximum
        hm_index=where(rr ge max(kdagk[kk,*])/2.,nhmi)
        elogt[i,kk]=dlogt[kk]
        if (nhmi gt 1) then $
          elogt[i,kk]=(ltt[max(hm_index)]-ltt[min(hm_index)]) >dlogt[kk]
      endfor
         
    endif
    if ((i mod 1000) eq 0)  then print,'Bridge ',string(th_id+1, format='(i3)'),':  ',i,$
      ' of ',string(na,format='(i8)')
  endfor
  
end