;	plot the DEM map from restoring the dem_map.dat files
;	ssw023
	;-----------------------

	picture=13
	
	;----------------------

	!p.charsize = 3
	device, decomposed=0
	for a = 13, picture do begin

	;load the data
	path_to_restore = "~/ResultAndData/Final_Project/20101103_1212/result/DEM_map_chi/"
	restore, file = path_to_restore + "final_DEM_map_" + string(a, '(I0)') + ".dat"

	;set window
	!p.multi=[0, 4, 3]
	window, 0, xs=1000, ys=800	
	loadct, 39
	gamma_ct, 0.47, /current

	;plot the result
	for b=0, 11 do begin
	
	;different tempature range
	case b of
	0:	temp = '0.5-1MK'
	1:	temp = '1-1.5MK'
	2:      temp = '1.5-2MK'
	3:      temp = '2-3MK'
	4:      temp = '3-4MK'
	5:      temp = '4-6MK'
	6:      temp = '6-8MK'
	7:      temp = '8-11MK'
	8:      temp = '11-14MK'
	9:      temp = '14-19MK'
	10:      temp = '19-25MK'
	11:      temp = '25-32MK'
	endcase

	!x.margin=2
	!y.margin=.5
	!x.omargin=2
	!y.omargin=0.1

	;plot image
	plot_image, alog10(( final_DEM_map[150:650, 200:700, b]  > 0 )+1), $
	title=temp, max=23.5, min=19.5, background=255, color=0

	endfor

	;output file in jpge
	;filename: final_DEM_map_{$temperature}_{$time}_result.jpg
	path_to_save = "~/ResultAndData/Final_Project/20101103_1212/result/Plot_DEM_map/"
	image = tvrd(/true)

	write_jpeg, $
	path_to_save+"whole_DEM_map_"+string(a, '(I0)')+".jpg", $
	image, true=1, quality=100

	
	endfor
end
