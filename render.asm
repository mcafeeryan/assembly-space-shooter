; #########################################################################
;
;   render.asm - Assembly file for EECS205 Assignment 4/5
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include stars.inc		
    include blit.inc
    include trig.inc
    include rotate.inc	
    include game.inc


.DATA

.CODE

;; Define the function GameRender

GameRender PROC 

	INVOKE BeginDraw

	INVOKE DrawAllStars

	INVOKE RotateBlit, asteroid1.bmpPtr, asteroid1.x, asteroid1.y, asteroid1.a
	INVOKE RotateBlit, asteroid2.bmpPtr, asteroid2.x, asteroid2.y, asteroid2.a
	INVOKE RotateBlit, ship.bmpPtr, ship.x, ship.y, ship.a

	INVOKE EndDraw

ret
GameRender ENDP


END
