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
pew BYTE "pew.wav",0
explosion_sound BYTE "explosion.wav",0

	
.CODE

EXTERNDEF STDCALL PlaySoundA : NEAR
PlaySoundA PROTO STDCALL :DWORD, :DWORD, :DWORD
PlaySound equ <PlaySoundA>

SND_ASYNC = 1h
SND_FILENAME = 20000h
	
;; Define the function GameLogic

MoveShip PROTO shipArg: PTR SPRITE, key:DWORD

GameLogic PROC USES ecx key:DWORD, ship1:DWORD, ship2:DWORD, ship3:DWORD

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
	mov ecx, key
	cmp ecx, VK_SPACE
	jne finish_up
	;; if space need to shoot projectile and play sound
	INVOKE PlaySound, OFFSET pew, 0, SND_ASYNC+SND_FILENAME
	
finish_up:	
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
	cmp ecx, VK_UP
	je up
	cmp ecx, VK_DOWN
	je down
	jmp done

up:
	mov ebx, shipArg
	mov ecx, (SPRITE PTR [ebx]).y
	cmp ecx, 325
	jl done
	sub (SPRITE PTR [ebx]).y, 15
	jmp done

down:
	mov ebx, shipArg
	mov ecx, (SPRITE PTR [ebx]).y
	cmp ecx, 415
	jg done
	add (SPRITE PTR [ebx]).y, 15
	jmp done

	
left:
	mov ebx, shipArg
	mov ecx, (SPRITE PTR [ebx]).x
	cmp ecx, 30 		;check so you don't go out of bounds
	jl done
	sub (SPRITE PTR[ebx]).x, 15;	
	jmp done

right: 
	mov ebx, shipArg
	mov ecx, (SPRITE PTR[ebx]).x
	cmp ecx, 600		;check so you don't go out of bounds
	jg done
	add (SPRITE PTR[ebx]).x, 15

done:
	ret
MoveShip ENDP
	
END
