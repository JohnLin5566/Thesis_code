; Plot_DEM_reg.pro
	device, decomposed=0
	loadct, 12
	window, xs=800, ys=600
	!p.charsize = 2.2
	!x.margin=7
	!y.margin=3

	;--------------------------
	pixels = 2
	time_1 = 1
	time_2 = 16
	;.--------------------------


	;start the for loop of b, pixel
	for a = 2, pixels do begin
	
	;restore the data
	path_to_restore = "~/ResultAndData/Final_Project/20101103_1212/result/DEM_reg_chi/"

;	DEM_reg_{times}_{pixel_number}.dat
	restore, file = path_to_restore + "DEM_reg_" + string(time_1, '(I0)') + $
	"_" + string(a, '(I0)') + ".dat"
	DEM_reg_1 = reg
	chk_1 = DEM_reg_1.dem ge 1e19

	restore, file = path_to_restore + "DEM_reg_" + string(time_2, '(I0)') + $
	"_" + string(a, '(I0)') + ".dat"
	DEM_reg_2 = reg
	chk_2 = DEM_reg_2.dem ge 1e19

	;plot the figure
	ploterr, DEM_reg_2.logt, DEM_reg_2.dem*chk_2+1, DEM_reg_2.elogt*chk_2, DEM_reg_2.edem*chk_2, $
	title = "DEM of pixel", $
	xtitle = 'log!D10!N T [K]',ytitle=' !4n!X(T) [cm!U-5!N K!U-1!N]', $
	background=255, /ylog, xrange=[5.5, 7.5],yrange=[1e19, 1e24],$
	linestyle=0, color=0, errcolor=0, thick=4, errthick=2, /nohat

	wave_length = [ '12:15:02']
	tresp_color = [ 0 ]
	al_legend, wave_length, color=tresp_color, thick=3, linestyle=0, /right

	;output file in jpge
	image = tvrd(/true)

	;path to save
	;name : DEM_reg_pixel_{pixel}.jpg
	path_to_save = "~/ResultAndData/Final_Project/20101103_1212/result/Plot_DEM_reg/"
	write_jpeg, path_to_save + "DEM_reg_pixel_simple.jpg", $
	image, true=1, quality=100

	endfor
end
