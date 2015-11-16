; test DEM_reg with observation data, plot the RK matrix


;-------------parameters setting--------------------

	;select the observation data
	length  = 2.
	x_start = 322
	y_start = 1414

	ord = 0
	re = 1.
	gu = 0
	pos = 0

;----------------------------------------------------

	tresp=aia_get_response(/temperature, /dn, /chiantifix, /evenorm)
;	tresp=aia_get_response(/temperature, /dn)

	;get the channels order and set the TRmartix and logT
	filt=[0,1,2,3,4,6]
	TRmatrix=tresp.all[*,filt]
	logT=tresp.logte

	;load file
	files = file_search('~/Final_Project/20101103_1212/data/16/*fits')
	read_sdo, files, ind, da
	aia_prep, ind, da, index, data

	;select the target data
	data_target = data[x_start : x_start+length-1, y_start : y_start+length-1,*]

	;reorder the data with wavelength order
	wave_order = index.wavelnth
	data_reorder = data_target[*, *, sort(wave_order)]

	;sum all data with individual wavelength
	data_total = make_array(6)
	for i=0, length-1 do for j=0,length-1 do data_total = data_total + data_reorder[i, j, *]

	;average the data with pixel*pixel
	data_final = make_array(6)
	data_final = data_total / ( length*length )

	;data noise with stddev
	data_noise = make_array(6)
	for d=0, 5 do data_noise[d] = stddev( data_reorder[*, *, d] )

	;calculate DEM_reg
	reg =	data2dem_reg(logT, TRmatrix, data_final, data_noise, $
		channels=tresp.channels[filt], $
		order=ord, reg_tweak=re, guess=gu, gloci=1, pos=pos)
	
	;calculate rk matrix
	rn = reg.rk
	final_rn = make_array(33, 33)
	for i=0, n_elements(reg.logt)-1 do final_rn[i, *] = rn[i, *]/max( rn[i, *] )
	
	;recover original value
	K_resp=make_array(6, 33)
	K_resp[0, *]=tresp.a94.tresp[34:66]
	K_resp[1, *]=tresp.a131.tresp[34:66]
	K_resp[2, *]=tresp.a171.tresp[34:66]
	K_resp[3, *]=tresp.a193.tresp[34:66]
	K_resp[4, *]=tresp.a211.tresp[34:66]
	K_resp[5, *]=tresp.a335.tresp[34:66]

	;recover original value, get the EM(emission measure) first
	lgT = tresp.logte[34:67]		;logT
	T = 10^lgT				;T = 10 ^logT 
	dT = T[1:33] - T[0:32]			;dT = t[i+1] - t[i-1]
	EM = reg.dem * dT			;em = dem * dT
	re_data = K_resp # EM			;g = K_resp * dem * dT

	;data noise percentage
	noise_per = ( data_noise/data_final )*100

	;error percentage
	re_diff_per = ( ( re_data - data_final ) / data_final ) *100
	tot_sq_per = total( re_diff_per*re_diff_per )

	;output the results
	print, "order = ", ord
	print, "reg_tweak = ", re
	print, "geuss = ", gu
	print, "pos = ", pos
	print, "chisq = ", reg.chisq
	print, "origianl data = ", data_final
	print, "data noise(stddev) = ", data_noise
	print, "noise percentage = ", noise_per
	print, "recover data = ", re_data
	print, "error percentage = ", re_diff_per
	print, "sum of square of per = ", tot_sq_per

	;plot rk matrix
	loadct, 8, /silent
	gamma_ct, 2.
	window,0,xsize=500,ysize=500,title='RK Matrix'

	image_tv, transpose(final_rn), reg.logt, reg.logt, ytitle='Temperature Bin'
	oplot, [0, 20], [0, 20]

	;plot logT-DEM figrue
	window,1 ,xsize=500 ,ysize=500, title="logT-DEM figure"
	plot, reg.logt, reg.dem


end
