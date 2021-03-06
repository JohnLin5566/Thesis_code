;	plot the DEM map from restoring the dem_map.dat files
;	ssw023
	;-----------------------

	picture=13

	;----------------------
	device, decomposed=0
	!p.charsize = 1.6
	!x.margin=2.2
	!y.margin=2.4

	for a = 13, picture do begin
	;load the data
	path_to_restore = "~/ResultAndData/Final_Project/20101103_1212/result/DEM_map_chi/"
	restore, file = path_to_restore + "final_EM_map_" + string(a, '(I0)') + ".dat"

	;set window
	window, 0, xs=600, ys=600	
	loadct, 39
	gamma_ct, 0.35, /current

	;plot the result
	for b=8, 8 do begin
	
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

	;plot image
	plot_image, alog10(( final_EM_map[75:725, 125:775, b] > 0 )+1), $
	title=temp, min=27, max=30, background=255, color=0

	;output file in jpge
	;filename: final_DEM_map_{$temperature}_{$time}_result.jpg
	path_to_save = "~/ResultAndData/Final_Project/20101103_1212/result/Plot_EM_map/"
	image = tvrd(/true)

	write_jpeg, $
	path_to_save+"EM_map_"+string(b, '(I0)')+"_"+string(a, '(I0)')+".jpg", $
	image, true=1, quality=100

	endfor
	endfor
end
