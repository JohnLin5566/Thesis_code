;	calculate STEM density, kinetic, and thermal energy

	device, decomposed=0
	;color table
	loadct, 39

	;find and restore data
	path_to_restore = string('~/ResultAndData/Final_Project/20101103_1212/result/DEM_map_chi/')
	restore, file= path_to_restore + "final_EM_map_18.dat"

	window, xs=1000, ys=1000
	;plot the image
	EM_rot = rot( final_EM_map[*, *, 8], 17 )
	plot_image, alog10( ( EM_rot>0 ) +1), max=31, min=27, background=255, color=0


	x_start = 371
	x_end   = 402
	y_start = 450
	y_end   = 456

	x_dis   = x_end - x_start
	y_dis   = y_end - y_start

	;calculate the mean
	mean_em =  mean( EM_rot[x_start:x_end, y_start:y_end] )
	print, "mean_em=", mean_em

	;calculate the density
	pixel = 0.435e+8
	h = y_dis * pixel
	density = sqrt( ( mean_em)  / h )
	print, "density=", density

	;calculate the volume, V = whL = y * y * x
	V = y_dis * y_dis * x_dis * ( pixel*pixel*pixel ) 
	print, "V=", V

	;calculate the thermal
	Kb = 1.38e-16
	T = 12.5e+6
	Wt = 3. * density * V * kb * T
	print, "Wt=", Wt

	;calculate the kinetic
	Mp =  1.67e-24
	velocity = 507e+5
	Wk = 0.5 * density * V * Mp * velocity * velocity
	print, "Wk = ", Wk

end

