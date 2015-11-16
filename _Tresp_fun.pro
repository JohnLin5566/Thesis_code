	;Tresp_function, making temperature response function for special temperature 
	;range from chianti database.

	tresp=aia_get_response(/temperature, /dn, /chiantifix, /evenorm)	;chiantifix database

	Temp = [0.5,1,1.5,2,3,4,6,8,11,14,19,25,32]

	tresp_function = dindgen( 6, 12 )
	
	;A94
	tresp_function[0,0] = tresp.a94.tresp[34]
	tresp_function[0,1] = tresp.a94.tresp[40] 
	tresp_function[0,2] = tresp.a94.tresp[44] 
	tresp_function[0,3] = tresp.a94.tresp[46] 
	tresp_function[0,4] = tresp.a94.tresp[50] 
	tresp_function[0,5] = tresp.a94.tresp[52]
	tresp_function[0,6] = tresp.a94.tresp[56]
	tresp_function[0,7] = tresp.a94.tresp[58]
	tresp_function[0,8] = tresp.a94.tresp[61]
	tresp_function[0,9] = tresp.a94.tresp[63]
	tresp_function[0,10] = tresp.a94.tresp[66]
	tresp_function[0,11] = tresp.a94.tresp[68]
;	tresp_function[0,11] = tresp.a94.tresp[70]

	;A131
	tresp_function[1,0] = tresp.a131.tresp[34] 
	tresp_function[1,1] = tresp.a131.tresp[40] 
	tresp_function[1,2] = tresp.a131.tresp[44] 
	tresp_function[1,3] = tresp.a131.tresp[46] 
	tresp_function[1,4] = tresp.a131.tresp[50] 
	tresp_function[1,5] = tresp.a131.tresp[52]
	tresp_function[1,6] = tresp.a131.tresp[56]
	tresp_function[1,7] = tresp.a131.tresp[58]
	tresp_function[1,8] = tresp.a131.tresp[61]
	tresp_function[1,9] = tresp.a131.tresp[63]
	tresp_function[1,10] = tresp.a131.tresp[66]
	tresp_function[1,11] = tresp.a131.tresp[68]
;	tresp_function[1,11] = tresp.a131.tresp[70]

	;A171
	tresp_function[2,0] = tresp.a171.tresp[34] 
	tresp_function[2,1] = tresp.a171.tresp[40] 
	tresp_function[2,2] = tresp.a171.tresp[44] 
	tresp_function[2,3] = tresp.a171.tresp[46] 
	tresp_function[2,4] = tresp.a171.tresp[50] 
	tresp_function[2,5] = tresp.a171.tresp[52]
	tresp_function[2,6] = tresp.a171.tresp[56]
	tresp_function[2,7] = tresp.a171.tresp[58]
	tresp_function[2,8] = tresp.a171.tresp[61]
	tresp_function[2,9] = tresp.a171.tresp[63]
	tresp_function[2,10] = tresp.a171.tresp[66]
	tresp_function[2,11] = tresp.a171.tresp[68]
;	tresp_function[2,11] = tresp.a171.tresp[70]

	;A193
	tresp_function[3,0] = tresp.a193.tresp[34] 
	tresp_function[3,1] = tresp.a193.tresp[40] 
	tresp_function[3,2] = tresp.a193.tresp[44] 
	tresp_function[3,3] = tresp.a193.tresp[46] 
	tresp_function[3,4] = tresp.a193.tresp[50] 
	tresp_function[3,5] = tresp.a193.tresp[52]
	tresp_function[3,6] = tresp.a193.tresp[56]
	tresp_function[3,7] = tresp.a193.tresp[58]
	tresp_function[3,8] = tresp.a193.tresp[61]
	tresp_function[3,9] = tresp.a193.tresp[63]
	tresp_function[3,10] = tresp.a193.tresp[66]
	tresp_function[3,11] = tresp.a193.tresp[68]
;	tresp_function[3,11] = tresp.a193.tresp[70]

	;A211
	tresp_function[4,0] = tresp.a211.tresp[34] 
	tresp_function[4,1] = tresp.a211.tresp[40] 
	tresp_function[4,2] = tresp.a211.tresp[44] 
	tresp_function[4,3] = tresp.a211.tresp[46] 
	tresp_function[4,4] = tresp.a211.tresp[50] 
	tresp_function[4,5] = tresp.a211.tresp[52]
	tresp_function[4,6] = tresp.a211.tresp[56]
	tresp_function[4,7] = tresp.a211.tresp[58]
	tresp_function[4,8] = tresp.a211.tresp[61]
	tresp_function[4,9] = tresp.a211.tresp[63]
	tresp_function[4,10] = tresp.a211.tresp[66]
	tresp_function[4,11] = tresp.a211.tresp[68]
;	tresp_function[4,11] = tresp.a211.tresp[70]

	;A335
	tresp_function[5,0] = tresp.a335.tresp[34] 
	tresp_function[5,1] = tresp.a335.tresp[40] 
	tresp_function[5,2] = tresp.a335.tresp[44] 
	tresp_function[5,3] = tresp.a335.tresp[46] 
	tresp_function[5,4] = tresp.a335.tresp[50] 
	tresp_function[5,5] = tresp.a335.tresp[52]
	tresp_function[5,6] = tresp.a335.tresp[56]
	tresp_function[5,7] = tresp.a335.tresp[58]
	tresp_function[5,8] = tresp.a335.tresp[61]
	tresp_function[5,9] = tresp.a335.tresp[63]
	tresp_function[5,10] = tresp.a335.tresp[66]
	tresp_function[5,11] = tresp.a335.tresp[68]
;	tresp_function[5,11] = tresp.a335.tresp[70]

	;save
	save, tresp_function, file="DEM_map_tresp_function.dat"

	;output results
	help, tresp_function
	print, tresp_function
	
END
	
