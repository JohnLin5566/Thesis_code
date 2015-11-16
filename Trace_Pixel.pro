;	Pixels tracing

;	----------------------
	
	pixels = 4
	times = 16
	wav_len = 131
	
	length = 800
	x_start = 1
	y_start = 1001

;	----------------------

	;create array to restore pixels, array of position of pixel
	;x: app[pixels, times, 0], y:app[pixels, times, 1]
;	app = fltarr( pixels, times, 2)
	app = fltarr( pixels, 1, 2)

	;how many pixels
	for a = 0, pixels-1 do begin
	
	;load image
	path_to_restore = "~/ResultAndData/Final_Project/20101103_1212/data/"
	files = file_search( path_to_restore + string(times, '(I0)') + path_sep() + $
	"*." + string(wav_len, '(I0)') +".*.fits" )
	
	;read and calibrate data
;	read_sdo, files, ind, da
;	aia_prep, ind, da, index, data
	read_sdo, files, index, data

	;select the atea need to plot
	data_target = data[ x_start : x_start + length, y_start : y_start + length, *]

	;set the window and color table
	window, xs=1000, ys=1000
	aia_lct, rr, gg, bb, wave=wav_len, /load

	;plot image 
	plot_image, alog( ( data_target>0 ) +1 )

	;cursor position of pixel
	cursor, x, y, /down
	app[a, 0, 0] = x
	app[a, 0, 1] = y

	;a loop
	endfor

	save, app, file="Pixels_tracing_result.dat"
	print, "x = ", app[*, 0, 0]
	print, "y = ", app[*, 0, 1] 

end
