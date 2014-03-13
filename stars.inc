; #########################################################################
;
;   stars.inc - Includes for EECS205 Assignment 1
;
;
; #########################################################################


DrawStarReg PROTO STDCALL ; Renders a star in the 2D drawing space
                        ; Uses register passed parameters:
                        ;      esi = x-coordinate
                        ;      edi = y-coordinate

DrawAllStars PROTO STDCALL ; Routine which uses DrawStarReg to create all the stars

EXTERNDEF STDCALL WinMain : NEAR
