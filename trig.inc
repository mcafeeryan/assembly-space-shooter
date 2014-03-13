; #########################################################################
;
;   trig.inc - Includes for EECS205 Assignment 3
;
;
; #########################################################################

;; FIXED is a fixed point number (16 bit integer and 16 bit fractional components)
;;    To convert a FIXED value in eax into an integer:  sar eax, 16
;;    To convert an integer value in eax into a FIXED:  shl eax, 16
FIXED TYPEDEF DWORD

EXTERNDEF SINTAB:WORD 

FixedSin PROTO STDCALL dwAngle:FIXED 
FixedCos PROTO STDCALL dwAngle:FIXED




