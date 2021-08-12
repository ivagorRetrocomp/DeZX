;ZX2 PDP-11 decoder by Ivan Gorodetsky
;Based on ZX2 z80 decoder by Einar Saukas
;
;usage:
; mov #src_adr,r1
; mov #dst_adr,r2
; jsr pc,dzx2
;
;v 1.0 - 2021-03-18
;v 1.1 - 2021-08-12 (-4 bytes and faster)
;version for -x -z compressor option
;70 bytes
;

dzx2:
		mov #32768.,r0
dzx2_literals:
		jsr pc,dzx2_elias
dzx2_ldir1:
		movb (r1)+,(r2)+
		sob r3,dzx2_ldir1
		add r0,r0
		bcs dzx2_new_offset
dzx2_reuse:
		jsr pc,dzx2_elias
dzx2_copy:
		mov r2,r5
		add r4,r5
dzx2_ldir2:
		movb (r5)+,(r2)+
		sob r3,dzx2_ldir2
		add r0,r0
		bcc dzx2_literals 
dzx2_new_offset:
		movb (r1)+,r4
		inc r4
		beq dzx2_ret
		bis #177400,r4
		br dzx2_reuse
dzx2_elias:
		mov #1,r3
dzx2_elias_loop:
		add r0,r0
		bne dzx2_elias_skip
		ror r0
		bisb (r1)+,r0
		swab r0
		add r0,r0
dzx2_elias_skip:
		bcs dzx2_elias_skip2
dzx2_ret:
		rts pc
dzx2_elias_skip2:
		add r0,r0
		rol r3
		br dzx2_elias_loop
