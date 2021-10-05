; -----------------------------------------------------------------------------
; ZX5v2 8080 decoder by Ivan Gorodetsky
; Based on ZX5 z80 decoder by Einar Saukas
; v1 (2021-10-05) - 150 bytes code + 5 bytes variables
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


dzx5:
#ifdef BACKWARD
        lxi d,1
		push d
#else
        lxi d,0FFFFh
		push d
		inx d
#endif
		mvi a,080h
dzx5_literals:
		call dzx5_elias
		call ldir
		jc dzx5_other_offset
dzx5_last_offset:
		call dzx5_elias
dzx5_copy:
		xthl
		push h
		dad b
		call ldir
		pop h
		xthl
		jnc dzx5_literals
dzx5_other_offset:
		add a
		jnz dzx5_other_offset_skip
		mov a,m
		NEXT_HL
		ral
dzx5_other_offset_skip:
		jnc dzx5_prev_offset 
dzx5_new_offset:
		xthl
		push h
		lhld dzx5_offset2
		shld dzx5_offset3
		pop h
		shld dzx5_offset2
		sta dzx5_PreservedBit
		add a
		pop h
#ifdef BACKWARD
		call dzx5_elias
		dcr d
		rz
		dcr e
#else
		mvi e,0FEh
		call dzx5_elias_loop
		inr e
		rz
#endif
		mov d,e
		mov e,m
		NEXT_HL 
#ifdef BACKWARD
		inx d
#endif
		push d
		xchg
		lxi h,dzx5_PreservedBit
		dcr m
		xchg
		lxi d,1
#ifdef BACKWARD
		cm dzx5_elias_backtrack
#else
		cp dzx5_elias_backtrack
#endif
		inx d
		jmp dzx5_copy
dzx5_prev_offset:
		add a
		xthl
		push h
		xchg
		xthl
		push h
		lhld dzx5_offset3
		xchg
		lhld dzx5_offset2
		jnc dzx5_second_offset
		xchg
dzx5_second_offset:
		xthl
		shld dzx5_offset2
		xchg
		shld dzx5_offset3
		pop h
		xthl
		xchg
		pop h
		xthl
        jmp dzx5_last_offset
#ifdef BACKWARD
dzx5_elias_backtrack:
		xchg\ dad h\ xchg
		add a
		jnc dzx5_elias
		inr e
dzx5_elias:
		add a
		jnz dzx5_elias_skip
		mov a,m
		NEXT_HL
		ral
dzx5_elias_skip:
		rnc
		jmp dzx5_elias_backtrack
#else
dzx5_elias:
		inr e
dzx5_elias_loop:	
		add a
		jnz dzx5_elias_skip
		mov a,m
		NEXT_HL
		ral
dzx5_elias_skip:
		rc
dzx5_elias_backtrack:
		xchg\ dad h\ xchg
		add a
		jnc dzx5_elias_loop
		jmp dzx5_elias
#endif
		
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
#ifdef BACKWARD
		inr e
#endif
		add a
		ret

dzx5_PreservedBit:
		.db 0
dzx5_offset2:
		.dw 0
dzx5_offset3:
		.dw 0

		.end
