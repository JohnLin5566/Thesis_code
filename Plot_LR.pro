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
	restore, file = path + "testing_results.dat"

	;plot
	i=[1,4,7,10,13,16,19,22,25]
	j=[2,5,8,11,14,17,20,23,26]
	k=[3,6,9,12,15,18,21,24,27]
	x= indgen(10)+1
	plot, x, t_r[0, i, 0], color=0, thick=3, symsize=3, psym=1, $
	background=255, xrange=[0, 10], yrange=[0, 32], $
	title="The R!Derr!N were affected by different constraint matrix L", $
	xtitle=" Condition ", ytitle="R!Derr!N Percentage", $
	xtickinterval=1, xminor=1
	oplot, x,t_r[1, i, 0], color=0, thick=3, symsize=3, psym=1
	oplot, x,t_r[2, i, 0], color=0, thick=3, symsize=3, psym=1
	oplot, x,t_r[3, i, 0], color=0, thick=3, symsize=3, psym=1
	oplot, x,t_r[4, i, 0], color=0, thick=3, symsize=3, psym=1

	oplot, x,t_r[0, j, 0], color=30, thick=3, symsize=3, psym=2
	oplot, x,t_r[1, j, 0], color=30, thick=3, symsize=3, psym=2
	oplot, x,t_r[2, j, 0], color=30, thick=3, symsize=3, psym=2
	oplot, x,t_r[3, j, 0], color=30, thick=3, symsize=3, psym=2
	oplot, x,t_r[4, j, 0], color=30, thick=3, symsize=3, psym=2

	oplot, x,t_r[0, k, 0], color=110, thick=3, symsize=3, psym=5
	oplot, x,t_r[1, k, 0], color=110, thick=3, symsize=3, psym=5
	oplot, x,t_r[2, k, 0], color=110, thick=3, symsize=3, psym=5
	oplot, x,t_r[3, k, 0], color=110, thick=3, symsize=3, psym=5
	oplot, x,t_r[4, k, 0], color=110, thick=3, symsize=3, psym=5


	;line mark
	set_number = [ 'L = 0', 'L = 1', 'L = 2' ]
	set_color = [ 0, 30, 110]
	sym = [1,2,5]
	al_legend, set_number, psym=sym, color=set_color, thick=2, charsize=3, symsize=3, /right

	image = tvrd(/true)
	write_jpeg, "parameter_LR.jpg", image, true=1, quality=100



end
