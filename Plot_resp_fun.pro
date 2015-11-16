	device, decomposed=0
	window, xs=800, ys=600
	!p.charsize = 2.1
	!x.omargin=0.5
	!y.omargin=0.2

	loadct, 12	
	tresp=aia_get_response(/temperature, /dn, version=7)

	plot, tresp.logte, tresp.a94.tresp, color=0, thick=3, $
	background=255,yrange=[1e-28, 1e-23], /ylog, $
	title="AIA response function", $
	xtitle="log!D10!N (T)", ytitle="Response [DN cm!U-5!N s!U-1!N pixel!U-1!N]"
	oplot, tresp.logte, tresp.a131.tresp, color=30, thick=3
	oplot, tresp.logte, tresp.a171.tresp, color=60, thick=3
	oplot, tresp.logte, tresp.a193.tresp, color=110, thick=3
	oplot, tresp.logte, tresp.a211.tresp, color=120, thick=3
	oplot, tresp.logte, tresp.a335.tresp, color=200, thick=3

	wave_length = [ '94'+STRING(197B), '131'+STRING(197B), '171'+STRING(197B), $
			'193'+STRING(197B), '211'+STRING(197B), '355'+STRING(197B) ]
	tresp_color = [ 0, 30, 60 , 110, 120, 200 ]

	al_legend, wave_length, color=tresp_color, thick=3, linestyle=0, /right

	image = tvrd(/true)
	write_jpeg, "AIA_resp_fun.jpg", image, true=1, quality=100

end
