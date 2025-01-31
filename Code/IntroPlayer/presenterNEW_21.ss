����  �  �  
  l�  �q          }  �  |�;		*****************************************
;		*	    CYTADELA PRESENTER		*
;		*	-------------------------	*
;		*Coding on 21.05.1995 by KANE of SUSPECT*
;		*****************************************

EXE:	equ	0


IFEQ	EXE
BASE:	equ	$100000
BASEF:	equ	$180000
ELSE
BASE:	equ	$000000
ENDC

VBR_BASE:	equ	$7ffee
MEMORY:		equ	$7fff8
DELAY:		equ	$7ffd8
MC20:		equ	$7fff2

VBLANK:	macro
	cmp.b	#$ff,6(a0)
	bne.s	*-6
	cmp.b	#$ff,6(a0)
	beq.s	*-6
	endm

waitblt: macro
	btst.b	#14,2(a0)
	bne.s	*-6
	endm

raster: macro
	movem.l	d0-a6,rej+4
	move.l	#.r\@,rej
	rts
.r\@:	movem.l	rej+4,d0-a6
	endm

jump:	macro
	move.l	#.p\@,jumpadr
	bra	\1
.p\@:
	endm
return:	macro
	move.l	jumpadr(pc),a1
	jmp	(a1)
	endm

wait:	macro
	move	#\1,d0
.w\@:	movem.l	d0-a6,rej+4
	move.l	#.t\@,rej
	rts
.t\@:	movem.l	rej+4,d0-a6
	dbf	d0,.w\@
	endm

	org	BASE+$3f000
	load	*

s:
		IFEQ	EXE
		move.l	#0,VBR_base
		move.l	#BASEF,MEMORY
;		move	#$1400,DELAY
		ELSE
		tst	mc20
		beq.s	.nie20
		moveq	#0,d0
		movec	d0,CACR
.nie20:
		ENDC
		lea	$dff000,a0
		VBLANK
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move	#$7fff,$96(a0)
		move.l	VBR_base,a1
		lea	OldLev3(pc),a2
		move.l	$6c(a1),(a2)		;set lev3 interrupt
		lea	NewLev3(pc),a2
		move.l	a2,$6c(a1)

		lea	l_copper2(pc),a3
		move.l	a3,$80(a0)
		move	#0,$88(a0)
		movem.l	d0-a6,rej+4
		move.l	#DoLoop,rej
		bsr	mt_init
		lea	$dff000,a0
;	move	#$fff,$180(a0)
		VBLANK
		move	#$83c0,$96(a0)
		move	#$c020,$9a(a0)
		VBLANK
;		move	DELAY,dl_delay		;loader speed

;tu loading...

.l1:		lea	BASE+$5100,a0	;load music
		move	#7*2,d0		;start track
		move	#20*2,d1	;read tracks
		bsr	dl_start
		IFNE	EXE
		bmi.s	.l1
		ENDC

.l3:		lea	BASE+$6a000,a0	;load intro player
		move	#53*2,d0	;start track
		move	#4*2,d1		;read tracks
		bsr	dl_start
		IFNE	EXE
		bmi.s	.l3
		ENDC

.l2:		move.l	MEMORY,a0	;load data
		lea	$5000(a0),a0
		move	#57*2,d0	;start track
		move	#23*2,d1	;read tracks
		bsr	dl_start
		IFNE	EXE
		bmi.s	.l2
		ENDC

		lea	$dff000,a0
Loop:		VBLANK
IFEQ	EXE
		btst.b	#6,$bfe001
		beq.s	out
ENDC
		tst	Finished
		beq.s	Loop


out:		lea	$dff000,a0
		VBLANK
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		bsr	mt_end
		lea	$dff000,a0
		move.l	#copper0,d0
		move.l	d0,$80(a0)
		move	#0,$88(a0)
		lea	BASE+$6a000,a1
		lea	BASE+$69000,a2
		move	#[$b000/4]-1,d7
.ccc:		move.l	(a1)+,(a2)+
		dbf	d7,.ccc
IFEQ	EXE
		VBLANK
		move.l	VBR_base,a1
		move.l	OldLev3(pc),$6c(a1)
		move	#$83f0,$96(a0)
		move	#$e02c,$9a(a0)
		rts
ELSE
		jmp	$69000
ENDC

;-------------------------------------------------------------------
NewLev3:	movem.l d0-a6,-(sp)
		bsr	mt_music
		move.l	rej,a1
		jsr	(a1)
		movem.l	(sp)+,d0-a6
		move	#$20,$dff09c
		rte

;-------------------------------------------------------------------
DoLoop:
		wait	350+25
		lea	l_arrakis+$5aa0,a4	;logo - arrakis
		moveq	#3,d4
		JUMP	p_setcolors
;		bsr	p_setcolors
		wait	120
		JUMP	l_fadecolors
;		bsr	l_fadecolors
		wait	20

		move	#$5300,l_bpl+2
		move.b	#$37,l_up
		move.b	#$ff,l_dn
		move.l	#l_my,d0
		bsr.w	l_adres
		lea	l_my+$9c40,a4		;logo - my
		moveq	#31,d4
		JUMP	l_setcolors
;		bsr	l_setcolors
		wait	120
		JUMP	l_fadecolors
;		bsr	l_fadecolors
		wait	20


		lea	$dff000,a0
		move.l	#l_copper,$80(a0)	;napisy
		move	#0,$88(a0)
		move.l	#l_pic,d0
		JUMP	l_conloop
		move.l	#l_pic+2*72*40,d0
		JUMP	l_conloop
		move.l	#l_pic+72*40,d0
		JUMP	l_conloop
		move.l	#l_pic+3*72*40,d0
		JUMP	l_conloop
		wait	50
		move	#1,finished
		raster
		rts

;-------------------------------------------------------------------

l_adres:	moveq	#4,d1
		lea	l_scr3(pc),a1
.kukaj:		move	d0,6(a1)
		swap	d0
		move	d0,2(a1)
		swap	d0
		lea	8(a1),a1
		addi.l	#8000,d0
		dbf	d1,.kukaj
		rts
;-------------------------------------------------------------------

l_conloop:	lea	l_scr2(pc),a1
		move	d0,6(a1)
		swap	d0
		move	d0,2(a1)
		swap	d0
		addi.l	#40*288,d0
		move	d0,8+6(a1)
		swap	d0
		move	d0,8+2(a1)

		moveq	#0,d0
		moveq	#0,d1
		moveq	#0,d2
		lea	l_copper+8(pc),a1
		moveq	#16,d3
l_con0:		raster
		cmpi	#$555,d0
		beq.s	.l1
		addi	#$111,d0
.l1:		cmpi	#$999,d1
		beq.s	.l2
		addi	#$111,d1
.l2:		cmpi	#$eee,d2
		beq.s	.l3
		addi	#$111,d2
.l3:		move	d0,2(a1)
		move	d0,6(a1)
		move	d1,10(a1)
		move	d1,14(a1)
		move	d2,18(a1)
		move	d2,22(a1)
		dbf	d3,l_con0

l_control:	raster
		lea	l_pion(pc),a2
		moveq	#0,d0
		move	2(a2),d0
		lsl	#5,d0
		divu	#320,d0
		cmpi	#16,d0
		bmi.s	.l4
		subi	#31,d0
		neg	d0
