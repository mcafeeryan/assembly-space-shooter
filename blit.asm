; #########################################################################
;
;   blit.asm - Assembly file for EECS205 Assignment 2
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include blit.inc		; Take a look at this file to understand how
				;      bitmaps are declared

.DATA
	;; You may declare helper variables here.
	bmpX DWORD 0
	bmpY DWORD 0
	dwW DWORD ?
	dwH DWORD ?
	bTrans BYTE ?
	lpB DWORD ?
	screenX DWORD ?
	screenY DWORD ?
.CODE

; Routine which draws a bitmap to the screen
BlitReg PROC 

    ;; Here is some C-like pseudocode. You can use this as a starting point
    ;; 	 (or start from scratch if you feel like it)

    ;; Feel free to declare variables (global) if it helps. There is a pretty
    ;;   good chance that you won't fit everything in registers

    ;; 	for(bmpY = 0;  bmpY < srcBitmap->dwHeight; bmpY++)
    ;;         	for(bmpX = 0;  bmpX < srcBitmap->dwWidth; bmpX++) {
    ;; 		        screenX = centerX + bmpX - srcBitmap->dwWidth/2;
    ;; 		        screenY = centerY + bmpY - srcBitmap->dwHeight/2;
    ;; 	
    ;; 			if (srcBitmap->lpBytes[bmpY*srcBitmap->dwWidth+bmpX] != srcBitmap->bTransparent &&
    ;; 			    screenX >= 0 && screenX <= 639 &&
    ;; 			    screenY >= 0 && screenY <= 479)
    ;; 				lpDisplayBits[screenY*dwPitch + screenX] =
    ;; 					srcBitmap->lpBytes[bmpY*srcBitmap->dwWidth+bmpX]; 
    ;; 				
    ;; 		}
    	
	;; edx contains pointer to EECS205BITMAP structure
	;; initialize all variables before starting the loops
	mov al, (EECS205BITMAP PTR [edx]).bTransparent
	mov bTrans, al
	mov eax, (EECS205BITMAP PTR [edx]).lpBytes 
	mov lpB, eax 		;lpB is a pointer
	mov eax, (EECS205BITMAP PTR [edx]).dwWidth
	mov dwW, eax
	mov eax, (EECS205BITMAP PTR [edx]).dwHeight	
	mov dwH, eax
	mov bmpX, 0
	mov bmpY, 0
	
firstfor:
	mov eax, dwH ; moving values into registers for cmp
	mov ebx, bmpY
	cmp ebx, eax ; bmpY is inited to 0
	jge endfirstfor	; this is bmpY >= scrBitmap->dwHeight so end loop
	mov bmpX, 0	; before entering second for loop reset bmpX to 0
	
secondfor:
	mov eax, dwW ; moving values into registers for cmp
	mov ebx, bmpX
	cmp ebx, eax ; bmpX inited to 0
	jge endsecondfor ; this is bmpX >= srcBitmap->dwWidth so end loop

	;; body of loop
	
	;; ebx is going to be screenX
	;; ecx is going to be screenY
	mov ebx, esi 		; esi has x-coord of center
	add ebx, bmpX 		; screenX = centerX + bmpX
	sub eax, eax 		; clear eax
	mov eax, dwW 		; going to divide dwWidth/2
	shr eax, 1
	sub ebx, eax 		; screenX = (centerX + bmpX) - (dwWidth/2)
	mov screenX, ebx
	
	mov ecx, edi 		; edi has centerY
	add ecx, bmpY 		; screenY = centerY + bmpY
	sub eax, eax
	mov eax, dwH 		; going to divide dwHeight/2
	shr eax, 2
	sub ecx, eax 		; screenY = (centerY + bmpY) - (dwHeight/2)
	mov screenY, ecx
	
