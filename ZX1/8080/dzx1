; -----------------------------------------------------------------------------
; ZX1 8080 decoder by Ivan Gorodetsky
; Based on ZX1 z80 decoder by Einar Saukas
; Compile with The Telemark Assembler (TASM) 3.2
; v1 (2021-02-16) - 131 bytes forward / 135 bytes backward
; v2 (2021-02-17) - 129 bytes forward / 133 bytes backward
; v3 (2021-02-22) - 124 bytes forward / 128 bytes backward
; v4 (2021-02-25) - 124 bytes forward / 128 bytes backward (faster version)
; v5 (2021-02-25) - 128 bytes forward / 132 bytes backward (+4 bytes, bug fix)
; -----------------------------------------------------------------------------
; Parameters (forward):
;   DE: source address (compressed data)
;   BC: destination address (decompressing)
;
; Parameters (backward):
;   DE: last source address (compressed data)
;   BC: last destination address (decompressing)
; -----------------------------------------------------------------------------

;#define BACKWARD

#ifdef BACKWARD
#define NEXT_HL dcx h
#define NEXT_DE dcx d
#define NEXT_BC dcx b
#else
#define NEXT_HL inx h
#define NEXT_DE inx d
#define NEXT_BC inx b
#endif

dzx1_standard:
#ifdef BACKWARD
		lxi h,1
#else
		lxi h,0FFFFh
#endif
		shld Offset
		mvi a,080h
dzx1s_literals:
		call dzx1s_elias
		push psw
		dcx h
		inr l
dzx1s_ldir1:
		ldax d
		stax b
		NEXT_DE
		NEXT_BC
		dcr l
		jnz dzx1s_ldir1
		xra a
		ora h
		jz $+7
		dcr h
		jmp dzx1s_ldir1
		pop psw
		add a
		jc dzx1s_new_offset
		call dzx1s_elias
dzx1s_copy:
		push d
		xchg
		lhld Offset
		dad b
		push psw
		dcx d
		inr e
dzx1s_ldir2:
		mov a,m
		stax b
		NEXT_HL
		NEXT_BC
		dcr e
		jnz dzx1s_ldir2
		xra a
		ora d
		jz $+7
		dcr d
		jmp dzx1s_ldir2
		pop psw
		xchg
		pop d
		add a
		jnc dzx1s_literals
dzx1s_new_offset:
#ifdef BACKWARD
		ora a
#else
		dcr h
#endif
		push psw
		ldax d
		NEXT_DE
		rar\ mov l,a
		jnc dzx1s_msb_skip
		ldax d
		NEXT_DE
#ifdef BACKWARD
		ora a
		rar\ rar\ adc a
#else
		rar\ inr a
#endif
		jz dzx1s_exit
		mov h,a
#ifdef BACKWARD
		dcr h
#endif
		mov a,l\ ral\ mov l,a
dzx1s_msb_skip:
		pop psw
#ifdef BACKWARD
		inr l
#endif
		shld Offset
		call dzx1s_elias
		inx h
		jmp dzx1s_copy
dzx1s_elias:
		lxi h,1
dzx1s_elias_loop:	
		add a
		rnc
		jnz dzx1s_elias_skip
		ldax d
		NEXT_DE
		ral
		rnc
dzx1s_elias_skip:
		dad h
		add a
		jnc dzx1s_elias_loop
		inr l
		jmp dzx1s_elias_loop
dzx1s_exit:
		pop psw
		ret

Offset:
		.dw 0
		
		
		.end