.l4:		lea	l_copper+6(pc),a1
		move	d0,(a1)
		bsr.w	l_LineEffect
		subi	#1,(a2)
		subi	#2,2(a2)
		bpl.s	l_control
		move	#240,(a2)
		move	#319,2(a2)


		lea	l_copper+8(pc),a1
		move	#$555,d0
		move	#$999,d1
		move	#$eee,d2
		move	#22,d3
l_con1:		raster
		raster
		tst	d0
		beq.s	.l1
		subi	#$111,d0
.l1:		tst	d1
		beq.s	.l2
		subi	#$111,d1
.l2:		tst	d2
		beq.s	.l3
		subi	#$111,d2
.l3:		move	d0,2(a1)
		move	d0,6(a1)
		move	d1,10(a1)
		move	d1,14(a1)
		move	d2,18(a1)
		move	d2,22(a1)
		dbf	d3,l_con1
		RETURN
;		rts

;-------------------------------------------------------------------
l_LineEffect:
;		movem	d0-d4,-(sp)
		lea	$dff000,a0
		lea	scron(pc),a1
		move.l	(a1),a5
		move.l	4(a1),d1
		move.l	a5,4(a1)
		move.l	d1,(a1)
		lea	l_scr(pc),a1
		move	d1,6(a1)
		swap	d1
		move	d1,2(a1)
		waitblt
		move	#0,$66(a0)
		move.l	#$1000000,$40(a0)
		move.l	a5,$54(a0)
		move	#[200*64]+20,$58(a0)


		lea	l_pion(pc),a1
		move	(a1)+,d0		;x left
		move	(a1)+,d2		;x right
		moveq	#100,d1
		moveq	#19,d4
l_addpion:	addi	#1,(a1)
		bmi.s	.l1
		cmpi	#199,(a1)
		bpl.s	.l2
		move	(a1)+,d3
		bra.s	.l3
.l2:		move	#-199,(a1)
.l1:		move	(a1)+,d3
		neg	d3
.l3:		bsr.s	l_drawline
		dbf	d4,l_addpion
;		movem	(sp)+,d0-d4
		rts

;-------------------------------------------------------------------
l_drawline:
		movem	d0-d7,-(sp)
		cmpi	d1,d3
		bpl.s	l_lineok
		exg	d0,d2
		exg	d1,d3
l_lineok:	moveq	#3,d4
		move	d0,d5
		move	d1,d6
		subi	d3,d1
		bpl.s	l_dr1
		neg	d1
l_dr1:		subi	d2,d0
		bpl.s	l_dr2
		eori	#%01,d4
		neg	d0
l_dr2:		cmpi	d0,d1
		bmi.s	l_dr3
		exg	d0,d1
		eori	#%10,d4
l_dr3:		move	d5,d7
		and.l	#$f,d7
		ror	#4,d7
		ori	#$0bca,d7
		swap	d7
		move.b	l_octant(pc,d4.w),d7
		add	d1,d1
		add	d6,d6
		move	l_ytable(pc,d6.w),d6
		and.l	#$fff0,d5
		lsr	#3,d5
		addi	d6,d5
		add.l	a5,d5			;addr
		waitblt
		move.l	#-1,$44(a0)
		move.l	#$ffff8000,$72(a0)
		move	#40,$60(a0)
		move	d1,$62(a0)
		move.l	d5,$48(a0)
		move.l	d5,$54(a0)
		subi	d0,d1
		bpl.s	l_dr4
		ori	#$40,d7
l_dr4:		move	d1,$52(a0)
		move.l	d7,$40(a0)
		subi	d0,d1
		move	d1,$64(a0)
		addq	#1,d0
		lsl	#6,d0
		addq	#2,d0
		move	d0,$58(a0)
		movem	(sp)+,d0-d7
		rts

l_octant:	dc.b	1,8+1,16+1,20+1
l_ytable:
VALUE:		SET	0
		REPT	200
		dc.w	VALUE
VALUE:		SET	VALUE+40
		ENDR

;---------------------------------------------------------------------
;a3 - copperlist, a4 - coltab, d4 - nr.of colors-1

l_setcolors:	move	#16,d0
l_setcol:	lea	(a3),a1
		lea	(a4),a2
		move	d4,d3				;color nr. - 1
l_scol1:	move	(a2),d1
		andi	#$f,d1
		move	2(a1),d2
		andi	#$f,d2
		cmpi	d1,d2
		beq.s	l_scol2
		addi	#1,2(a1)
l_scol2:	move	(a2),d1
		andi	#$f0,d1
		move	2(a1),d2
		andi	#$f0,d2
		cmpi	d1,d2
		beq.s	l_scol3
		addi	#$10,2(a1)
l_scol3:	move	(a2)+,d1
		andi	#$f00,d1
		move	2(a1),d2
		andi	#$f00,d2
		cmpi	d1,d2
		beq.s	l_scol4
		addi	#$100,2(a1)
l_scol4:	addi.l	#4,a1
		dbf	d3,l_scol1
;		raster
		raster
		dbf	d0,l_setcol
		RETURN
;		rts


p_setcolors:	move	#0,d0
p_SetC:		lea	(a3),a1			;copper
		lea	(a4),a2			;color tab
		move	d4,d5			;color nr. - 1
p_SC1:		move	(a2)+,d1
		move	d1,d2
		andi	#$f,d2
		mulu	d0,d2
		lsr	#4,d2
		move	d1,d3
		andi	#$f0,d3
		mulu	d0,d3
		lsr	#4,d3
		andi	#$f0,d3
		andi	#$f00,d1
		mulu	d0,d1
		lsr	#4,d1
		andi	#$f00,d1
		or	d3,d1
		or	d2,d1
		move	d1,2(a1)
		lea	4(a1),a1
		dbf	d5,p_SC1
;		raster
		raster
		addq	#1,d0
		cmpi	#17,d0
		bne.s	p_SetC
		RETURN
;		rts

;a3 - copperlist, d4 - nr.of colors

l_fadecolors:	move	#16,d0
l_fadcol:	lea	(a3),a1
		move	d4,d3			;no. of colors - 1
l_fad1:		move	2(a1),d1
		andi	#$f,d1
		beq.s	l_fad2
		subi	#1,2(a1)
l_fad2:		move	2(a1),d1
		andi	#$f0,d1
		beq.s	l_fad3
		subi	#$10,2(a1)
l_fad3:		move	2(a1),d1
		andi	#$f00,d1
		beq.s	l_fad4
		subi	#$100,2(a1)
l_fad4:		addi.l	#4,a1
		dbf	d3,l_fad1
		raster
		raster
		dbf	d0,l_fadcol
		RETURN
;		rts

;---------------------------------------------------------------------

mt_init:LEA	mt_data,A0
	MOVE.L	A0,mt_SongDataPtr
	LEA	250(A0),A1
	MOVE.W	#511,D0
	MOVEQ	#0,D1
mtloop:	MOVE.L	D1,D2
	SUBQ.W	#1,D0
mtloop2:	MOVE.B	(A1)+,D1
	CMP.W	D2,D1
	BGT.S	mtloop
	DBRA	D0,mtloop2
	ADDQ	#1,D2

	MOVE.W	D2,D3
	MULU	#128,D3
	ADD.L	#766,D3
	ADD.L	mt_SongDataPtr(PC),D3
	MOVE.L	D3,mt_LWTPtr

	LEA	mt_SampleStarts(PC),A1
	MULU	#128,D2
	ADD.L	#762,D2
	ADD.L	(A0,D2.L),D2
	ADD.L	mt_SongDataPtr(PC),D2
	ADDQ.L	#4,D2
	MOVE.L	D2,A2
	MOVEQ	#30,D0
