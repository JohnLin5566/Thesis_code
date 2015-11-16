;	DEM reg method to make DEM map with chianti database
;	ssw017
	
	;----------- parameters setting ----------------
	
	;how many pictures of time need to calculate in the whole event
	times=66

	;set the length of the squre side
	length=800
	
	;set the start point
	x_start=1
	y_start=1001
		     
	;-------------- calculate the DEM map -----------------

	;road the aia response function
	aia_resp=aia_get_response(/temperature,/dn,/chiantifix,/evenorm)

	;start the for loop
	for a=27, times do begin

	;load and calibrate file
	files = file_search('~/ResultAndData/Final_Project/20101103_1212/data/' + $
	string(a, '(I0)') + path_sep() + '*.fits')

	read_sdo, files, index, data
	aia_prep, files, -1, index, data
	
	;reorder the index with wavelength in order
	index_wave=index.wavelnth
	index_reorder=index[sort(index_wave)]

	;reorder the data with wavelength in order
	data_reorder=data[*, *, sort(index_wave)]

	;choose the target range of map with parameters setting
	target_data=data_reorder[x_start : x_start+length, y_start : y_start+length,*]

	;transfer data to map
	index2map, index_reorder, target_data, data_map

	;calculate DEM_map
	dn2dem_map_pos, data_map, DEM_map, chisq, pos=1, $
	doallpix=1, edem=edem_map, elogt=elogt_map, nbridges=6, /tcont, DNperT=dpt

	;make a chk_DEM_map for constrainting the DEM_map
	chk_DEM_map=(eDEM_map/DEM_map le 0.3) and (elogT_map le 0.25)
	final_DEM_map=DEM_map*chk_DEM_map

	;make the EM_map, EEM_map, amd temps array
	EM_map=make_array(length + 1, length + 1, 12)
	eEM_map=make_array(length + 1, length + 1, 12)
	temps=[0.5,1,1.5,2,3,4,6,8,11,14,19,25,32]*1e6
	
	;calculate the EM_map, EEM_map
	lgt=alog10(temps)
	nt=n_elements(lgt)-1
	dlgT=lgt[1:nt]-lgt[0:nt-1]
	factor=nt*10d^lgt*alog(10d^dlgt)
	for i=0, nt-1 do EM_map[*,*,i]=DEM_map[*,*,i]*factor[i]
	for i=0, nt-1 do eEM_map[*,*,i]=eDEM_map[*,*,i]*factor[i]

	;make a chk_EM_map for constrainting the EM_map, and calculate the final_EM_map
	chk_EM_map=(eEM_map/EM_map le 0.3)
	final_EM_map=EM_map*chk_EM_map

	;save the results in dat file
	path=string('~/ResultAndData/Final_Project/20101103_1212/result/DEM_map_chi/')
	times_number=string(a, '(I0)')

	save, DEM_map, 		filename = path + "DEM_map_" 		+ times_number + ".dat"
	save, eDEM_map, 	filename = path + "eDEM_map_" 		+ times_number + ".dat"
	save, elogt_map, 	filename = path + "elogt_map_"	 	+ times_number + ".dat"
	save, chk_DEM_map, 	filename = path + "chk_DEM_map_" 	+ times_number + ".dat"
	save, final_DEM_map, 	filename = path + "final_DEM_map_" 	+ times_number + ".dat"
	save, EM_map, 		filename = path + "EM_map_" 		+ times_number + ".dat"
	save, EEM_map, 		filename = path + "eEM_map_" 		+ times_number + ".dat"
	save, final_EM_map, 	filename = path + "final_EM_map_" 	+ times_number + ".dat"
	save, chisq,            filename = path + "chisq_"              + times_number + ".dat"
	save, dpt,              filename = path + "DNperT_"             + times_number + ".dat"

	print, a


	endfor

END
