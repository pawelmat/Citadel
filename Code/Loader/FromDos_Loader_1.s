����                                        
;PURE DISK LOADER - coded by Laxity of Kefrens,
;cut on 26.10.92 by Xanthar from 'Guardian Dragon II'...
;
;	-doesn't use libraries nor trackdisk nor interrupts!!!-
;
;input:
;a0.l - destination
;d0.w - start track (side - to 160 )
;d1.w - number of sides to read (1 track = 2 sides)
;d2.l - now 0, you can choose side of disk 1-up, 2-down, 0-both

		SECTION	"CYTADELA1",code_c

s:		movem.l	d0-a6,-(sp)
		lea	$7d000-1024,a0
		moveq	#0,d0		;track 0
		moveq	#2,d1		;read 1 track
		move	#$4000,$dff09a
		bsr.s	dl_readtracks
		move	#$c000,$dff09a
		movem.l	(sp)+,d0-a6
		jmp	$7d000

dl_readtracks:	lea	$DFF000,a6
		lea	$BFD100,a5
		lea	$BFE001,a4
		move.w	#$1002,$9A(a6)
		move.w	#$8010,$96(a6)
		clr.l	d2			;change this-head u/d
		move.l	d2,dl_side
		bsr	dl_sethead
		tst.w	dl_headpos
		bpl.s	dl_chgside
		bsr	dl_dowait1
dl_chgside:	bsr	dl_checkend
		bclr	#1,(a5)
dl_loop1:	bsr	dl_set
		bsr.s	dl_read
		subq.w	#1,dl_pos
		bgt.s	dl_loop1
		bchg	#2,(a5)
		bne.s	dl_loop2
		bsr	dl_dalay2
		bsr	dl_delay1
		addq.w	#1,dl_headpos
dl_loop2:	subq.w	#1,d1			;1 side less
		bgt.s	dl_loop1
		bset	#3,(a5)
		bset	#7,(a5)
		bclr	#3,(a5)
		rts

dl_read:	movem.l	d0-d7/a1-a6,-(sp)
		moveq	#0,d6
		lea	dl_buffer,a1
		move.l	#$55555555,d4
		moveq	#10,d5
dl_checksync:	cmp.w	#$4489,(a1)+
		bne.s	dl_checksync
		cmp.w	#$4489,(a1)
		beq.s	dl_checksync
		move.l	(a1)+,d0
		and.l	d4,d0
		add.l	d0,d0
		move.l	(a1)+,d1
		and.l	d4,d1
		or.l	d1,d0
		add.w	d0,d0
		and.w	#$1E00,d0
		lea	0(a0,d0.w),a2
		add.w	#$24,a1
		move.l	(a1)+,d0
		moveq	#9,d7
		lea	-$30(a1),a3
dl_skipsync:	move.l	(a3)+,d1
		eor.l	d1,d0
		dbra	d7,dl_skipsync

		and.l	d4,d0
		addq.w	#4,a1
		move.l	(a1)+,d2
		move.l	dl_side,d7
		lea	$200(a1),a4
		moveq	#$7F,d3
dl_decode:	move.l	(a4)+,d1
		eor.l	d1,d2
		move.l	(a1)+,d0
		eor.l	d0,d2
		and.l	d4,d0
		add.l	d0,d0
		and.l	d4,d1
		or.l	d1,d0
		eor.l	d7,d0
		move.l	d0,(a2)+
		dbra	d3,dl_decode

		dbra	d5,dl_checksync
		add.l	#$1600,a0
		movem.l	(sp)+,d0-d7/a1-a6
		rts

dl_set:		move.w	#$4000,$24(a6)
		move.l	#dl_buffer,$20(a6)
		move.w	#$4489,$7E(a6)
		move.w	#$7F00,$9E(a6)
		move.w	#$9500,$9E(a6)
		move.w	#$9900,$24(a6)
		move.w	#$9900,$24(a6)
dl_waitlast:	move.w	$1E(a6),d0
		and.w	#2,d0
		beq.s	dl_waitlast
		move.w	#2,$9C(a6)
		move.w	#$4000,$24(a6)
		rts

dl_delay1:	move.w	#$BB8,d7
dl_delayloop1:	dbra	d7,dl_delayloop1

dl_delay3:	btst	#5,(a4)
		bne.s	dl_delay3
		rts
dl_sethead:	bset	#3,(a5)
		bclr	#7,(a5)
		bclr	#3,(a5)
		bra.s	dl_delay3
dl_dowait1:	bset	#1,(a5)
dl_dowait2:	btst	#4,(a4)
		beq.s	dl_endload
		bsr.s	dl_dalay2
		bsr.s	dl_delay1
		bra.s	dl_dowait2
dl_endload:	clr.w	dl_headpos
		rts

dl_checkend:	move.w	d0,d3
		lsr.w	#1,d3
		bcc.s	dl_checkend1
		bclr	#2,(a5)
		bra.s	dl_checkend2

dl_checkend1:	bset	#2,(a5)
dl_checkend2:	tst.w	d3
		beq.s	dl_dowait1
		move.w	dl_headpos,d2
		move.w	d3,dl_headpos
		sub.w	d2,d3
		beq.s	dl_return
		bpl.s	dl_dodelay1
		bset	#1,(a5)
		neg.w	d3
		bra.s	dl_dodelay2

dl_dodelay1:	bclr	#1,(a5)
dl_dodelay2:	subq.w	#1,d3
dl_makedelay:	bsr.s	dl_dalay2
		bsr.s	dl_delay1
		dbra	d3,dl_makedelay
dl_return:	rts
dl_dalay2:	bclr	#0,(a5)
		nop
		nop
		nop
		bset	#0,(a5)
		rts

		SECTION	"CYTADELA2",data_c
dl_pos:		dc.w	0		;292
dl_side:	dc.l	0		;294
dl_headpos:	dc.w	-1		;430

		SECTION	"CYTADELA3",bss_c
dl_buffer:	ds.b	$3200
