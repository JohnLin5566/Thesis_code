; DEM_reg.pro

	;----------------------
	length = 2
	pixels = 4
	x_ = 1
	y_ = 1001
	;----------------------

	
	;two picture need to calculate
	for a = 1, 2 do begin
	case a of 
	1:	times = 1 
	2:	times = 16
	endcase
	
	;4 pixels need to calculate
	for b = 1, pixels do begin
	case b of 
	1:	begin
		x_start	= x_ + 233
		y_start	= y_ + 352
		end
	2:	begin
		x_start	= x_ + 302
		y_start	= y_ + 406
		end
	3:	begin
		x_start	= x_ + 382
		y_start	= y_ + 437
		end
	4:	begin
		x_start	= x_ + 515
		y_start	= y_ + 453
		end
	;end for case
	endcase
	
	;-------------- calculate the DEM reg -----------------

	;Get the sdo/aia temperature responses
	tresp=aia_get_response(/temperature, /dn, version=7, /evenorm)

	;get the channels order and set the TRmartix and logT
	filt=[0,1,2,3,4,6]
	TRmatrix=tresp.all[*,filt]
	logT=tresp.logte

	;find the files
	files = file_search('~/ResultAndData/Final_Project/20101103_1212/data/' + $
	string( times, '(I0)') + path_sep() + '*.fits')

	;load and calibrate images
;	read_sdo, files, ind, da
;	aia_prep, ind, da, index, data
	read_sdo, files, index, data

	;select the target data
	data_target = data[x_start : x_start+length-1, y_start : y_start+length-1,*]

;	print, data_target
;	stop

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
	for d=0, 5 do data_noise[d] = stddev( data_reorder[*, *, d] ) + 1

	;calculate DEM reg with for loop
	reg = 	data2dem_reg(logT, TRmatrix, data_final, data_noise, $
		channels=tresp.channels[filt], $
		order=2, reg_tweak=1.0, guess=2, gloci=0, pos=0 )

	;save the results
	path_to_save=string('~/ResultAndData/Final_Project/20101103_1212/result/DEM_reg_chi/')
	times_number = string(times, '(I0)')
	pixel_number = string(b, '(I0)')

	;filename : DEM_reg_{time}_{pixel}.dat
	save, reg, filename = path_to_save+"DEM_reg_"+times_number+"_"+pixel_number+".dat"

	endfor
	endfor
end
