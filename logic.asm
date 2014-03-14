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
PROJECTILE_ACCEL = 10
pew BYTE "pew.wav",0
explosion_sound BYTE "explosion.wav",0
yelling BYTE "scream.wav",0
	
.CODE

EXTERNDEF STDCALL PlaySoundA : NEAR
PlaySoundA PROTO STDCALL :DWORD, :DWORD, :DWORD
PlaySound equ <PlaySoundA>

SND_ASYNC = 1h
SND_FILENAME = 20000h
	
;; Define the function GameLogic

MoveShip PROTO shipArg: PTR SPRITE, key:DWORD
Shoot PROTO
CheckCollision PROTO
UpdateEnemyPos PROTO a1:DWORD, a3:DWORD, cage:DWORD, exp:DWORD
GameReset PROTO a1:DWORD, a3:DWORD, cage:DWORD

GameLogic PROC USES ecx key:DWORD, ship1:DWORD, ship2:DWORD, ship3:DWORD, exp:DWORD, a1:DWORD, a3:DWORD, cage:DWORD

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
	jne move
	;; if space need to shoot projectile and play sound
	INVOKE Shoot
	jmp finish_up
	
move:	
	INVOKE MoveShip, offset ship, key
finish_up:	
	cmp shot, 0
	je done
	sub projectile.y, PROJECTILE_ACCEL
done:
	INVOKE CheckCollision
	INVOKE UpdateEnemyPos, a1, a3, cage, exp
	ret
GameLogic ENDP

UpdateEnemyPos PROC USES ebx a1:DWORD, a3:DWORD, cage:DWORD, exp:DWORD

	mov ebx, exp
	
	cmp cage1.y, 1500
	jg reset
	cmp cage2.y, 1500
	jg reset
	cmp asteroid1.y, 1500
	jg reset
	cmp asteroid2.y, 650
	jg reset
	cmp asteroid3.y, 1500
	jg reset
	jmp update
reset:
	inc num_loops
	INVOKE GameReset, a1, a3, cage
update:
	cmp cage1.alive, 0
	je c1dead
	add cage1.y, 1
	add cage1.a, FIXED_ANGLE_ROTATE
	jmp c2
c1dead:
	cmp cage1.visible, 0
	je c2
	cmp cage1.bmpPtr, ebx
	je c1done
	mov cage1.bmpPtr, ebx
	jmp c2
c1done:
	mov cage1.visible, 0
c2:	
	cmp cage2.alive, 0
	je c2dead
	add cage2.y, 1
	sub cage2.a, FIXED_ANGLE_ROTATE
c2dead:
	cmp cage2.visible, 0
	je as1
	cmp cage2.bmpPtr, ebx
	je c2done
	mov cage2.bmpPtr, ebx
	jmp as1
c2done:	
	mov cage2.visible, 0
as1:	
	cmp asteroid1.alive, 0
	je as1dead
	add asteroid1.y, 1
	sub asteroid1.a, FIXED_ANGLE_ROTATE
as1dead:
	cmp asteroid1.visible, 0
	je  as2
	cmp asteroid1.bmpPtr, ebx
	je as1done
	mov asteroid1.bmpPtr, ebx
	jmp as2
as1done:	
	mov asteroid1.visible, 0
as2:
	cmp asteroid2.alive, 0
	je as3
	add asteroid2.y, 1
	add asteroid2.a, FIXED_ANGLE_ROTATE
as2dead:
	cmp asteroid2.visible, 0
	je as3
	cmp asteroid2.bmpPtr, ebx
	je as2done
	mov asteroid2.bmpPtr, ebx
	jmp as3
as2done:
	mov asteroid2.visible, 0
as3:
	cmp asteroid3.alive, 0
	je done
	add asteroid3.y, 1
	sub asteroid3.a, FIXED_ANGLE_ROTATE
as3dead:
	cmp asteroid3.visible, 0
	je done
	cmp asteroid3.bmpPtr, ebx
	je as3done
	mov asteroid3.bmpPtr, ebx
	jmp done
as3done:	
	mov asteroid3.visible, 0
done:	
	ret
UpdateEnemyPos ENDP

