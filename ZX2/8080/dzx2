; -----------------------------------------------------------------------------
; ZX2 8080 decoder by Ivan Gorodetsky
; Based on ZX2 z80 decoder by Einar Saukas
;
; v1 (2021-03-18) - 68-79 bytes forward / 68-78 bytes backward
;
; ZX2_X_SKIP_INCREMENT (compressor -x option) - -4 bytes
; ZX2_Y_LIMIT_LENGTH (compressor -y option) - -6 bytes forward / -5 bytes backward
; ZX2_Z_IGNORE_DEFAULT (compressor -z option) - -1 byte
; BACKWARD (compressor -b option) - -1 byte (without ZX2_Y_LIMIT_LENGTH)
; -----------------------------------------------------------------------------
; Parameters (forward):
;   HL: source address (compressed data)
;   BC: destination address (decompressing)
;
; Parameters (backward):
;   HL: last source address (compressed data)
;   BC: last destination address (decompressing)
; -----------------------------------------------------------------------------

;#define BACKWARD
;#define ZX2_X_SKIP_INCREMENT
;#define ZX2_Y_LIMIT_LENGTH
;#define ZX2_Z_IGNORE_DEFAULT 

#ifdef BACKWARD
#define NEXT_HL dcx h
#define NEXT_BC dcx b
#else
#define NEXT_HL inx h
#define NEXT_BC inx b
#endif

dzx2:
#ifdef BACKWARD
#ifdef ZX2_Z_IGNORE_DEFAULT 
		mvi d,0
#else
		lxi d,1
#endif
#else
#ifdef ZX2_Z_IGNORE_DEFAULT 
		mvi d,0FFh
#else
		lxi d,0FFFFh
#endif
#endif
		push d
		mvi a,080h
dzx2n_literals:
		call dzx2n_elias
		call ldir
		add a
		jc dzx2n_new_offset
dzx2n_reuse:
		call dzx2n_elias
dzx2n_copy:
		xthl
		push h
		dad b
		call ldir
		pop h
		xthl
		add a
		jnc dzx2n_literals
dzx2n_new_offset:
		pop d
		mov e,m
		inr e
		rz
		NEXT_HL
		push d
#ifdef ZX2_X_SKIP_INCREMENT
		jmp dzx2n_reuse
#else
		call dzx2n_elias
#ifdef ZX2_Y_LIMIT_LENGTH
		inr d
#else
		inx d
#endif
		jmp dzx2n_copy
#endif
dzx2n_elias:
#ifdef ZX2_Y_LIMIT_LENGTH
		mvi d,1
#else
#ifdef BACKWARD
		mvi e,1
#else
		lxi d,1
#endif
#endif
dzx2n_elias_loop:	
		add a
		jnz dzx2n_elias_skip
		mov a,m
		NEXT_HL
		ral
dzx2n_elias_skip:
		rnc
#ifdef ZX2_Y_LIMIT_LENGTH
		mov e,a
		xchg\ dad h\ xchg
		mov a,e
		jmp dzx2n_elias_loop
ldir:
		mov e,a
ldir_loop:
		mov a,m
		stax b
		NEXT_HL
		NEXT_BC
		dcr d
		jnz ldir_loop
		mov a,e
#else		
		xchg\ dad h\ xchg
		add a
		jnc dzx2n_elias_loop
		inr e
		jmp dzx2n_elias_loop
ldir:
		push psw
ldir_loop:
		mov a,m
		stax b
		NEXT_HL
		NEXT_BC
		dcx d
		mov a,e
		ora d
		jnz ldir_loop
		pop psw
#endif
		ret

		.end
