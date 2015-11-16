	device, decomposed=0
	window, xs=800, ys=600
	!p.charsize = 2.1
	!x.omargin=0.5
	!y.omargin=0.2

	loadct, 12
	x=[0, 24, 48, 72, 96, 120]
	x_err=intarr(6)
	y1=( [490, 524, 551, 583, 625, 663]-250 ) * 0.435
	y1_err=[5, 8, 3, 10, 11, 10] * 0.435
	y2=( [492, 530, 553, 585, 623, 668]-250 ) * 0.435
	y2_err=[5, 8, 5, 3, 10, 12] * 0.435

	ploterr, x, y1, x_err, y1_err, color=0, thick=3, errcolor=0, errthick=3, $
	background=255,	ytitle="Height [Mm]", xtitle="Start Time 12:13:50 [s]", $
	xrange=[0, 121], yrange=[90, 200]
	oploterr, x, y2, x_err, y2_err, color=30, thick=3, errcolor=30, errthick=3

	v1=(( 663.-490. )*435. ) / (120.)
	v2=(( 668.-492. )*435. ) / (120.)

	d_v1= (8.-5.)/(524.-490.) + (8.-3.)/(551.-524.) + (10.-3.)/(583.-551.) + $
		(11.-10.)/(625.-583.) + (11.-10.)/(663.-635.)
	d_v2= (8.-5.)/(530.-492.) + (8.-5.)/(553.-530.) + (5.-3.)/(585.-553.) + $
		(10.-3.)/(623.-585.) + (12.-10.)/(668.-623.)
	
	print, d_v1/5., d_v2/5.

	d_v1= (d_v1/5.)*v1
	d_v2= (d_v2/5.)*v2

	temp = [ '8-11 MK' +" "+ string(v1, '(I0)')+string(177B)+string(d_v1, '(I0)') + 'km/s' , $
		 '11-14 MK'+" "+ string(v2, '(I0)')+string(177B)+string(d_v2, '(I0)') + 'km/s' ]
	temp_color = [ 0, 30 ]

	al_legend, temp, color=temp_color, thick=3, linestyle=0, /right, /bottom

	image = tvrd(/true)
	write_jpeg, "rundiff_xt.jpg", image, true=1, quality=100

end