mtloop3:	MOVE.L	A2,(A1)+
	MOVEQ	#0,D1
	MOVE.W	(A0),D1
	ADD.L	D1,D1
	ADD.L	D1,A2
	LEA	8(A0),A0
	DBRA	D0,mtloop3

	OR.B	#2,$BFE001
	lea	mt_speed(PC),A4
	MOVE.B	#6,(A4)
	CLR.B	mt_counter-mt_speed(A4)
	CLR.B	mt_SongPos-mt_speed(A4)
	CLR.W	mt_PatternPos-mt_speed(A4)
mt_end:	LEA	$DFF096,A0
	CLR.W	$12(A0)
	CLR.W	$22(A0)
	CLR.W	$32(A0)
	CLR.W	$42(A0)
	MOVE.W	#$F,(A0)
	RTS

mt_music:
	MOVEM.L	D0-D4/D7/A0-A6,-(SP)
	ADDQ.B	#1,mt_counter
	MOVE.B	mt_counter(PC),D0
	CMP.B	mt_speed(PC),D0
	BLO.S	mt_NoNewNote
	CLR.B	mt_counter
	TST.B	mt_PattDelTime2
	BEQ.S	mt_GetNewNote
	BSR.S	mt_NoNewAllChannels
	BRA.W	mt_dskip

mt_NoNewNote:
	BSR.S	mt_NoNewAllChannels
	BRA.W	mt_NoNewPosYet

mt_NoNewAllChannels:
	LEA	$DFF090,A5
	LEA	mt_chan1temp-44(PC),A6
	BSR.W	mt_CheckEfx
	BSR.W	mt_CheckEfx
	BSR.W	mt_CheckEfx
	BRA.W	mt_CheckEfx

mt_GetNewNote:
	MOVE.L	mt_SongDataPtr(PC),A0
	LEA	(A0),A3
	LEA	122(A0),A2	;pattpo
	LEA	762(A0),A0	;patterndata
	CLR.W	mt_DMACONtemp

	LEA	$DFF090,A5
	LEA	mt_chan1temp-44(PC),A6
	BSR.S	mt_DoVoice
	BSR.S	mt_DoVoice
	BSR	mt_DoVoice
	BSR	mt_DoVoice
	BRA.W	mt_SetDMA

mt_DoVoice:
	MOVEQ	#0,D0
	MOVEQ	#0,D1
	MOVE.B	mt_SongPos(PC),D0
	LEA	128(A2),A2
	MOVE.B	(A2,D0.W),D1
	MOVE.W	mt_PatternPos(PC),D2
	LSL	#7,D1
	LSR.W	#1,D2
	ADD.W	D2,D1
	LEA	$10(A5),A5
	LEA	44(A6),A6

	TST.L	(A6)
	BNE.S	mt_plvskip
	BSR.W	mt_PerNop
mt_plvskip:
	MOVE.W	(A0,D1.W),D1
	LSL.W	#2,D1
	MOVE.L	A0,-(sp)
	MOVE.L	mt_LWTPtr(PC),A0
	MOVE.L	(A0,D1.W),(A6)
	MOVE.L	(sp)+,A0
	MOVE.B	2(A6),D2
	AND.L	#$F0,D2
	LSR.B	#4,D2
	MOVE.B	(A6),D0
	AND.B	#$F0,D0
	OR.B	D0,D2
	BEQ	mt_SetRegs
	MOVEQ	#0,D3
	LEA	mt_SampleStarts(PC),A1
	SUBQ	#1,D2
	MOVE	D2,D4
	ADD	D2,D2
	ADD	D2,D2
	LSL	#3,D4
	MOVE.L	(A1,D2.L),4(A6)
	MOVE.W	(A3,D4.W),8(A6)
	MOVE.W	(A3,D4.W),40(A6)
	MOVE.W	2(A3,D4.W),18(A6)
	MOVE.L	4(A6),D2	; Get start
	MOVE.W	4(A3,D4.W),D3	; Get repeat
	BEQ.S	mt_NoLoop
	MOVE.W	D3,D0		; Get repeat
	ADD.W	D3,D3
	ADD.L	D3,D2		; Add repeat
	ADD.W	6(A3,D4.W),D0	; Add replen
	MOVE.W	D0,8(A6)

mt_NoLoop:
	MOVE.L	D2,10(A6)
	MOVE.L	D2,36(A6)
	MOVE.W	6(A3,D4.W),14(A6)	; Save replen
	MOVE.B	19(A6),9(A5)	; Set volume
mt_SetRegs:
	MOVE.W	(A6),D0
	AND.W	#$0FFF,D0
	BEQ.W	mt_CheckMoreEfx	; If no note

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0E50,D0
	BEQ.S	mt_DoSetFineTune

	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	CMP.B	#3,D0	; TonePortamento
	BEQ.S	mt_ChkTonePorta
	CMP.B	#5,D0
	BEQ.S	mt_ChkTonePorta
	CMP.B	#9,D0	; Sample Offset
	BNE.S	mt_SetPeriod
	BSR.W	mt_CheckMoreEfx
	BRA.S	mt_SetPeriod

mt_ChkTonePorta:
	BSR.W	mt_SetTonePorta
	BRA.W	mt_CheckMoreEfx

mt_DoSetFineTune:
	BSR.W	mt_SetFineTune

mt_SetPeriod:
	MOVEM.L	D1/A1,-(SP)
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1

mt_SetPeriod2:
	LEA	mt_PeriodTable(PC),A1
	MOVEQ	#36,D7
mt_ftuloop:
	CMP.W	(A1)+,D1
	BHS.S	mt_ftufound
	DBRA	D7,mt_ftuloop
mt_ftufound:
	MOVEQ	#0,D1
	MOVE.B	18(A6),D1
	LSL	#3,D1
	MOVE	D1,D0
	LSL	#3,D1
	ADD	D0,D1
	MOVE.W	-2(A1,D1.W),16(A6)

	MOVEM.L	(SP)+,D1/A1

	MOVE.W	2(A6),D0
	AND.W	#$0FF0,D0
	CMP.W	#$0ED0,D0 ; Notedelay
	BEQ.W	mt_CheckMoreEfx

	MOVE.W	20(A6),$DFF096
	BTST	#2,30(A6)
	BNE.S	mt_vibnoc
	CLR.B	27(A6)
mt_vibnoc:
	BTST	#6,30(A6)
	BNE.S	mt_trenoc
	CLR.B	29(A6)
mt_trenoc:
	MOVE.L	4(A6),(A5)	; Set start
	MOVE.W	8(A6),4(A5)	; Set length
	MOVE.W	16(A6),6(A5)	; Set period
	MOVE.W	20(A6),D0
	OR.W	D0,mt_DMACONtemp
	BRA.W	mt_CheckMoreEfx
 
mt_SetDMA:
	OR.W	#$8000,mt_DMACONtemp
	bsr.w	mt_WaitDMA

	MOVE.W	mt_dmacontemp(pc),$DFF096
	bsr.w	mt_WaitDMA

	LEA	$DFF0A0,A5
	LEA	mt_chan1temp(PC),A6
	MOVE.L	10(A6),(A5)
	MOVE.W	14(A6),4(A5)
	MOVE.L	54(A6),$10(A5)
	MOVE.W	58(A6),$14(A5)
	MOVE.L	98(A6),$20(A5)
	MOVE.W	102(A6),$24(A5)
	MOVE.L	142(A6),$30(A5)
	MOVE.W	146(A6),$34(A5)

