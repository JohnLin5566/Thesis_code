;	calculate the running different DEM_map, and rotate the map

	;----------------
	;how many pictures want to calculate	
	times = 30 
	;angle
	angle = 110
	;which temperature you want to choise
	;pictures length
	length = 800
	interval = times - 1
	;the results file directroy
	path_to_restore=string('~/ResultAndData/Final_Project/20101103_1212/result/DEM_map_chi/')
	
	;-----------------
	device, decomposed=0

	;load the dem_map file, and save all of the data in the array dem_map_array
	DEM_map_array=make_array(length+1, length+1, 12, times)

	for a=1, times do begin
		restore, file = path_to_restore + "final_DEM_map_" + string(a, '(I0)') + ".dat"
		DEM_map_array[*, *, *, a-1] = final_DEM_map
	endfor
	
	;running differences, and save the results in the array dem_map_diff
	DEM_map_diff=make_array(length+1, length+1, 12, times-1)
	
	for b = interval, 1, -1 do begin
		DEM_map_diff[*, *, *, b-1] = DEM_map_array[*, *, *, b] - DEM_map_array[*, *, *, b-1]
	endfor

	;show the results
	window, xsize=600, ysize=600
	loadct, 0
	!p.multi=[0, 1, 1]
	!p.charsize = 1.6
	!x.margin=2.1
	!y.margin=2.1
	
	;run all temperature of the DEM_map_rundiff
	for temperature = 7, 7 do begin

	;run diff of the map
	for c = 0, interval-1 do begin
	plot_image, rot( dem_map_diff[*, *, temperature, c], angle )/8e19, max=1, min=-1, $
	title="DEM_map_rundiff_" + string(temperature, '(I0)') + "_" + string(c, '(I0)'), $
	background=255, color=0

	;output file in jpge
	image = tvrd(/true)


	;path to save
	path_to_save = string('~/ResultAndData/Final_Project/20101103_1212/result/DEM_map_rundiff/')

	;save the output with name : DEM_map_rundiff_temperature_interval.jpg 
	write_jpeg, path_to_save +"_"+ string(temperature, '(I0)') + "_" + string(c, '(I0)') + ".jpg", $
	image, true=1, quality=100

	;end for c loop
	endfor

	;end for temperature loop
	endfor

	;run diff of the sobel map
;	for d = 0, interval-1 do plot_image, sobel(rot(dem_map_diff[*, *, temperature, d], 110))

end
