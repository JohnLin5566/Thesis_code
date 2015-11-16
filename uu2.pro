; test DEM_reg with aritifical data, plot the RK matrix


;	------------parameter setting-------------------

;	random_p = randomu(seed, 6)*0.1   ;random_percentage
	a_length = 3				;order = 0, 1, 2, ( a_length = 3 )
	b_length = 3				;guess = 0, 1, 2, ( b_length = 3 )
	c_length = 3				;reg_tweak = 0.5 + 0.5*c
	d_length = 10				;random noise times
	pos = 0					;postive solution
	data_original = [ 30,90,650,2600,1600,100  ]
	file_name = "set_2.dat"

;	-------------------------------------------------

	result = replicate( { calculate_result, $
		order:0, guess:0, reg_tweak:0., pos:0, $
		random_p:findgen(6), data_final:findgen(6), $
		logt:dindgen(33), DEM:dindgen(33), elogt:dindgen(33), eDEM:dindgen(33), $
		rk_final:dindgen(33, 33), data_recover:findgen(6), recover_per:findgen(6), chisq:0.} , $
		a_length, b_length, c_length, d_length )

	;order
	for a = 0, a_length-1 do begin
	;guess times
	for b = 0, b_length-1 do begin
	;reg_tweak
	for c = 0, c_length-1 do begin
	;every fixed reg_tweak, with d times random noise of data
	for d = 0, d_length-1 do begin

	ord = a								;order
	gu = b								;guess
	re = 0.5 + 0.5 * c						;reg_tweak
	random_p = randomu(seed, 6)*0.1 	 			;random_percentage
	data_final = data_original 					;input data * random_percentage
	noise_factor = random_p						;input data * noise

;	---------------------------------------------------

	tresp=aia_get_response(/temperature, /dn, /chiantifix, /evenorm);chiantifix database
	;get the channels order and set the TRmartix and logT
	filt=[0,1,2,3,4,6]
	TRmatrix=tresp.all[*,filt]
	logT=tresp.logte

	;use the first data and the first reg structure to make an array for store the results
	reg =	data2dem_reg(logT, TRmatrix, data_final, data_final*noise_factor+1, $
		channels=tresp.channels[filt], $
		order=ord, reg_tweak=re, guess=gu, gloci=0, pos=pos)

	;calculate rk matrix
;	rk = reg.rk
;	rk_final= make_array(33, 33)
;	for i=0, n_elements(reg.logt)-1 do rk_final[i, *] = rk[i, *]/max( rk[i, *] )

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
	dT = T[1:33] - T[0:32]			;dT = T[i+1] - T[i-1]
	reg_eDEM = reg.edem			;eDEM
	reg_elogT = reg.elogt			;elogT
	reg_dem = reg.dem			;DEM
	EM = reg.dem * dT			;em = dem * dT
	data_re = K_resp # EM			;g = K_resp * dem * dT
	per = ( data_re - data_final ) / data_final

	;save the output data
	result[a,b,c,d].order = a
	result[a,b,c,d].guess = b
	result[a,b,c,d].reg_tweak = re
	result[a,b,c,d].pos = pos
	result[a,b,c,d].random_p = random_p
	result[a,b,c,d].data_final = data_final
	result[a,b,c,d].logT = reg_elogT
	result[a,b,c,d].DEM = reg_dem
	result[a,b,c,d].elogT = reg_elogT
	result[a,b,c,d].eDEM = reg_eDEM
	result[a,b,c,d].data_recover = data_re
	result[a,b,c,d].recover_per = per

;	result[a,b,c,d].chisq = reg.chisq
;	result[a,b,c,d].rk_final = rk_final

	print, a, b, c, d

	endfor
	endfor
	endfor
	endfor

	path_to_save = string('~/ResultAndData/Final_Project/20101103_1212/result/reg_test/')
	save, result, file = path_to_save + file_name

end
