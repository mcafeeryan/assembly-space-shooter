; #########################################################################
;
;   blit.inc - Includes for EECS205 Assignment 2
;
;
; #########################################################################


_EECS205BITMAP STRUCT
 dwWidth      DWORD  ?
 dwHeight     DWORD  ?
 bTransparent BYTE   ?
              BYTE   3 DUP(?)
 lpBytes      DWORD  ?
_EECS205BITMAP ENDS

EECS205BITMAP TYPEDEF _EECS205BITMAP

EXTERNDEF StarBitmap:EECS205BITMAP
EXTERNDEF dwPitch:DWORD
EXTERNDEF lpDisplayBits:DWORD


BlitReg PROTO STDCALL   ; Renders a bitmap to the 2D drawing space
                        ; Uses register passed parameters:
                        ;      esi = x-coordinate (of image center)
                        ;      edi = y-coordinate (of image center)
			;      edx = pointer to the bitmap to draw


