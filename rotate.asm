; #########################################################################
;
;   rotate.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include blit.inc 		; So I can call BlitReg
    include trig.inc		; Useful prototypes
    include rotate.inc		; 	and definitions


.DATA
	;; You may declare helper variables here, but it would probably be better to use local variables

.CODE


;; Define the functions BasicBlit and RotateBlit
; Routine which draws a bitmap to the screen

	;; Helper function FixedMult
	
FixedMult PROC STDCALL USES ebx edx val1:FIXED, val2:FIXED
	;; fixed point multiply two values
	mov eax, val1
	imul val2
	shr eax, 16
	shl edx, 16
	or eax, edx
	ret
	
FixedMult ENDP

BasicBlit PROC STDCALL USES edx esi edi lpBmp:PTR EECS205BITMAP, xcenter:DWORD, ycenter:DWORD

	mov edx, lpBmp
	mov esi, xcenter
	mov edi, ycenter
	call BlitReg
	ret
	
BasicBlit ENDP

RotateBlit PROC STDCALL USES ebx edx lpBmp:Ptr EECS205BITMAP, xcenter:DWORD, ycenter:DWORD, angle:DWORD

	LOCAL cosa:FIXED, sina:FIXED, shiftX:DWORD, shiftY:DWORD, dstWidth:DWORD, dstHeight:DWORD, dstX:DWORD, dstY:DWORD, srcX:DWORD, srcY:DWORD, dwH:DWORD, dwW:DWORD, bTrans:BYTE, lpB:DWORD, screenX:DWORD, screenY:DWORD
	
blit:
	;; just variable initialization
	mov esi, lpBmp
	mov eax, (EECS205BITMAP PTR [esi]).dwWidth
	mov dwW, eax
	mov eax, (EECS205BITMAP PTR [esi]).dwHeight
	mov dwH, eax
	mov al, (EECS205BITMAP PTR [esi]).bTransparent
	mov bTrans, al
	mov eax, (EECS205BITMAP PTR [esi]).lpBytes
	mov lpB, eax
	
;cosa = FixedCos(angle) 
;sina = FixedSin(angle) 

	INVOKE FixedCos, angle
	mov cosa, eax
	INVOKE FixedSin, angle
	mov sina, eax
	
;shiftX = dwWidth * cosa / 2 ­ dwHeight * sina / 2;
	mov ebx, dwW
	mov shiftX, ebx		;shiftX = dwWidth
	shl shiftX, 16 		;make it a fixed point
	mov ebx, cosa
	sar ebx, 1 		;ebx <- cosa/2
	INVOKE FixedMult, ebx, shiftX
	mov shiftX, eax 	;shiftX = dwWidth * cosa/2
	mov ebx, dwH
	shl ebx, 16 		;make it fixed point
	mov ecx, sina
	sar ecx, 1 		;ecx <- sina/2
	INVOKE FixedMult, ecx, ebx ;eax has dwHeight * sina/2
	sub shiftX, eax 	;shiftX = dwWidth * cosa/2 - dwHeight * sina/2
	sar shiftX, 16 		;convert to int
;shiftY = dwHeight * cosa / 2 + dwWidth * sina / 2;
	mov ebx, dwH
	mov shiftY, ebx		;shiftY=dwHeight
	shl shiftY, 16 		;make it fixed point
	mov ebx, cosa
	sar ebx, 1 		;ebx <- cosa/2
	INVOKE FixedMult, ebx, shiftY ;shiftY = dwHeight * cosa/2
	mov shiftY, eax
	mov ebx, dwW
	shl ebx, 16
	mov ecx, sina
	sar ecx, 1 		;eax <- sina/2
	INVOKE FixedMult, ecx, ebx ;eax <- dwWidth * sina/2
	add shiftY, eax		   ;shiftY = dwHeight * cosa/2 + dwWidth * sina/2
	sar shiftY, 16		   ;convert to int

;dstWidth= dwWidth + dwHeight; 
;dstHeight= dstWidth; 
	mov ebx, dwW
	mov dstWidth, ebx
	mov ebx, dwH
	add dstWidth, ebx
	mov ebx, dstWidth
	mov dstHeight, ebx

