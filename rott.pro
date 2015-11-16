
;+
; NAME:
;	ROTT
;
; PURPOSE:
;	   Rotate an image about a point, and optionally recenter it.
;
; PROCEDURE:
;	The POLY_2D function is used to rotate the original image.
;	Note that the nearest neighbor method of interpolation
;	is used.  Use ROT_INT for bilinear interpolation.                       
;
; CALLING SEQUENCE:
;	             Result = ROTT(A,ANGLE,X0,y0[,xc,yc][,missing=value][,/interp])
;
; PARAMETERS:
;	      	A  	Image, may be of any type, must have two dimensions.
;		ANGLE   Angle of rotation in degrees CLOCKWISE. (Why?,
;			because of an error in the old ROT.)
;		X0  	Center of rotation, X subscript.  
;		Y0  	Center of rotation, Y subscript.  
;
; OPTIONAL PARAMETERS:
;
;	XC = Center of output, X subscript.  If omitted, YC = X0. 
;	YC = Center of output, Y subscript.  If omitted, YC = Y0.
;
; KEYWORDS:
;
;	Interp = keyword parameter, set to 1 for bilinear interpolation.
;		0 or omitted for nearest neighbor.
;	Missing = kwrd param, data value to substitute for pixels in the 
;		output image that map outside the input image.
;
; MODIFICATION HISTORY:
;	June, 1982, Written by DMS, RSI.
;	Feb, 1986, Modified by Mike Snyder, ES&T Labs, 3M Company.
;	 adjusted things so that rotation is exactly on the designated
;	 center.
;	October, 1986.  Modified by DMS to use POLY_2D Function.
;	Aug, 1988.	Added interp param.
;       Hacked to make a pure rotation routine, 12-dec-92, A.McA.
;-

FUNCTION ROTT,A,ANGLE,X0,Y0,xc,yc, interp = interp, missing = missing 

on_error,2				;Return to caller if error
B = FLOAT(SIZE(A))			;Get dimensions
IF N_PARAMS(0) LT 6 THEN BEGIN

	XC = X0				;Center of output in X
	YC = Y0				;and in Y.

ENDIF
;
	theta = -angle/!radeg		;angle in degrees CLOCKWISE.
	c = cos(theta)
	s = sin(theta)
;
	kx = -xc+c*x0-s*y0		;useful constants.
	ky = -yc+s*x0+c*y0
	kk = 1./(1.+s^2/c^2)
;
	cx = kk* [s/c^2*ky+kx/c,s/c^2,1/c,0.]  		;x coeff...
	cy = kk * [-s/c^2*kx+ky/c,1/c,-s/c^2,0.] 	;y coeff.
	if n_elements(interp) eq 0 then interp = 0
	if n_elements(missing) eq 0 then return,poly_2d(a,cx,cy, interp) $
	else return, poly_2d(a,cx,cy, interp, missing = missing) 
END