mt_dskip:
	lea	mt_speed(PC),A4
	ADDQ.W	#4,mt_PatternPos-mt_speed(A4)
	MOVE.B	mt_PattDelTime-mt_speed(A4),D0
	BEQ.S	mt_dskc
	MOVE.B	D0,mt_PattDelTime2-mt_speed(A4)
	CLR.B	mt_PattDelTime-mt_speed(A4)
mt_dskc:	TST.B	mt_PattDelTime2-mt_speed(A4)
	BEQ.S	mt_dska
	SUBQ.B	#1,mt_PattDelTime2-mt_speed(A4)
	BEQ.S	mt_dska
	SUBQ.W	#4,mt_PatternPos-mt_speed(A4)
mt_dska:	TST.B	mt_PBreakFlag-mt_speed(A4)
	BEQ.S	mt_nnpysk
	SF	mt_PBreakFlag-mt_speed(A4)
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	CLR.B	mt_PBreakPos-mt_speed(A4)
	LSL	#2,D0
	MOVE.W	D0,mt_PatternPos-mt_speed(A4)
mt_nnpysk:
	CMP.W	#256,mt_PatternPos-mt_speed(A4)
	BLO.S	mt_NoNewPosYet
mt_NextPosition:
	MOVEQ	#0,D0
	MOVE.B	mt_PBreakPos(PC),D0
	LSL	#2,D0
	MOVE.W	D0,mt_PatternPos-mt_speed(A4)
	CLR.B	mt_PBreakPos-mt_speed(A4)
	CLR.B	mt_PosJumpFlag-mt_speed(A4)
	ADDQ.B	#1,mt_SongPos-mt_speed(A4)
	AND.B	#$7F,mt_SongPos-mt_speed(A4)
	MOVE.B	mt_SongPos(PC),D1
	MOVE.L	mt_SongDataPtr(PC),A0
	CMP.B	248(A0),D1
	BLO.S	mt_NoNewPosYet
	CLR.B	mt_SongPos-mt_speed(A4)
mt_NoNewPosYet:	
	lea	mt_speed(PC),A4
	TST.B	mt_PosJumpFlag-mt_speed(A4)
	BNE.S	mt_NextPosition
	MOVEM.L	(SP)+,D0-D4/D7/A0-A6
	RTS

mt_CheckEfx:
	LEA	$10(A5),A5
	LEA	44(A6),A6
	BSR.W	mt_UpdateFunk
	MOVE.W	2(A6),D0
	AND.W	#$0FFF,D0
	BEQ.S	mt_PerNop
	MOVE.B	2(A6),D0
	MOVEQ	#$0F,D1
	AND.L	D1,D0
	BEQ.S	mt_Arpeggio
	SUBQ	#1,D0
	BEQ.W	mt_PortaUp
	SUBQ	#1,D0
	BEQ.W	mt_PortaDown
	SUBQ	#1,D0
	BEQ.W	mt_TonePortamento
	SUBQ	#1,D0
	BEQ.W	mt_Vibrato
	SUBQ	#1,D0
	BEQ.W	mt_TonePlusVolSlide
	SUBQ	#1,D0
	BEQ.W	mt_VibratoPlusVolSlide
	SUBQ	#8,D0
	BEQ.W	mt_E_Commands
SetBack:	MOVE.W	16(A6),6(A5)
	ADDQ	#7,D0
	BEQ.W	mt_Tremolo
	SUBQ	#3,D0
	BEQ.W	mt_VolumeSlide
mt_Return2:
	RTS

mt_PerNop:
	MOVE.W	16(A6),6(A5)
	RTS

mt_Arpeggio:
	MOVEQ	#0,D0
	MOVE.B	mt_counter(PC),D0
	DIVS	#3,D0
	SWAP	D0
	TST.W	D0
	BEQ.S	mt_Arpeggio2
	SUBQ	#2,D0
	BEQ.S	mt_Arpeggio1
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	BRA.S	mt_Arpeggio3

mt_Arpeggio2:
	MOVE.W	16(A6),6(A5)
	RTS

mt_Arpeggio1:
	MOVE.B	3(A6),D0
	AND.W	#15,D0
mt_Arpeggio3:
	ADD.W	D0,D0
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D1
	MOVE.B	18(A6),D1
	LSL	#3,D1
	MOVE	D1,D2
	LSL	#3,D1
	ADD	D2,D1
	ADD.L	D1,A0

	MOVE.W	16(A6),D1
	MOVEQ	#36,D7
mt_arploop:
	CMP.W	(A0)+,D1
	BHS.S	mt_Arpeggio4
	DBRA	D7,mt_arploop
	RTS

mt_Arpeggio4:
	MOVE.W	-2(A0,D0.W),6(A5)
	RTS

mt_FinePortaUp:
	TST.B	mt_counter
	BNE.S	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaUp:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	SUB.W	D0,16(A6)
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#113,D0
	BPL.S	mt_PortaUskip
	AND.W	#$F000,16(A6)
	OR.W	#113,16(A6)
mt_PortaUskip:
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS	
 
mt_FinePortaDown:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	#$0F,mt_LowMask
mt_PortaDown:
	CLR.W	D0
	MOVE.B	3(A6),D0
	AND.B	mt_LowMask(PC),D0
	MOVE.B	#$FF,mt_LowMask
	ADD.W	D0,16(A6)
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	CMP.W	#856,D0
	BMI.S	mt_PortaDskip
	AND.W	#$F000,16(A6)
	OR.W	#856,16(A6)
mt_PortaDskip:
	MOVE.W	16(A6),D0
	AND.W	#$0FFF,D0
	MOVE.W	D0,6(A5)
	RTS

mt_SetTonePorta:
	MOVE.L	A0,-(SP)
	MOVE.W	(A6),D2
	AND.W	#$0FFF,D2
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D0
	MOVE.B	18(A6),D0
	ADD	D0,D0
	MOVE	D0,D7
	ADD	D0,D0
	ADD	D0,D0
	ADD	D0,D7
	LSL	#3,D0
	ADD	D7,D0
	ADD.L	D0,A0

	MOVEQ	#0,D0
mt_StpLoop:
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_StpFound
	ADDQ	#2,D0
	CMP.W	#37*2,D0
	BLO.S	mt_StpLoop
	MOVEQ	#35*2,D0
mt_StpFound:
	BTST	#3,18(A6)
	BEQ.S	mt_StpGoss
	TST.W	D0
	BEQ.S	mt_StpGoss
	SUBQ	#2,D0
mt_StpGoss:
	MOVE.W	(A0,D0.W),D2
	MOVE.L	(SP)+,A0
	MOVE.W	D2,24(A6)
	MOVE.W	16(A6),D0
	CLR.B	22(A6)
	CMP.W	D0,D2
	BEQ.S	mt_ClearTonePorta
	BGE.W	mt_Return2
	MOVE.B	#1,22(A6)
	RTS

mt_ClearTonePorta:
	CLR.W	24(A6)
	RTS

mt_TonePortamento:
	MOVE.B	3(A6),D0
	BEQ.S	mt_TonePortNoChange
	MOVE.B	D0,23(A6)
	CLR.B	3(A6)
