; -----------------------------------------------------------------------------
; ZX1 8080 decoder by Ivan Gorodetsky
; Based on ZX1 z80 decoder by Einar Saukas
; Compile with The Telemark Assembler (TASM) 3.2
; v1 (2021-02-16) - 131 bytes forward / 135 bytes backward
; v2 (2021-02-17) - 129 bytes forward / 133 bytes backward
; v3 (2021-02-22) - 124 bytes forward / 128 bytes backward
; v4 (2021-02-25) - 124 bytes forward / 128 bytes backward (faster version)
; v5 (2021-02-25) - 128 bytes forward / 132 bytes backward (+4 bytes, bug fix)
; v6 (2022-05-03) - 128 bytes forward / 130 bytes backward (2% faster, backward version -2 bytes)
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

dzx1:
#ifdef BACKWARD
		lxi h,1
		shld Offset
		dcr l
#else
		lxi h,0FFFFh
		shld Offset
		inx h
#endif
		mvi a,080h
dzx1_literals:
		inr l
		add a
		cc dzx1_elias
		push psw
		dcx h
		inr l
		inr h
dzx1_ldir1:
		ldax d
		stax b
		NEXT_DE
		NEXT_BC
		dcr l
		jnz dzx1_ldir1
		dcr h
		jnz dzx1_ldir1
		pop psw
		add a
		jc dzx1_new_offset
		inr l
		add a
		cc dzx1_elias
dzx1_copy:
		push d
		xchg
		lhld Offset
		dad b
		push psw
		dcx d
		inr e
		inr d
dzx1_ldir2:
		mov a,m
		stax b
		NEXT_HL
		NEXT_BC
		dcr e
		jnz dzx1_ldir2
		dcr d
		jnz dzx1_ldir2
		pop psw
		xchg
		pop d
		add a
		jnc dzx1_literals
dzx1_new_offset:
#ifdef BACKWARD
		ora a
		push psw
#else
		mov h,a
#endif
		ldax d
		NEXT_DE
		rar\ mov l,a
		jnc dzx1_msb_skip
		ldax d
		NEXT_DE
#ifdef BACKWARD
		ora a
		rar\ rar\ adc a
		jnz $+5
		pop psw
		ret
		mov h,a
		dcr h
		mov a,l\ ral\ mov l,a
dzx1_msb_skip:
		pop psw
		inr l
#else
		rar\ inr a
		rz
		push h
		mov h,a
		mov a,l\ ral\ mov l,a
		pop psw
		jmp $+6
dzx1_msb_skip:
		mov a,h
		mvi h,0FFh
#endif
		shld Offset
		lxi h,1
		add a
		cc dzx1_elias
		inx h
		jmp dzx1_copy
dzx1_elias_loop:
		add a
		rnc
dzx1_elias:
		jnz dzx1_elias_skip
		ldax d
		NEXT_DE
		ral
		rnc
dzx1_elias_skip:
		dad h
		add a
		jnc dzx1_elias_loop
		inr l
		jmp dzx1_elias_loop

Offset:
		.dw 0
		
		
		.end