;; if (srcBitmap->lpBytes[bmpY*srcBitmap->dwWidth+bmpX] != srcBitmap->bTransparent &&
;;     screenX >= 0 && screenX <= 639 && screenY >= 0 && screenY <= 479)
	
	mov ebx, lpB
	mov eax, dwW
	mul bmpY 		; dwWidth * bmpY
	add eax, bmpX 		; dwWidth * bmpY + bmpX
	add ebx, eax 		; lpBytes[bmpY*dwWidth+bmpX] address
	mov eax, 0 		; clear out eax
	mov al, BYTE PTR [ebx] ; eax <- lpBytes[bmpY*dwWidth+bmpX]
	mov ebx, 0	       ; clear out ebx
	mov bl, bTrans
	cmp al, bl 		
	jz els			; if lpBytes[bmpY*dwWidth+bmpX] == bTransparent short circuit
	mov ebx, 0
	mov ecx, screenX
	cmp ecx, ebx
	jl els	 		; if screenX < 0 short circuit
	mov ebx, 27Fh 		; 639 in hex is 27F, was having issues if using 639 decimal
	cmp ecx, ebx 		; ecx still has screenX
	jg els	 		; if screenX > 639 short circuit
	mov ebx, 0
	mov ecx, screenY
	cmp ecx, ebx
	jl els	 		; if screenY < 0 short circuit
	mov ebx, 1DFh 		; 479 in hex is 1DF
	cmp ecx, ebx 		; ecx still has screenY
	jg els	 		; if screenY > 479 short circuit

	;; Now got through the whole if statement, need to do then clause

;;lpDisplayBits[screenY*dwPitch + screenX] = srcBitmap->lpBytes[bmpY*srcBitmap->dwWidth+bmpX]; 
	mov eax, screenY
	mul dwPitch 		; screenY*dwPitch
	add eax, screenX 	; screenY*dwPitch + screenX
	mov ebx, lpDisplayBits
	add ebx, eax 		; lpDisplayBits[screenY*dwPitch + screenX] address
	mov ecx, lpB 		; lpBytes[bmpY*dwWidth + bmpX]
	mov eax, dwW
	mul bmpY 		; bmpY * dwWidth
	add eax, bmpX 		; bmpY*dwWidth + bmpX
	add ecx, eax 		; lpBytes[bmpY*dwWidth + bmpX] addr
	mov eax, 0 		; clear out eax
	mov al, BYTE PTR [ecx] 	; al <- lpBytes[bmpY*dwWidth + bmpX]
	mov BYTE PTR [ebx], al

els:	
	inc bmpX  ; bmpX++ part of for loop
	jmp secondfor ; continue the loop

endsecondfor:
	inc bmpY ; bmpY++ part of for loop
	jmp firstfor ; continue the loop
	
endfirstfor:	
    ret             ;; Don't delete this line
    
BlitReg ENDP


.DATA
		