mt_TonePortNoChange:
	TST.W	24(A6)
	BEQ.W	mt_Return2
	MOVEQ	#0,D0
	MOVE.B	23(A6),D0
	TST.B	22(A6)
	BNE.S	mt_TonePortaUp
mt_TonePortaDown:
	ADD.W	D0,16(A6)
	MOVE.W	24(A6),D0
	CMP.W	16(A6),D0
	BGT.S	mt_TonePortaSetPer
	MOVE.W	24(A6),16(A6)
	CLR.W	24(A6)
	BRA.S	mt_TonePortaSetPer

mt_TonePortaUp:
	SUB.W	D0,16(A6)
	MOVE.W	24(A6),D0
	CMP.W	16(A6),D0
	BLT.S	mt_TonePortaSetPer
	MOVE.W	24(A6),16(A6)
	CLR.W	24(A6)

mt_TonePortaSetPer:
	MOVE.W	16(A6),D2
	MOVE.B	31(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_GlissSkip
	LEA	mt_PeriodTable(PC),A0

	MOVEQ	#0,D0
	MOVE.B	18(A6),D0
	LSL	#3,D0
	MOVE	D0,D1
	LSL	#3,D0
	ADD	D1,D0
	ADD.L	D0,A0

	MOVEQ	#0,D0
mt_GlissLoop:
	CMP.W	(A0,D0.W),D2
	BHS.S	mt_GlissFound
	ADDQ	#2,D0
	CMP.W	#36*2,D0
	BLO.S	mt_GlissLoop
	MOVEQ	#35*2,D0
mt_GlissFound:
	MOVE.W	(A0,D0.W),D2
mt_GlissSkip:
	MOVE.W	D2,6(A5) ; Set period
	RTS

mt_Vibrato:
	MOVE.B	3(A6),D0
	BEQ.S	mt_Vibrato2
	MOVE.B	26(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_vibskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_vibskip:
	MOVE.B	3(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_vibskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_vibskip2:
	MOVE.B	D2,26(A6)
mt_Vibrato2:
	MOVE.B	27(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVE.B	30(A6),D2
	AND.W	#$03,D2
	BEQ.S	mt_vib_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_vib_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_vib_set
mt_vib_rampdown:
	TST.B	27(A6)
	BPL.S	mt_vib_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_rampdown2:
	MOVE.B	D0,D2
	BRA.S	mt_vib_set
mt_vib_sine:
	MOVE.B	0(A4,D0.W),D2
mt_vib_set:
	MOVE.B	26(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#7,D2
	MOVE.W	16(A6),D0
	TST.B	27(A6)
	BMI.S	mt_VibratoNeg
	ADD.W	D2,D0
	BRA.S	mt_Vibrato3
mt_VibratoNeg:
	SUB.W	D2,D0
mt_Vibrato3:
	MOVE.W	D0,6(A5)
	MOVE.B	26(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,27(A6)
	RTS

mt_TonePlusVolSlide:
	BSR.W	mt_TonePortNoChange
	BRA.W	mt_VolumeSlide

mt_VibratoPlusVolSlide:
	BSR.S	mt_Vibrato2
	BRA.W	mt_VolumeSlide

mt_Tremolo:
	MOVE.B	3(A6),D0
	BEQ.S	mt_Tremolo2
	MOVE.B	28(A6),D2
	AND.B	#$0F,D0
	BEQ.S	mt_treskip
	AND.B	#$F0,D2
	OR.B	D0,D2
mt_treskip:
	MOVE.B	3(A6),D0
	AND.B	#$F0,D0
	BEQ.S	mt_treskip2
	AND.B	#$0F,D2
	OR.B	D0,D2
mt_treskip2:
	MOVE.B	D2,28(A6)
mt_Tremolo2:
	MOVE.B	29(A6),D0
	LEA	mt_VibratoTable(PC),A4
	LSR.W	#2,D0
	AND.W	#$001F,D0
	MOVEQ	#0,D2
	MOVE.B	30(A6),D2
	LSR.B	#4,D2
	AND.B	#$03,D2
	BEQ.S	mt_tre_sine
	LSL.B	#3,D0
	CMP.B	#1,D2
	BEQ.S	mt_tre_rampdown
	MOVE.B	#255,D2
	BRA.S	mt_tre_set
mt_tre_rampdown:
	TST.B	27(A6)
	BPL.S	mt_tre_rampdown2
	MOVE.B	#255,D2
	SUB.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_rampdown2:
	MOVE.B	D0,D2
	BRA.S	mt_tre_set
mt_tre_sine:
	MOVE.B	0(A4,D0.W),D2
mt_tre_set:
	MOVE.B	28(A6),D0
	AND.W	#15,D0
	MULU	D0,D2
	LSR.W	#6,D2
	MOVEQ	#0,D0
	MOVE.B	19(A6),D0
	TST.B	29(A6)
	BMI.S	mt_TremoloNeg
	ADD.W	D2,D0
	BRA.S	mt_Tremolo3
mt_TremoloNeg:
	SUB.W	D2,D0
mt_Tremolo3:
	BPL.S	mt_TremoloSkip
	CLR.W	D0
mt_TremoloSkip:
	CMP.W	#$40,D0
	BLS.S	mt_TremoloOk
	MOVE.W	#$40,D0
mt_TremoloOk:
	MOVE.W	D0,8(A5)
	MOVE.B	28(A6),D0
	LSR.W	#2,D0
	AND.W	#$003C,D0
	ADD.B	D0,29(A6)
	RTS

mt_SampleOffset:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	BEQ.S	mt_sononew
	MOVE.B	D0,32(A6)
mt_sononew:
	MOVE.B	32(A6),D0
	LSL.W	#7,D0
	CMP.W	8(A6),D0
	BGE.S	mt_sofskip
	SUB.W	D0,8(A6)
	ADD.W	D0,D0
	ADD.L	D0,4(A6)
	RTS
mt_sofskip:
	MOVE.W	#$0001,8(A6)
	RTS

mt_VolumeSlide:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	LSR.B	#4,D0
	TST.B	D0
	BEQ.S	mt_VolSlideDown
mt_VolSlideUp:
	ADD.B	D0,19(A6)
	CMP.B	#$40,19(A6)
	BMI.S	mt_vsuskip
	MOVE.B	#$40,19(A6)
mt_vsuskip:
	MOVE.B	19(A6),9(A5)
	RTS

mt_VolSlideDown:
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
mt_VolSlideDown2:
	SUB.B	D0,19(A6)
	BPL.S	mt_vsdskip
	CLR.B	19(A6)
mt_vsdskip:
	MOVE.B	19(A6),9(A5)
	RTS

mt_PositionJump:
	MOVE.B	3(A6),D0
	SUBQ	#1,D0
	MOVE.B	D0,mt_SongPos
mt_pj2:	CLR.B	mt_PBreakPos
	ST 	mt_PosJumpFlag
	RTS

mt_VolumeChange:
	MOVE.B	3(A6),D0
	CMP.B	#$40,D0
	BLS.S	mt_VolumeOk
	MOVEQ	#$40,D0
mt_VolumeOk:
	MOVE.B	D0,19(A6)
	MOVE.B	D0,9(A5)
	RTS

mt_PatternBreak:
	MOVEQ	#0,D0
	MOVE.B	3(A6),D0
	MOVE.W	D0,D2
	LSR.B	#4,D0
	ADD	D0,D0
	MOVE	D0,D1
	ADD	D0,D0
	ADD	D0,D0
	ADD	D1,D0
	AND.B	#$0F,D2
	ADD.B	D2,D0
	CMP.B	#63,D0
	BHI.S	mt_pj2
	MOVE.B	D0,mt_PBreakPos
	ST	mt_PosJumpFlag
	RTS

mt_SetSpeed:
	MOVE.B	3(A6),D0
	BEQ.W	mt_Return2
	CLR.B	mt_counter
	MOVE.B	D0,mt_speed
	RTS

mt_CheckMoreEfx:
	BSR.W	mt_UpdateFunk
	MOVE.B	2(A6),D0
	AND.B	#$0F,D0
	SUB.B	#9,D0
	BEQ.W	mt_SampleOffset
	SUBQ	#2,D0
	BEQ.W	mt_PositionJump
	SUBQ	#1,D0
	BEQ	mt_VolumeChange
	SUBQ	#1,D0
	BEQ.S	mt_PatternBreak
	SUBQ	#1,D0
	BEQ.S	mt_E_Commands
	SUBQ	#1,D0
	BEQ.S	mt_SetSpeed
	BRA.W	mt_PerNop

mt_E_Commands:
	MOVE.B	3(A6),D0
	AND.W	#$F0,D0
	LSR.B	#4,D0
	BEQ.S	mt_FilterOnOff
	SUBQ	#1,D0
	BEQ.W	mt_FinePortaUp
	SUBQ	#1,D0
	BEQ.W	mt_FinePortaDown
	SUBQ	#1,D0
	BEQ.S	mt_SetGlissControl
	SUBQ	#1,D0
	BEQ	mt_SetVibratoControl

	SUBQ	#1,D0
	BEQ	mt_SetFineTune
	SUBQ	#1,D0

	BEQ	mt_JumpLoop
	SUBQ	#1,D0
	BEQ.W	mt_SetTremoloControl
	SUBQ	#2,D0
	BEQ.W	mt_RetrigNote
	SUBQ	#1,D0
	BEQ.W	mt_VolumeFineUp
	SUBQ	#1,D0
	BEQ.W	mt_VolumeFineDown
	SUBQ	#1,D0
	BEQ.W	mt_NoteCut
	SUBQ	#1,D0
	BEQ.W	mt_NoteDelay
	SUBQ	#1,D0
	BEQ.W	mt_PatternDelay
	BRA.W	mt_FunkIt

mt_FilterOnOff:
	MOVE.B	3(A6),D0
	AND.B	#1,D0
	ADD.B	D0,D0
	AND.B	#$FD,$BFE001
	OR.B	D0,$BFE001
	RTS	

mt_SetGlissControl:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,31(A6)
	OR.B	D0,31(A6)
	RTS

mt_SetVibratoControl:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	AND.B	#$F0,30(A6)
	OR.B	D0,30(A6)
	RTS

mt_SetFineTune:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	MOVE.B	D0,18(A6)
	RTS

mt_JumpLoop:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	BEQ.S	mt_SetLoop
	TST.B	34(A6)
	BEQ.S	mt_jumpcnt
	SUBQ.B	#1,34(A6)
	BEQ.W	mt_Return2
mt_jmploop: 	MOVE.B	33(A6),mt_PBreakPos
	ST	mt_PBreakFlag
	RTS

mt_jumpcnt:
	MOVE.B	D0,34(A6)
	BRA.S	mt_jmploop

mt_SetLoop:
	MOVE.W	mt_PatternPos(PC),D0
	LSR	#2,D0
	MOVE.B	D0,33(A6)
	RTS

mt_SetTremoloControl:
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,30(A6)
	OR.B	D0,30(A6)
	RTS

mt_RetrigNote:
	MOVE.L	D1,-(SP)
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	BEQ.S	mt_rtnend
	MOVEQ	#0,d1
	MOVE.B	mt_counter(PC),D1
	BNE.S	mt_rtnskp
	MOVE.W	(A6),D1
	AND.W	#$0FFF,D1
	BNE.S	mt_rtnend
	MOVEQ	#0,D1
	MOVE.B	mt_counter(PC),D1
mt_rtnskp:
	DIVU	D0,D1
	SWAP	D1
	TST.W	D1
	BNE.S	mt_rtnend
mt_DoRetrig:
	MOVE.W	20(A6),$DFF096	; Channel DMA off
	MOVE.L	4(A6),(A5)	; Set sampledata pointer
	MOVE.W	8(A6),4(A5)	; Set length
	BSR.W	mt_WaitDMA
	MOVE.W	20(A6),D0
	BSET	#15,D0
	MOVE.W	D0,$DFF096
	BSR.W	mt_WaitDMA
	MOVE.L	10(A6),(A5)
	MOVE.L	14(A6),4(A5)
mt_rtnend:
	MOVE.L	(SP)+,D1
	RTS

mt_VolumeFineUp:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$F,D0
	BRA.W	mt_VolSlideUp

mt_VolumeFineDown:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	BRA.W	mt_VolSlideDown2

mt_NoteCut:
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	CMP.B	mt_counter(PC),D0
	BNE.W	mt_Return2
	CLR.B	19(A6)
	CLR.W	8(A5)
	RTS

mt_NoteDelay:
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	CMP.B	mt_Counter(PC),D0
	BNE.W	mt_Return2
	MOVE.W	(A6),D0
	BEQ.W	mt_Return2
	MOVE.L	D1,-(SP)
	BRA.W	mt_DoRetrig

mt_PatternDelay:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.W	#$0F,D0
	TST.B	mt_PattDelTime2
	BNE.W	mt_Return2
	ADDQ.B	#1,D0
	MOVE.B	D0,mt_PattDelTime
	RTS

mt_FunkIt:
	TST.B	mt_counter
	BNE.W	mt_Return2
	MOVE.B	3(A6),D0
	AND.B	#$0F,D0
	LSL.B	#4,D0
	AND.B	#$0F,31(A6)
	OR.B	D0,31(A6)
	TST.B	D0
	BEQ.W	mt_Return2
mt_UpdateFunk:
	MOVEM.L	D1/A0,-(SP)
	MOVEQ	#0,D0
	MOVE.B	31(A6),D0
	LSR.B	#4,D0
	BEQ.S	mt_funkend
	LEA	mt_FunkTable(PC),A0
	MOVE.B	(A0,D0.W),D0
	ADD.B	D0,35(A6)
	BTST	#7,35(A6)
	BEQ.S	mt_funkend
	CLR.B	35(A6)

	MOVE.L	10(A6),D0
	MOVEQ	#0,D1
	MOVE.W	14(A6),D1
	ADD.L	D1,D0
	ADD.L	D1,D0
	MOVE.L	36(A6),A0
	ADDQ.L	#1,A0
	CMP.L	D0,A0
	BLO.S	mt_funkok
	MOVE.L	10(A6),A0
mt_funkok:
	MOVE.L	A0,36(A6)
	NEG.B	(A0)
	SUBQ.B	#1,(A0)
mt_funkend:
	MOVEM.L	(SP)+,D1/A0
	RTS

mt_WaitDMA:
	MOVEQ	#3,D0
mt_WaitDMA2:
	MOVE.B	$DFF006,D1
mt_WaitDMA3:
	CMP.B	$DFF006,D1
	BEQ.S	mt_WaitDMA3
	DBF	D0,mt_WaitDMA2
	RTS

mt_FunkTable: dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable:
	dc.b   0, 24, 49, 74, 97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120, 97, 74, 49, 24

mt_PeriodTable:
; Tuning 0, Normal
	dc.w	856,808,762,720,678,640,604,570,538,508,480,453
	dc.w	428,404,381,360,339,320,302,285,269,254,240,226
	dc.w	214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w	850,802,757,715,674,637,601,567,535,505,477,450
	dc.w	425,401,379,357,337,318,300,284,268,253,239,225
	dc.w	213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w	844,796,752,709,670,632,597,563,532,502,474,447
	dc.w	422,398,376,355,335,316,298,282,266,251,237,224
	dc.w	211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w	838,791,746,704,665,628,592,559,528,498,470,444
	dc.w	419,395,373,352,332,314,296,280,264,249,235,222
	dc.w	209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w	832,785,741,699,660,623,588,555,524,495,467,441
	dc.w	416,392,370,350,330,312,294,278,262,247,233,220
	dc.w	208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w	826,779,736,694,655,619,584,551,520,491,463,437
	dc.w	413,390,368,347,328,309,292,276,260,245,232,219
	dc.w	206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w	820,774,730,689,651,614,580,547,516,487,460,434
	dc.w	410,387,365,345,325,307,290,274,258,244,230,217
	dc.w	205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w	814,768,725,684,646,610,575,543,513,484,457,431
	dc.w	407,384,363,342,323,305,288,272,256,242,228,216
	dc.w	204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w	907,856,808,762,720,678,640,604,570,538,508,480
	dc.w	453,428,404,381,360,339,320,302,285,269,254,240
	dc.w	226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w	900,850,802,757,715,675,636,601,567,535,505,477
	dc.w	450,425,401,379,357,337,318,300,284,268,253,238
	dc.w	225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w	894,844,796,752,709,670,632,597,563,532,502,474
	dc.w	447,422,398,376,355,335,316,298,282,266,251,237
	dc.w	223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w	887,838,791,746,704,665,628,592,559,528,498,470
	dc.w	444,419,395,373,352,332,314,296,280,264,249,235
	dc.w	222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w	881,832,785,741,699,660,623,588,555,524,494,467
	dc.w	441,416,392,370,350,330,312,294,278,262,247,233
	dc.w	220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w	875,826,779,736,694,655,619,584,551,520,491,463
	dc.w	437,413,390,368,347,328,309,292,276,260,245,232
	dc.w	219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w	868,820,774,730,689,651,614,580,547,516,487,460
	dc.w	434,410,387,365,345,325,307,290,274,258,244,230
	dc.w	217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w	862,814,768,725,684,646,610,575,543,513,484,457
	dc.w	431,407,384,363,342,323,305,288,272,256,242,228
	dc.w	216,203,192,181,171,161,152,144,136,128,121,114

mt_chan1temp:	blk.l	5
		dc.w	1
		blk.w	21
		dc.w	2
		blk.w	21
		dc.w	4
		blk.w	21
		dc.w	8
		blk.w	11

mt_SampleStarts:	blk.l	31,0

mt_SongDataPtr:	dc.l 0
mt_LWTPtr:	dc.l 0
mt_oldirq:	dc.l 0

mt_speed:	dc.b 6
mt_counter:	dc.b 0
mt_SongPos:	dc.b 0
mt_PBreakPos:	dc.b 0
mt_PosJumpFlag:	dc.b 0
mt_PBreakFlag:	dc.b 0
mt_LowMask:	dc.b 0
mt_PattDelTime:	dc.b 0
mt_PattDelTime2:	dc.b 0,0
mt_PatternPos:	dc.w 0
mt_DMACONtemp:	dc.w 0

;---------------------------------------------------------------------
;-----------------------------------------------------------------------
;SpaceBalls '9Fingers' trackloader...
;INPUT:	a0	- addr
;	d0	- start track (*2 !)
;	d1	- nr. of tracks to read (*2 !)
; dl_DISK:.w	- drive nr (0,1,2,3)
;OUTPUT:
;	d0	- 0 if all OK, -1 if error (no disk)

;-----------------------------------------------------------------------
;start from 'dl_START' or 'dl_FINDDISK'...

dl_START:	bsr.s	dl_SetDma
		bsr.w	lbC0001D2	;set drive & wait for disk
lbC000004:	subq	#1,d1
		move	#10,dl_COUNTER+2
		bsr.w	lbC000174
lbC000008:	btst	#0,d0
		bne.b	lbC000018
		bset	#2,$BFD100
		bra.b	lbC000020

lbC000018:	bclr	#2,$BFD100
lbC000020:	bsr.b	lbC00006E
		btst	#0,d0
		beq.b	lbC000032
		move.w	d0,-(sp)
		moveq	#0,d0
		bsr.w	lbC00015A
		move.w	(sp)+,d0
lbC000032:	addq.w	#1,d0
		lea	dl_COUNTER(pc),a3
		addq.w	#1,(a3)
		dbra	d1,lbC000008
		andi.w	#$FFFE,(a3)
		bsr.w	lbC000228
		moveq	#0,d0
		rts				;quit here if all OK

dl_SetDma:	moveq	#0,d2
		moveq	#0,d3
		moveq	#0,d4
		moveq	#0,d5
		moveq	#0,d6
		moveq	#0,d7
		lea	$dff000,a6
		move	#$1002,$9a(a6)	;drive ints clear
		move	#$8010,$96(a6)	;drive DMA on
		rts

dl_FindDisk:	bsr.s	dl_SetDma	;check drive for disk
		bsr.w	lbC0001F6	;if no disk - quit
		tst.w	d5
		bne.b	lbC000052
		bra.b	lbC000004

lbC000052:	move.w	#3,d0
		bsr.w	lbC000142
		moveq	#2,d0
		bsr.w	lbC00015A
		move.w	#3,d0
		bsr.w	lbC000142
		bsr.w	lbC000228
		moveq	#-1,d0
		rts				;here quit if no disk

lbC00006E:	move.w	#$4000,$24(a6)
		move.l	#dl_BUFFER,$20(a6)
		move.w	#$7F00,$9E(a6)
		move.w	#$4489,$7E(a6)
		move.w	#$9500,$9E(a6)
		lea	$BFE001,a5
lbC000094:	btst	#2,(a5)
		beq.b	lbC0000D4
		btst	#5,(a5)
		bne.b	lbC000094
		move.w	#2,$9C(a6)
		move.w	#$9900,$24(a6)
		move.w	#$9900,$24(a6)
lbC0000B2:	btst	#2,(a5)
		beq.b	lbC0000D4
		btst	#1,$1F(a6)
		beq.b	lbC0000B2
		move.w	#$4000,$24(a6)
		bsr.b	lbC0000E0
		lea	dl_COUNTER+2(pc),a3
		tst.w	d2
		beq.b	lbC0000D6
		subq.w	#1,(a3)
		bne.b	lbC00006E
lbC0000D4:	rts

lbC0000D6:	move.w	#10,(a3)
		lea	$1600(a0),a0
		rts

lbC0000E0:	lea	DL_BUFFER,a2
		moveq	#10,d5
		move.l	#$55555555,d7
lbC0000EE:	cmpi.w	#$4489,(a2)+
		bne.b	lbC0000EE
		cmpi.w	#$4489,(a2)
		bne.b	lbC0000FC
		addq.l	#2,a2
lbC0000FC:	move.w	2(a2),d3
		move.w	6(a2),d4
		and.w	d7,d3
		and.w	d7,d4
		add.w	d3,d3
		or.w	d4,d3
		add.w	d3,d3
		andi.w	#$FF00,d3
		movea.l	a0,a3
		lea	(a3,d3.w),a3
		lea	$38(a2),a2
		moveq	#$7F,d6
lbC00011E:	move.l	$200(a2),d3
		move.l	(a2)+,d4
		and.l	d7,d4
		and.l	d7,d3
		add.l	d4,d4
		or.l	d3,d4
		move.l	d4,(a3)+
		dbra	d6,lbC00011E
		lea	$204(a2),a2
		dbra	d5,lbC0000EE
		moveq	#0,d2
		rts

		moveq	#-1,d2
		rts

lbC000142:	move	d1,-(sp)
lbC000144:	move.b	6(a6),d1
		addi.b	#$22,d1
lbC00014C:	cmp.b	6(a6),d1
		bne.b	lbC00014C
		subq.w	#1,d0
		bne.b	lbC000144
		move	(sp)+,d1
		rts

lbC00015A:	lea	$BFD100,a5
		bclr	#1,(a5)
		or.b	d0,(a5)
		bclr	#0,(a5)
		bset	#0,(a5)
		move.w	#3,d0
		bra.b	lbC000142

lbC000174:	move.w	d0,-(sp)
		move.w	d0,d2
		bclr	#0,d2
		lea	DL_COUNTER(pc),a3
		tst.w	(a3)
		bpl.b	lbC0001A8
		btst	#4,$BFE001
		beq.b	lbC0001A6
lbC00018E:	moveq	#2,d0
		bsr.b	lbC00015A
		btst	#2,$BFE001
		beq.b	lbC0001D0
		btst	#4,$BFE001
		bne.b	lbC00018E
lbC0001A6:	clr.w	(a3)
lbC0001A8:	move.w	DL_COUNTER(pc),d0
		bclr	#0,d0
		sub.w	d0,d2
		tst.w	d2
		beq.b	lbC0001CA
		bpl.b	lbC0001BE
		neg.w	d2
		moveq	#2,d0
		bra.b	lbC0001C0

lbC0001BE:	moveq	#0,d0
lbC0001C0:	lsr.w	#1,d2
		subq.w	#1,d2
lbC0001C4:	bsr.b	lbC00015A
		dbra	d2,lbC0001C4
lbC0001CA:	move.w	(sp)+,d0
		move.w	d0,(a3)
		rts

lbC0001D0:	rts

lbC0001D2:	lea	$BFD100,a5
		move	DL_DISK(pc),d5
		move.b	dl_offsets(pc,d5.w),d5
		neg.b	d5
		or.b	d5,(a5)
		andi.b	#$7F,(a5)
		neg.b	d5
		and.b	d5,(a5)
lbC0001EA:
		btst	#5,$BFE001
		bne.b	lbC0001EA
		rts

lbC0001F6:	lea	$BFD100,a5
		move	DL_DISK(pc),d5
		move.b	dl_offsets(pc,d5.w),d5
		neg.b	d5
		or.b	d5,(a5)
		andi.b	#$7F,(a5)
		neg.b	d5
		and.b	d5,(a5)
		lea	$BFE001,a5
;		move	#5000,d5
lbC000214:;	subq	#1,d5			;if no such drive
	;	bmi.s	lbC000224
		btst	#2,(a5)
		beq.b	lbC000224
		btst	#5,(a5)
		bne.b	lbC000214
		moveq	#0,d5			;ok - disk found
		rts

lbC000224:	moveq	#1,d5			;no disk found
		rts

lbC000228:	lea	$BFD100,a5
		ori.b	#$F8,(a5)
		andi.b	#$87,(a5)
		ori.b	#$F8,(a5)
		rts

dl_Offsets:	dc.b	$f7,$ef,$df,$bf
dl_DISK:	dc.w	0			;drive NR
dl_COUNTER:	dc.w	-1,0			;-1 to init drive

;dl_BUFFER:	equ	$a0000

;---------------------------------------------------------------------
copper0:
dc.l	$1800000,$1000300,-2

l_copper:
dc.w	$180,0,$182,0,$184,0,$186,0
dc.w	$188,0,$18a,0,$18c,0,$18e,0

l_scr:
dc.w	$e0,l_screen/$10000,$e2,l_screen&$ffff
l_scr2:
dc.w	$e4,l_pic/$10000,$e6,l_pic&$ffff
dc.w	$e8,[l_pic+11520]/$10000,$ea,[l_pic+11520]&$ffff

dc.w	$108,0,$10a,0
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$1020000,$1040000
dc.w	$1fc,0,$106,0,$10c,0

dc.l	$3701ff00,$01001300
dc.l	$7701ff00
dc.l	$01003300
dc.l	$bf01ff00
dc.l	$01001300
dc.l	$ff01ff00,$01000300
dc.l	-2


l_copper2:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0,$1A0,0,$1A2,0,$1A4,0,$1A6,0
dc.w	$1A8,0,$1AA,0,$1AC,0,$1AE,0,$1B0,0
dc.w	$1B2,0,$1B4,0,$1B6,0,$1B8,0,$1BA,0,$1BC,0,$1be,0

dc.w	$108,0,$10a,0
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$1020000,$1040000
dc.w	$1fc,0,$106,0,$10c,0
l_scr3:
dc.w	$e0,l_arrakis/$10000,$e2,l_arrakis&$ffff
dc.w	$e4,[l_arrakis+11600]/$10000,$e6,[l_arrakis+11600]&$ffff
dc.w	$e8,[l_arrakis+2*8000]/$10000,$ea,[l_arrakis+2*8000]&$ffff
dc.w	$ec,[l_arrakis+3*8000]/$10000,$ee,[l_arrakis+3*8000]&$ffff
dc.w	$f0,[l_my+4*8000]/$10000,$f2,[l_my+4*8000]&$ffff

l_up:
dc.l	$5001ff00
l_bpl:
dc.l	$0100a300
l_dn:
dc.l	$e101ff00,$01000300
dc.l	-2

;-------------------------------------------------------------------
OldLev3:	dc.l	0
Finished:	dc.w	0
JumpAdr:dc.l	0
rej:	blk.l	18,0
scron:	dc.l	l_screen,l_screen+[200*40]
l_pion:	dc.w	240,319
	dc.w	-200,-180,-160,-140,-120,-100,-80,-60,-40,-20
	dc.w	0,20,40,60,80,100,120,140,160,180

l_pic:
incbin	"DAT1:GFX/NAPISY.P"
l_my:
incbin	"DAT1:GFX/MY.LOGO"
l_arrakis:
incbin	"DAT1:GFX/ARRAKIS.LOGO"
mt_data:
incbin	"DAT1:MODS/mod.short_intro.pro"

;-------------------------------------------------------------------
l_screen:	equ	BASE+$62000	;$3e80
dl_buffer:	equ	l_screen+$3e80	;$3200

;l_pic:		equ	l_screen+$3e80			;$5a00+8
;l_my:		equ	l_screen+$3e80+$5a08		;$9c40+64
;l_arrakis:	equ	l_screen+$3e80+$5a08+$9c80	;$5aa0+8
;
;>extern	"DAT1:GFX/NAPISY.P",l_pic,-1
;>extern	"DAT1:GFX/MY.LOGO",l_my,-1
;>extern	"DAT1:GFX/ARRAKIS.LOGO",l_arrakis,-1

end:
endall:	equ	end+$3e80+$3200
;-------------------------------------------------------------------

