; #########################################################################
;
;   logic.asm - Assembly file for EECS205 Assignment 4/5
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
    include keys.inc		
	
.DATA


FIXED_ANGLE_ROTATE = 00000100

.CODE

;; Define the function GameLogic

MoveShip PROTO shipArg: PTR SPRITE, key:DWORD

GameLogic PROC USES ecx key:DWORD, ship1:DWORD, ship2:DWORD, ship3:DWORD

	mov ecx, key
	cmp ecx, VK_UP 		;going to use the up key to animate the ship to move forward by switching sprites
	jne sprite_same
	mov ecx, ship1
	cmp ecx, ship.bmpPtr
	je changeship2
	mov ecx, ship2
	cmp ecx, ship.bmpPtr
	je changeship3
	
changeship2:
	mov ecx, ship2
	mov ship.bmpPtr, ecx
	jmp sprite_same

changeship3:
	mov ecx, ship3
	mov ship.bmpPtr, ecx
	
sprite_same:	
	INVOKE MoveShip, offset ship, key
	add asteroid1.a, FIXED_ANGLE_ROTATE
	sub asteroid2.a, FIXED_ANGLE_ROTATE

	ret
GameLogic ENDP

MoveShip PROC USES ebx ecx shipArg:PTR SPRITE, key: DWORD
	mov ecx, key
	cmp ecx, VK_LEFT
	je left
	cmp ecx, VK_RIGHT
	je right
	jmp done

left:
	mov ebx, shipArg
	mov ecx, (SPRITE PTR[ebx]).x
	cmp ecx, 20 		;check so you don't go out of bounds
	jl done
	sub (SPRITE PTR[ebx]).x, 10;	
	jmp done;

right: 
	mov ebx, shipArg
	mov ecx, (SPRITE PTR[ebx]).x
	cmp ecx, 615		;check so you don't go out of bounds
	jg done
	add (SPRITE PTR[ebx]).x, 10;

done:
	ret
MoveShip ENDP
	
END
