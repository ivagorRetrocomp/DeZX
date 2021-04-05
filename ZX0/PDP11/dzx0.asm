;ZX0 PDP-11 decoder by Ivan Gorodetsky
;Based on ZX0 z80 decoder by Einar Saukas
;
;usage:
; mov #src_adr,r1
; mov #dst_adr,r2
; jsr pc,unlzsa1
;
;v 1.0 - 2021-02-18
;102 bytes
;

dzx0:
		mov #177777,r4
		clr r3
		mov #32768.,r0
dzx0_literals:
		jsr pc,dzx0_elias
dzx0_ldir1:
		movb (r1)+,(r2)+
		sob r3,dzx0_ldir1
		add r0,r0
		bcs dzx0_new_offset
		jsr pc,dzx0_elias
dzx0_copy:
		mov r2,r5
		add r4,r5
dzx0_ldir2:
		movb (r5)+,(r2)+
		sob r3,dzx0_ldir2
		add r0,r0
		bcc dzx0_literals 
dzx0_new_offset:
		jsr pc,dzx0_elias
		neg r3
		swab r3
		bic #255.,r3
		beq dzx0_ret
		bisb (r1)+,r3
		sec
		ror r3
		mov r3,r4
		mov #1,r3
		bcs dzx0_skipcall
		jsr pc,dzx0_elias_backtrack 
dzx0_skipcall:
		inc r3
		br dzx0_copy 
dzx0_elias:
		inc r3
dzx0_elias_loop:
		add r0,r0
		bne dzx0_elias_skip
		clr r0
		bisb (r1)+,r0
		swab r0
		bis #128.,r0
		add r0,r0
dzx0_elias_skip:
		bcc dzx0_elias_backtrack
dzx0_ret:
		rts pc
dzx0_elias_backtrack:
		add r0,r0
		rol r3
		br dzx0_elias_loop

		
