; -----------------------------------------------------------------------------
; ZX0 8080 decoder by Ivan Gorodetsky - OLD FILE FORMAT v1 
; Based on ZX0 z80 decoder by Einar Saukas
; v1 (2021-02-15) - 103 bytes forward / 100 bytes backward
; v2 (2021-02-17) - 101 bytes forward / 100 bytes backward
; v3 (2021-02-22) - 99 bytes forward / 98 bytes backward
; v4 (2021-02-23) - 98 bytes forward / 97 bytes backward
; v5 (2021-08-16) - 94 bytes forward and backward (slightly faster)
; v6 (2021-08-17) - 92 bytes forward / 94 bytes backward (forward version slightly faster)
; v7 (2022-04-30) - 92 bytes forward / 94 bytes backward (source address now in DE, slightly faster)
; -----------------------------------------------------------------------------
; Parameters (forward):
;   DE: source address (compressed data)
;   BC: destination address (decompressing)
;
; Parameters (backward):
;   DE: last source address (compressed data)
;   BC: last destination address (decompressing)
; -----------------------------------------------------------------------------
; compress forward with <-c> option (<-classic> for salvador)
;
; compress backward with <-b -c> options (<-b -classic> for salvador)
;
; Compile with The Telemark Assembler (TASM) 3.2
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

dzx0:
#ifdef BACKWARD
		lxi h,1
		push h
		dcr l
#else
		lxi h,0FFFFh
		push h
		inx h
#endif
		mvi a,080h
dzx0_literals:
		call dzx0_elias
		call dzx0_ldir
		jc dzx0_new_offset
		call dzx0_elias
dzx0_copy:
		xchg
		xthl
		push h
		dad b
		xchg
		call dzx0_ldir
		xchg
		pop h
		xthl
		xchg
		jnc dzx0_literals
dzx0_new_offset:
		call dzx0_elias
#ifdef BACKWARD
		inx sp
		inx sp
		dcr h
		rz
		dcr l
		push psw
		mov a,l
#else
		mov h,a
		pop psw
		xra a
		sub l
		rz
		push h
#endif
		rar\ mov h,a
		ldax d
		rar\ mov l,a
		NEXT_DE
#ifdef BACKWARD
		inx h
#endif
		xthl
		mov a,h
		lxi h,1
#ifdef BACKWARD
		cc dzx0_elias_backtrack
#else
		cnc dzx0_elias_backtrack
#endif
		inx h
		jmp dzx0_copy
dzx0_elias:
		inr l
dzx0_elias_loop:	
		add a
		jnz dzx0_elias_skip
		ldax d
		NEXT_DE
		ral
dzx0_elias_skip:
#ifdef BACKWARD
		rnc
#else
		rc
#endif
dzx0_elias_backtrack:
		dad h
		add a
		jnc dzx0_elias_loop
		jmp dzx0_elias

dzx0_ldir:
		push psw
dzx0_ldir1:
		ldax d
		stax b
		NEXT_DE
		NEXT_BC
		dcx h
		mov a,h
		ora l
		jnz dzx0_ldir1
		pop psw
		add a
		ret
		
		.end
