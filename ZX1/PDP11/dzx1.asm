;ZX1 PDP-11 decoder by Ivan Gorodetsky
;Based on ZX1 z80 decoder by Einar Saukas
;
;usage:
; mov #src_adr,r1
; mov #dst_adr,r2
; jsr pc,unlzsa1
;
;v 1.0 - 2021-02-18
;v 1.1 - 2021-08-12 (-16 bytes and faster)
;110 bytes
;
		
dzx1:
		mov #177777,r4
		mov #32768.,r0
dzx1_literals:
		jsr pc,dzx1_elias
dzx1_ldir1:
		movb (r1)+,(r2)+
		sob r3,dzx1_ldir1
		add r0,r0
		bcs dzx1_new_offset
		jsr pc,dzx1_elias
dzx1_copy:
		mov r2,r5
		add r4,r5
dzx1_ldir2:
		movb (r5)+,(r2)+
		sob r3,dzx1_ldir2
		add r0,r0
		bcc dzx1_literals 
dzx1_new_offset:
		movb (r1)+,r3
		ror r3
		bis #177600,r3
		bcc dzx1_msb_skip
		mov #256.,r5
		bisb (r1)+,r5
		ror r5
		inc r5
		rol r3
		bic #177400,r5
		beq dzx1_ret
		bic #177400,r3
		swab r5
		bis r5,r3
dzx1_msb_skip:
		mov r3,r4
		jsr pc,dzx1_elias
		inc r3
		br dzx1_copy 
dzx1_elias:
		mov #1,r3
dzx1_elias_loop:
		add r0,r0
		bcc dzx1_ret
		bne dzx1_elias_skip
		ror r0
		bisb (r1)+,r0
		swab r0
		add r0,r0
		bcc dzx1_ret
dzx1_elias_skip:
		add r0,r0
		rol r3
		br dzx1_elias_loop
dzx1_ret:
		rts pc