GameReset PROC USES eax ebx a1:DWORD, a3:DWORD, cage:DWORD
	;; move correct bitmaps back in case they are explosions
	mov ebx, a1
	mov asteroid1.bmpPtr, ebx
	mov ebx, a3
	mov asteroid2.bmpPtr, ebx
	mov asteroid3.bmpPtr, ebx
	mov ebx, cage
	mov cage1.bmpPtr, ebx
	mov cage2.bmpPtr, ebx
	;; set everything to alive again
	mov asteroid1.alive, 1
	mov asteroid2.alive, 1
	mov asteroid3.alive, 1
	mov cage1.alive, 1
	mov cage2.alive, 1
	;; set everything to visible again
	mov asteroid1.visible, 1
	mov asteroid2.visible, 1
	mov asteroid3.visible, 1
	mov cage1.visible, 1
	mov cage2.visible,1

	;; each reset move enemies 15*num_resets to the right
	cmp num_loops, 5
	jg reset_loops
	mov eax, num_loops
	mov ebx, 15
	mul ebx
	add asteroid1.x, eax
	add asteroid2.x, eax
	add asteroid3.x, eax
	add cage1.x, eax
	add cage2.x, eax
	jmp reset_y

reset_loops:
	mov num_loops, 0
	mov asteroid1.x, 90
	mov asteroid2.x, 180
	mov asteroid3.x, 500
	mov cage1.x, 300
	mov cage2.x, 35

reset_y:
	mov asteroid1.y, -10
	mov asteroid2.y, -500
	mov asteroid3.y, -100
	mov cage1.y, -300
	mov cage2.y, -50
	
done:	
	ret
GameReset ENDP
	
CheckCollision PROC USES ebx ecx edx
	;; first check if projectile out of bounds and if so flip shot bool
	cmp shot, 0
	je check_enemies
	cmp projectile.y, 15
	jg check_projectile_hit
	not shot 		;flip shot bool cause out of bounds

	;; all of the 'magic numbers' hardcoded for collision boundaries were determined through looking at image size in pixels and testing what made sense
check_projectile_hit:
	mov ecx, projectile.x
	mov edx, projectile.y
	;; check if projectile hit enemy (need to check each enemy)
	;; if (cage1.x - 30 < projectile.x && cage1.x + 30 > projectile.x && cage1.y + 20  >= projectile.y && cage1.y - 20 <= projectile.y) then collision
	cmp cage1.visible, 0
	je c2proj
	mov ebx, cage1.x
	sub ebx, 30
	cmp ebx, ecx
	jg c2proj
	add ebx, 60
	cmp ebx, ecx
	jl c2proj
	mov ebx, cage1.y
	add ebx, 30
	cmp ebx, edx
	jl c2proj
	sub ebx, 60
	cmp ebx, edx
	jg c2proj
	mov cage1.alive, 0
	not shot
	INVOKE PlaySound, OFFSET yelling, 0, SND_ASYNC+SND_FILENAME 
c2proj:
	cmp cage2.visible, 0
	je a1proj
	mov ebx, cage2.x
	sub ebx, 30
	cmp ebx, ecx
	jg a1proj
	add ebx, 60
	cmp ebx, ecx
	jl a1proj
	mov ebx, cage2.y
	add ebx, 30
	cmp ebx, edx
	jl a1proj
	sub ebx, 60
	cmp ebx, edx
	jg a1proj
	mov cage2.alive, 0
	not shot
	INVOKE PlaySound, OFFSET yelling, 0, SND_ASYNC+SND_FILENAME
a1proj:
	cmp asteroid1.visible, 0
	je a2proj
	mov ebx, asteroid1.x
	sub ebx, 15
	cmp ebx, ecx
	jg a2proj
	add ebx, 30
	cmp ebx, ecx
	jl a2proj
	mov ebx, asteroid1.y
	add ebx, 16
	cmp ebx, edx
	jl a2proj
	sub ebx, 32
	cmp ebx, edx
	jg a2proj
	mov asteroid1.alive, 0
	not shot
	INVOKE PlaySound, OFFSET explosion_sound, 0, SND_ASYNC+SND_FILENAME
