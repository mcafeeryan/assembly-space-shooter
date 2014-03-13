; #########################################################################
;
;   trig.asm - Assembly file for EECS205 Assignment 3
;
;
; #########################################################################

      .586
      .MODEL FLAT,STDCALL
      .STACK 4096
      option casemap :none  ; case sensitive

    include trig.inc
    include rotate.inc

.DATA

;;  These are some useful constants (fixed point values that correspond to important angles)
PI_HALF = 102943           	;;  PI / 2
PI =  205887	                ;;  PI 
TWO_PI	= 411774                ;;  2 * PI 
PI_INC_RECIP =  5340353        	;;  256 / PI   (use this to find the table entry for a given angle
	                        ;;              it is easier to use than divison would be)

.CODE

FixedSin PROC STDCALL USES ebx ecx edx esi dwAngle:FIXED

	LOCAL isNegative:DWORD
	mov ebx, dwAngle
	mov isNegative, 0	;boolean for whether or not to flip the answer
	
	cmp ebx, 0	;ebx has current version of dwAngle
	jg greater2pi
	neg ebx 		;it's negative so flip and set boolean
	not isNegative

greater2pi:
	mov ecx, TWO_PI
	cmp ebx, ecx
	jle greaterthanpi			;less than 2 pi

looping:				;greater than 2 pi so loop til less than
	cmp ebx, TWO_PI
	jle greaterthanpi
	sub ebx, TWO_PI
	jmp looping
endloop:	

greaterthanpi:
	cmp ebx, PI
	jle greaterthanpiover2
	sub ebx, PI 		;subtract pi from angle
	not isNegative		;flip negative boolean

greaterthanpiover2:
	cmp ebx, PI_HALF
	jle quadrant1

	mov ecx, PI
	sub ecx, ebx 		;subtract angle from Pi
	mov ebx, ecx
		
quadrant1:
	;; get value from table (arr of WORDs)
	mov esi, PI_INC_RECIP
	xor edx, edx
	INVOKE FixedMult, esi, ebx ;multiply dwAngle by PI_INC_RECIP to get table entry
	sar eax, 16 		;convert to int so have table entry index
	sal eax, 1 		;multiply index by 2 to get number of bytes to go in table (table is WORD)
	xor ecx, ecx		;clear ecx
	mov cx, [SINTAB + eax] ;put correct sin table value into ecx
	mov eax, ecx 		;put return value in eax
	jmp almostdone
	
almostdone:
	mov edx, isNegative	;if value was originally negative or in quadrant3 or 4, make negative before ret
	cmp edx, 0
	jz done
	neg eax
	
done:	
	ret

FixedSin ENDP

FixedCos PROC STDCALL USES ebx dwAngle:FIXED

	mov ebx, dwAngle
	add ebx, PI_HALF
	INVOKE FixedSin, ebx
	ret

FixedCos ENDP
	
	
END
