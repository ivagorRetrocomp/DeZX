; -----------------------------------------------------------------------------
; ZX0 8080 decoder by Ivan Gorodetsky
; Based on ZX0 z80 decoder by Einar Saukas
; v1 (2021-02-15) - 103 bytes forward / 100 bytes backward
; v2 (2021-02-17) - 101 bytes forward / 100 bytes backward
; v3 (2021-02-22) - 99 bytes forward / 98 bytes backward
; v4 (2021-02-23) - 98 bytes forward / 97 bytes backward
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

#ifdef BACKWARD
#define NEXT_HL dcx h
#define NEXT_BC dcx b
#else
#define NEXT_HL inx h
#define NEXT_BC inx b
#endif

dzx0_standard:
#ifdef BACKWARD
        lxi d,1
		push d
		dcr e
#else
        lxi d,0FFFFh
		push d
		inx d
#endif
		mvi a,080h
dzx0s_literals:
		call dzx0s_elias
		call ldir
		add a
		jc dzx0s_new_offset
		call dzx0s_elias
dzx0s_copy:
		xthl
		push h
		dad b
		call ldir
		pop h
		xthl
		add a
		jnc dzx0s_literals
dzx0s_new_offset:
		call dzx0s_elias
#ifdef BACKWARD
		inx sp
		inx sp
		dcr d
		rz
		dcr e
		mov d,e
#else
		mov d,a
		pop psw
		xra a
		sub e
		rz
		mov e,d
		mov d,a
		mov a,e
#endif
		push b
		mov b,a
		mov a,d\ rar\ mov d,a
		mov a,m
		rar\ mov e,a
		mov a,b
		pop b
		NEXT_HL 
#ifdef BACKWARD
		inx d
#endif
		push d
		lxi d,1
#ifdef BACKWARD
		cc dzx0s_elias_backtrack
#else
		cnc dzx0s_elias_backtrack
#endif
		inx d
		jmp dzx0s_copy
dzx0s_elias:
		inr e
dzx0s_elias_loop:	
		add a
		jnz dzx0s_elias_skip
		mov a,m
		NEXT_HL
		ral
dzx0s_elias_skip:
#ifdef BACKWARD
		rnc
#else
		rc
#endif
dzx0s_elias_backtrack:
		xchg\ dad h\ xchg
		add a
		jnc dzx0s_elias_loop
		inr e
		jmp dzx0s_elias_loop
		
ldir:
		push psw						
ldir_loop:
		mov a,m
		stax b
		NEXT_HL
		NEXT_BC
		dcx d
		mov a,d
		ora e
		jnz ldir_loop
		pop psw
		ret

		.end
