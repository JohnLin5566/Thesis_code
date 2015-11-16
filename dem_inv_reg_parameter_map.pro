; NAME:
;   dem_inv_reg_parameter
;
; PURPOSE:
;   to compute regularization parameter
;
; CALLING SEQUENCE:
;
;  dem_inv_reg_parameter,sigmaA,SigmaB,U,W,Data,Err,dem_guess,reg_tweak,opt
;
; CALLS:
;   none
;
; INPUTS:
;  SigmaA 	- vector, generalised singular values
;  SigmaB 	- vector, generalised singular values
;  U      		- matrix, GSVD matrix
;  W      		- matrix, GSVD matrix
;  Data   		- vector, containing data (eg dn)
;  Err    		- vector, uncertanty on data (same units and dimension)
; reg_tweak	-scalar, parameter to adjusting regularization (chisq)
; num     - scale, number of samplesi n log-reg parm space for solution
;
; OPTIONAL INPUTS:
;   none
;
; OUTPUTS:
;    opt -  regularization parameter
;
; OPTIONAL OUTPUTS:
;   none
;
; KEYWORDS:
;   none
;
; COMMON BLOCKS:
;   none
;
; SIDE EFFECTS:
;
;
; RESTRICTIONS:
;
;
; MODIFICATION HISTORY:
;   eduard(at)astro.gla.ac.uk, 23 May, 2005
;   16- Sept-2005: now plots to display and eps files
;  21-Jul-2011	Program and Variable names changed    IGH
;  21-Jul-2011	Commented out plotting of picard condition IGH
;- 30-Apr-2012  Speed increase by using lower nmu
;  17-May-2012  mu range based on (sigmaa/sigmab)^2 instead of (sigmaa/sigmab) 


pro dem_inv_reg_parameter_map,sigmaA,SigmaB,U,W,Data,Err,reg_tweak,opt,nmu
;calculates regularisation parameter

 if (n_elements(nmu) lt 1) then nmu=500

 Ndata=n_elements(Data)
 Nreg =n_elements(SigmaA)

 arg=dblarr(Nreg,Nmu)
 discr=dblarr(Nmu)

 maxx=max(SigmaA[0:ndata-1]/SigmaB[0:ndata-1])
 minx=min(SigmaA[0:ndata-1]/SigmaB[0:ndata-1])^2.*1d-2
 
 step=(alog(maxx)-alog(minx))/(Nmu-1.)
 mu=exp(findgen(Nmu)*step)*minx

 for k=0,Ndata-1 do begin
	coef=data##u[k,*]-SigmaA[k]
	for i=0,Nmu-1 do begin
		arg[k,i]=(mu[i]*SigmaB[k]*SigmaB[k]*coef/$
		    (SigmaA[k]*SigmaA[k]+mu[i]*SigmaB[k]*SigmaB[k]))^2
	end
 end

discr=total(arg,1)-total(err*err)*reg_tweak

minimum=min(abs(discr),Min_index)
opt=mu[Min_index]

;plot,mu,abs(discr),/xlog,/ylog

end

