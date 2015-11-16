;	plot the R_err of the testing results

	; setting
	device, decomposed=0
	window, xs=1000, ys=600
	!p.charsize = 2.1
	!x.omargin=0.5
	!y.omargin=0.2
	loadct, 12

	;path
	path=string('~/ResultAndData/Final_Project/20101103_1212/code/')
	restore, file = path + "testing_results_2.dat"

	;plot
	i=[1,2,3,4,5,6,7,8,9]
	x= indgen(10)+1
	plot, x, t_r[0, i, 2], color=0, thick=3, symsize=3, psym=4, $
	background=255, xrange=[0, 10], yrange=[-50,100], $
	title="The H!Derr!N were affected by different guess solution", $
	xtitle=" Condition ", ytitle="H!Derr!N Percentage", $
	xtickinterval=1, xminor=1
	oplot, x,t_r[1, i, 2], color=30, thick=3, symsize=3, psym=4
	oplot, x,t_r[2, i, 2], color=60, thick=3, symsize=3, psym=4
	oplot, x,t_r[3, i, 2], color=90, thick=3, symsize=3, psym=4
	oplot, x,t_r[4, i, 2], color=110, thick=3, symsize=3, psym=4


	;line mark
	set_number = [ 'set = 1', 'set = 2', 'set = 3', 'set = 4', 'set = 5' ]
	set_color = [ 0, 30, 60, 90, 110]
	sym = [4,4,4,4,4]
	al_legend, set_number, psym=sym, color=set_color, thick=2, charsize=3, symsize=3, /right

	image = tvrd(/true)
	write_jpeg, "parameter_GH.jpg", image, true=1, quality=100



end
