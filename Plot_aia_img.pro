;	Plot aia image

	device, decomposed=0
	!p.charsize = 1.6
	!x.omargin=1
	!y.omargin=1

;	------------------------------------------
	;how many time point 
	times = 66
	;set the length of the squre side
	length = 800
	;set the start point
	x_start = 1
	y_start = 1001
	
;	------------------------------------------

	;how many time point in the a for loop
	for a = 1, times do begin

	;load the image data
	path_to_restore = "~/ResultAndData/Final_Project/20101103_1212/data/"
	files = file_search( path_to_restore + string(a, '(I0)') + path_sep() + "*.fits" )

	;read and calibrate data
	read_sdo, files, ind, da
	aia_prep, ind, da, index, data
;	read_sdo, files, index, data
	
	;reorder wavelength with index info
	index_wave=index.wavelnth
	index_reorder=index[sort(index_wave)]
	;reorder the data with wavelength in order
	data_reorder=data[*, *, sort(index_wave)]
	
	;six wavelegnth
	for b = 0, 5 do begin
	case b of 
	0: wav_len = 94
	1: wav_len = 131
	2: wav_len = 171
	3: wav_len = 193
	4: wav_len = 211
	5: wav_len = 335
	endcase

	;select the area need to plot
	data_target = data_reorder[ x_start : x_start + length, y_start : y_start + length, *]

	;set the window and color table
	window, xs=600, ys=600
	aia_lct, rr, gg, bb, wave=wav_len, /load

	;plot image 
	plot_image, alog( ( mean_filter( data_target[*, *, b]>0,3 )>0 ) +1 ), background=255, color=0
	img = tvrd(/true)

	;save the image in jpg files
	;filename : AIA_{$wave_length}_{$times}.jpg
	path_to_save = "~/ResultAndData/Final_Project/20101103_1212/result/AIA_image/"
	write_jpeg, $
	path_to_save + "AIA_" + string(wav_len, '(I0)') + "_" + string(a, '(I0)') + ".jpg", $
	img, true=1, quality=100
	
	endfor
	endfor
END