StarBitmap EECS205BITMAP <32, 36, 0ffh,, offset StarBitmap + sizeof StarBitmap>
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh
	BYTE 0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh
	BYTE 0feh,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh
	BYTE 0f9h,0f9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh
	BYTE 0f8h,0f8h,0fdh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh
	BYTE 0f8h,0f8h,0f8h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0fdh
	BYTE 0f8h,0f8h,0d8h,0f9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0f9h
	BYTE 0f8h,0f8h,0d8h,0d8h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0fdh,0f8h
	BYTE 0f8h,0f4h,0f8h,0d8h,0d9h,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0feh,0fdh,0f8h
	BYTE 0f8h,0f4h,0f8h,0d8h,0d8h,0fdh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0fdh,0f8h
	BYTE 0f4h,0f4h,0f4h,0f8h,0f8h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh,0f9h,0d4h
	BYTE 0f8h,0f4h,0f4h,0d4h,0f8h,0f8h,0d4h,0feh,0feh,0feh,0feh,0feh,0feh,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0f9h,0fdh,0f8h,0f8h
	BYTE 0f4h,0f8h,0f4h,0f4h,0f8h,0d4h,0d4h,0f8h,0d9h,0d9h,0d9h,0f9h,0d9h,0f9h,0d9h,0fah
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0fdh,0f9h,0f8h,0f8h,0f8h,0f8h
	BYTE 0f8h,0d4h,0f8h,0f8h,0f4h,0f8h,0f8h,0d8h,0f8h,0f8h,0f8h,0f8h,0d8h,0d4h,0d5h,0feh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0feh,0feh,0f9h,0f9h,0f8h,0f8h,0fch,0fch,0f8h,0f8h
	BYTE 0f8h,0f8h,0f8h,0f8h,0f4h,0f8h,0b0h,0d8h,0d8h,0f8h,0f8h,0f4h,0f8h,0d8h,0d9h,0feh
	BYTE 0ffh,0ffh,0feh,0fdh,0f9h,0f8h,0f8h,0f8h,0f8h,0f8h,0fdh,0fdh,0f8h,0f8h,0f8h,0f8h
	BYTE 0f8h,0b0h,0d8h,0f8h,0f8h,0f8h,044h,08ch,0d4h,0d8h,0d4h,0d4h,0d4h,0d4h,0feh,0ffh
	BYTE 0feh,0feh,0d9h,0d8h,0f8h,0f8h,0fch,0fch,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0fch
	BYTE 0f8h,06ch,06ch,0fch,0f8h,0d8h,06ch,06ch,0d4h,0f8h,0d4h,0d4h,0d4h,0d5h,0ffh,0ffh
	BYTE 0ffh,0dah,0d4h,0d4h,0f8h,0f8h,0f8h,0f8h,0f4h,0f4h,0f4h,0f8h,0f8h,0f8h,0fch,0fch
	BYTE 0fdh,06ch,06ch,0fdh,0fch,0d8h,048h,068h,0f8h,0d4h,0d4h,0d4h,0d4h,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0feh,0d8h,0d4h,0f4h,0f8h,0f4h,0f4h,0f4h,0f8h,0f8h,0f8h,0f8h,0fch,0fch
	BYTE 0fdh,048h,048h,0fdh,0fch,0fch,044h,024h,0f8h,0d4h,0d4h,0d4h,0d9h,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0feh,0f9h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fdh,048h,000h,0fdh,0fch,0f8h,048h,024h,0f8h,0f4h,0d4h,0d5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0f8h,0f8h,0d8h,0f8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,06ch,020h,0f8h,0fch,0fch,090h,044h,0f8h,0f4h,0d4h,0fah,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fdh,0f9h,0d8h,0d8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,0b4h,020h,0fdh,0fch,0fch,0d8h,0d8h,0f8h,0f4h,0d5h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0d8h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,0fch,0fch,0fch,0fch,0fch,0f8h,0d8h,0f8h,0f4h,0d5h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0f8h,0f8h,0f8h,0fch,0fch,0fch
	BYTE 0fch,0fch,0fch,0fch,0fch,0fch,0fch,0d8h,0f8h,0d4h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f8h,0f8h,0fch,0fch
	BYTE 0fch,0fch,0fch,0fch,0fch,0f8h,0f8h,0d8h,0f8h,0d4h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f8h,0f8h,0f8h,0fch
	BYTE 0fch,0fch,0fch,0fch,0f8h,0f8h,0f8h,0d8h,0d4h,0d4h,0d4h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h
	BYTE 0f8h,0fch,0f8h,0f8h,0f8h,0f8h,0d8h,0f8h,0f4h,0d4h,0d4h,0f9h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f8h,0f8h,0f4h,0f8h,0f8h,0f8h
	BYTE 0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0f8h,0d4h,0d4h,0d4h,0f4h,0f9h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0f8h,0f4h,0f4h,0f8h,0f8h,0f8h
	BYTE 0f8h,0f8h,0f8h,0f8h,0d4h,0d4h,0d4h,0d4h,0d4h,0d4h,0d4h,0d5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0f8h,0f4h,0f4h,0f4h,0f4h,0d4h
	BYTE 0d4h,0d8h,0d4h,0f9h,0f9h,0d5h,0b0h,0d4h,0d4h,0d4h,0d4h,0d4h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f9h,0f8h,0f4h,0f4h,0f4h,0d4h,0d4h
	BYTE 0d8h,0d4h,0feh,0ffh,0ffh,0ffh,0feh,0d5h,0d5h,0d4h,0d4h,0d5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f9h,0f8h,0f4h,0f4h,0f4h,0d4h,0d8h
	BYTE 0d5h,0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0d5h,0b5h,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0f9h,0f4h,0f4h,0f4h,0d4h,0d4h,0f9h
	BYTE 0feh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0d9h,0d8h,0d4h,0d4h,0d5h,0fah,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0fah,0d4h,0d4h,0d5h,0feh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0dah,0d5h,0d4h,0feh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0feh,0f9h,0feh,0ffh,0ffh,0ffh,0ffh
	BYTE 0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh,0ffh
		

END
