; #########################################################################
;
;   rotate.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################

include blit.inc

BasicBlit PROTO STDCALL lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

RotateBlit PROTO STDCALL lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD

FixedMult PROTO val1:FIXED, val2:FIXED