a2proj:
	cmp asteroid2.visible, 0
	je a3proj
	mov ebx, asteroid2.x
	sub ebx, 22
	cmp ebx, ecx
	jg a3proj
	add ebx, 44
	cmp ebx, ecx
	jl a3proj
	mov ebx, asteroid2.y
	add ebx, 22
	cmp ebx, edx
	jl a3proj
	sub ebx, 44
	cmp ebx, edx
	jg a3proj
	mov asteroid2.alive, 0
	not shot
	INVOKE PlaySound, OFFSET explosion_sound, 0, SND_ASYNC+SND_FILENAME
a3proj:
	cmp asteroid3.visible, 0
	je check_enemies
	mov ebx, asteroid3.x
	sub ebx, 22
	cmp ebx, ecx
	jg check_enemies
	add ebx, 44
	cmp ebx, ecx
	jl check_enemies
	mov ebx, asteroid3.y
	add ebx, 22
	cmp ebx, edx
	jl check_enemies
	sub ebx, 44
	cmp ebx, edx
	jg check_enemies
	mov asteroid3.alive, 0
	not shot
	INVOKE PlaySound, OFFSET explosion_sound, 0, SND_ASYNC+SND_FILENAME
	
check_enemies:
	;; check if any objects collide with the player (need to check each enemy vs player)
	mov ecx, ship.x
	mov edx, ship.y

	cmp cage1.visible, 0
	je c2ship
	mov ebx, cage1.x
	sub ebx, 30
	cmp ebx, ecx
	jg c2ship
	add ebx, 60
	cmp ebx, ecx
	jl c2ship
	mov ebx, cage1.y
	add ebx, 30
	cmp ebx, edx
	jl c2ship
	sub ebx, 60
	cmp ebx, edx
	jg c2ship
	mov over, 1
c2ship:
	cmp cage2.visible, 0
	je a1ship
	mov ebx, cage2.x
	sub ebx, 30
	cmp ebx, ecx
	jg a1ship
	add ebx, 60
	cmp ebx, ecx
	jl a1ship
	mov ebx, cage2.y
	add ebx, 30
	cmp ebx, edx
	jl a1ship
	sub ebx, 60
	cmp ebx, edx
	jg a1ship
	mov over, 1
a1ship:
	cmp asteroid1.visible, 0
	je a2ship
	mov ebx, asteroid1.x
	sub ebx, 15
	cmp ebx, ecx
	jg a2ship
	add ebx, 30
	cmp ebx, ecx
	jl a2ship
	mov ebx, asteroid1.y
	add ebx, 16
	cmp ebx, edx
	jl a2ship
	sub ebx, 32
	cmp ebx, edx
	jg a2ship
	mov over, 1
a2ship:
	cmp asteroid2.visible, 0
	je a3ship
	mov ebx, asteroid2.x
	sub ebx, 22
	cmp ebx, ecx
	jg a3ship
	add ebx, 44
	cmp ebx, ecx
	jl a3ship
	mov ebx, asteroid2.y
	add ebx, 22
	cmp ebx, edx
	jl a3ship
	sub ebx, 44
	cmp ebx, edx
	jg a3ship
	mov over, 1
a3ship:
	cmp asteroid3.visible, 0
	je done
	mov ebx, asteroid3.x
	sub ebx, 22
	cmp ebx, ecx
	jg done
	add ebx, 44
	cmp ebx, ecx
	jl done
	mov ebx, asteroid3.y
	add ebx, 22
	cmp ebx, edx
	jl done
	sub ebx, 44
	cmp ebx, edx
	jg done
	mov over, 1
	
done: 
	ret
CheckCollision ENDP

Shoot PROC USES ebx ecx edx
	cmp shot, 0
	jne done
	mov ebx, offset ship
	mov ecx, (SPRITE PTR [ebx]).x
	mov projectile.x, ecx
	mov ecx, (SPRITE PTR [ebx]).y
	mov projectile.y, ecx
	sub projectile.y, 28
	mov projectile.a, 0
	INVOKE PlaySound, OFFSET pew, 0, SND_ASYNC+SND_FILENAME
	not shot

done:
	ret
	
Shoot ENDP
	
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
