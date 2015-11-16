; Plot the RK Matrix

	;--------------------------
	pixels = 4

	conditions = 5

	alltimes = 2

	;--------------------------

	;start the for loop of b, pixel
	for a = 1, pixels do begin

	;different size of the pixels
	case a of
	1:      length = 2.
	2:      length = 2.
	3:      length = 2.
	4:      length = 2.
	endcase

	;different conditions need to calculate
	for b = 1, conditions do begin


	for c = 1, alltimes do begin
	;two different time of the DEM_reg
	case c of 
	1:	times = 1
	2:	times = 16
	endcase

	;restore the data
	path_to_restore = "~/Final_Project/20101103_1212/result/DEM_reg/"

	restore, file = path_to_restore + "DEM_reg_" + $
	string(times, '(I0)') + "_" + string(a, '(I0)') + "_" + string(b, '(I0)') + ".dat"
	DEM_reg = reg

	;make a zero array to store rk
	total_rk = make_array(33, 33)
	final_rk = make_array(33, 33)

	;sum and average rn
	for i=0, length-1 do for j=0, length-1 do total_rk = total_rk + DEM_reg[i, j].rk_pos
	mean_rk = total_rk / (length*length)

	for h=0, n_elements(DEM_reg[0,0].logt)-1 do final_rk[h,*] = mean_rk[h,*]/max(mean_rk[h,*])
	
	;plot image
	loadct, 8, /silent
	gamma_ct, 2.
	window,0,xsize=500,ysize=500,title='RK Matrix'	

	image_tv, transpose(final_rk), DEM_reg[0,0].logt, DEM_reg[0,0].logt, $
	ytitle='Temperature Bin'
	oplot, [0, 20], [0, 20]

	;save the output image
	;name : DEM_reg_rk_{time}_{pixel}_{condition}.jpg
	path_to_save = "~/Final_Project/20101103_1212/result/Plot_DEM_reg_rk/20/"

	image = tvrd(/true)
	write_jpeg, path_to_save+$
	"DEM_reg_rk_"+string(times ,'(I0)')+"_"+string(a ,'(I0)')+"_"+string(b ,'(I0)')+"_.jpg", $
	image, true=1, quality=100

	endfor
	endfor
	endfor
end
