;	DEM_map test

;	----------------------------------
	;how many pictures of time need to calculate in the whole event
	pictures=16
	;set the length of the squre side
	length=800
	;set the start point
	x_start=1
	y_start=1001
;	----------------------------------

	;
	tresp=aia_get_response(/temperature, /dn, /chiantifix, /evenorm)	;chiantifix database

	;start the for loop
	for a=16, pictures do begin

	;load and calibrate file
	files = file_search('~/Final_Project/20101103_1212/data/' + $
	string(a, '(I0)') + path_sep() + '*.fits')
;	read_sdo, files, ind, da
;	aia_prep, ind, da, index, data
	read_sdo, files, index, data
	;reorder the index with wavelength in order
	index_wave = index.wavelnth
	index_reorder = index[sort(index_wave)]
	;reorder the data with wavelength in order
	data_reorder = data[*, *, sort(index_wave)]
	;choose the target range of map with parameters setting
	data_target = data_reorder[x_start : x_start+length, y_start : y_start+length,*]
	;transfer data to map
	index2map, index_reorder, data_target, data_map

	;;target_data[*,*,0] - data_map[0].data = 0

	;restore final_EM_map.dat
	restore, file="final_EM_map_16.dat"

	;response function
	restore, file="DEM_map_tresp_function.dat"

	;recover
	data_recover = lindgen( length+1, length+1, 6 )
	for i=0, length do begin
	for j=0, length do begin
		data_recover[i,j,*]  = tresp_function # transpose( final_EM_map[i,j,*] )
	endfor
	endfor

	;end loop of a 
	endfor

	;output result
	DEM_per = make_array( 11, 11, 6 )

	area_re = data_recover[300:310,400:410,*]
	area_ori = data_target[300:310,400:410,*]
	area_per = ( area_re - area_ori ) / area_ori

	print, area_per

end