;for(dstX = ­dstWidth; dstX < dstWidth; dstX++)   { 
;  for(dstY = ­dstHeight; dstY < dstHeight; dstY++) { 
	
	mov ebx, dstWidth
	neg ebx
	mov dstX, ebx
outerloop:
	mov ebx, dstWidth
	cmp dstX, ebx
	jge done
	mov ebx, dstHeight
	neg ebx
	mov dstY, ebx
innerloop:
	mov ebx, dstHeight
	cmp dstY, ebx
	jge doneinner

;srcX = dstX*cosa + dstY*sina; 
;srcY = dstY*cosa - dstX*sina; 
	mov ebx, dstX
	shl ebx, 16		;convert to fixed
	INVOKE FixedMult, ebx, cosa
	mov srcX, eax		;srcX = dstX * cosa
	mov ebx, dstY
	shl ebx, 16		;convert to fixed
	INVOKE FixedMult, ebx, sina
	add srcX, eax 		;srcX = dstX * cosa + dstY * sina
	sar srcX, 16 		;convert back to int

	mov ebx, dstY
	shl ebx, 16 		;convert to fixed
	INVOKE FixedMult, ebx, cosa
	mov srcY, eax		;srcY = dstY*cosa
	mov ebx, dstX
	shl ebx, 16 		;convert to fixed
	INVOKE FixedMult, ebx, sina
	sub srcY, eax 		;srcY = dstY*cosa - dstX*sina
	sar srcY, 16		;convert back to int
	
;if (srcX >= 0 && srcX < (EECS205BITMAP PTR [esi]).dwWidth && 
;            srcY >= 0 && srcY < (EECS205BITMAP PTR [esi]).dwHeight && 
;            (xcenter+dstX­shiftX) >= 0 && (xcenter+dstX­shiftX) < 639 && 
;            (ycenter+dstY­shiftY) >= 0 && (ycenter+dstY­shiftY) < 479 && 
;            bitmap pixel (srcX,srcY) is not transparent) then
;          Copy color value from bitmap (srcX, srcY) 
;to screen (xcenter+dstX­shiftX, ycenter+dstY­shiftX) 
	cmp srcX, 0		;if srcX >= 0
	jl continue
	mov eax, dwW		
	cmp srcX, eax		;if srcX < dwWidth
	jge continue
	cmp srcY, 0		;if srcY >= 0
	jl continue
	mov eax, dwH
	cmp srcY, eax 		;if srcY < dwHeight
	jge continue
	;;if (xcenter + dstX - shiftX) >= 0
	mov eax, xcenter
	add eax, dstX
	sub eax, shiftX
	cmp eax, 0
	jl continue
	;; if (xcenter+dstX-shiftX) < 639
	cmp eax, 27fh 		;639 in hex
	jge continue
	;; if (ycenter + dstY-shiftY) >= 0
	mov eax, ycenter
	add eax, dstY
	sub eax, shiftY
	cmp eax, 0
	jl continue
	;; if (ycenter+dstY-shiftY) < 479
	cmp eax, 1dfh 		;479 in hex
	jge continue
	;; if bitmap_pixel(srcX,srcY) is not transparent
	;; lpBytes[srcY*dwW+srcX]  != bTransparent
	mov ebx, lpB
	mov eax, dwW
	imul srcY
	add eax, srcX
	add ebx, eax 		;lpBytes[srcY*dwW+srcX] address
	xor eax, eax
	mov al, BYTE PTR [ebx] 	;eax <- lpBytes[srcY*dwW+srcX]
	xor ebx, ebx
	mov bl, bTrans
	cmp al, bl
	jz continue 		;if lpBytes[srcX*dwW+srcY] != bTrans

	;; Now through whole if statement, time for then
then:	
	;; screenX = xcenter + dstX - shiftX
	;; screenY = ycenter + dstY - shiftY
	mov eax, xcenter
	add eax, dstX
	sub eax, shiftX
	mov screenX, eax
	mov eax, ycenter
	add eax, dstY
	sub eax, shiftY
	mov screenY, eax

	;; lpDisplayBits[screenY*dwPitch + screenX] = lpB[srcY*dwW + srcX]
	mov eax, screenY
	imul dwPitch
	add eax, screenX
	mov ebx, lpDisplayBits
	add ebx, eax
	mov ecx, lpB
	mov eax, dwW
	imul srcY
	add eax, srcX
	add ecx, eax
	xor eax, eax
	mov al, BYTE PTR [ecx]
	mov BYTE PTR [ebx], al
	
continue:	
	inc dstY
	jmp innerloop
	
doneinner:	
	inc dstX
	jmp outerloop
	
done:	
	ret

RotateBlit ENDP


END
