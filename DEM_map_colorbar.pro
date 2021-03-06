;	draw the color bar
;	ssw022

	;load the data
	path = "~/ResultAndData/Final_Project/20101103_1212/result/"
	restore, file = path + "/DEM_map_chi/DEM_map_" + string(18, '(I0)') + ".dat"

	loadct, 39
	gamma_ct, 0.47, /current
	device, decomposed=0
	!p.charsize = 3.0
	!p.background = 255


	window, xsize=380, ysize=100
	color_bar, alog10( ( DEM_map[*, *, *]>0)+1 ), 320, 35, 30, 50, $
	title="log!D10!N  [ cm!U-5!N K!U-1!N]", min=19.5, max=23.5, $
	background=255, color=0 
	
	image = tvrd(/true)
	write_jpeg, path + "DEM_map_colorbar.jpg", $
	image, true=1, quality=100


end
