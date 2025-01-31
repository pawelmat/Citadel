����    �  ;  �  �  S  F�  �  -�  ;CITADEL loader...
;done by KANE, modified from demo version on 17.02.1995
;HD VERSION!!!

;save: wb st en

exe:	equ	0


IFEQ	EXE
SH:	equ	0
ELSE
;SH:	equ	$100000			;on 2 Meg
SH:	equ	0
ENDC

HardLoader:	equ	$f8000

ADDMEM:		equ	$7ffea
VBR_BASE:	equ	$7ffee
MC68000:	equ	$7fff2
MEMORY:		equ	$7fff8
DELAY:		equ	$7ffd8
HD:		equ	$7ffca
OLD3:		equ	$7ffc4

VBLANK: macro
	cmp.b	#$ff,6(a0)
	bne.s	*-6
	cmp.b	#$ff,6(a0)
	beq.s	*-6
	endm
wait:	macro
	move	#\1,d0
.w\@:	cmp.b	#$ff,6(a0)
	bne.s	*-6
	cmp.b	#$ff,6(a0)
	beq.s	*-6
	dbf	d0,.w\@
	endm

	org	$7d000
	load	$7d000+SH


s:		bsr	DetectMem
		move.l	d2,ADDMEM		;add memoty for table
		move.l	d1,MEMORY		;ext memory (0 if no)
;move.l	#0,memory
		bne.s	.s2
		move.l	#"NONE",p_mem
		move.l	#"    ",p_mem+4
.s2:		move.l	4.w,a6
		lea	VBR_BASE,a1
		move.l	#0,(a1)			;default settings
		move	#0,MC68000
		move	296(a6),d0
		move	d0,d1
		andi	#%11110000,d1
		bne.s	.s3
		move.l	#"NONE",p_kop
		move.l	#"    ",p_kop+4
.s3:		andi	#%1111,d0
		move	d0,d1
		lsl	#4,d0
		ori	#%00001000,d0
		move.b	#"5",d2
.s4:		subq	#1,d2
		add.b	d0,d0
		bcc.s	.s4
		move.b	d2,p_proc
		tst	d0
		beq.s	No_VBR
		lea	CheckVBR(pc),a5		;set VBR on 68020+
		jsr	-30(a6)			;supervisor
No_VBR:		move.l	VBR_base,a1
		lea	start(pc),a2
		move.l	a2,$bc(a1)
		trap	#15
		rts
CheckVBR:	movec	VBR,d0			;$4e7a0801
		move.l	d0,VBR_BASE
		move	#1,MC68000		;20++ found
		move.l	#"DETE",p_cah
		move.l	#"CTED",p_cah+4
		rte


start:		lea	$dff000,a0
		move.l	#copper0,d0
		VBLANK
		move.l	d0,$80(a0)
		move	#0,$88(a0)
		VBLANK
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		move	#$7fff,$96(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move	#$8390,$96(a0)
		IFNE	EXE
		move.l	USP,a1
		lea	-500(a1),a1
		lea	$f7000-500,a2
		move	#256,d0
CopyStack:	move.l	(a1)+,(a2)+
		lea	$f7000,a1
		move.l	a1,USP
		lea	$85000,a7		;set stack
		ENDC
		move	#1,HD			;set HD load

		lea	$dff000,a0
		cmp.b	#$40,6(a0)		;check speed for loader
		bne.s	*-6
		cmp.b	#$40,6(a0)
		beq.s	*-6
		moveq	#0,d0
		moveq	#0,d1
		move.b	6(a0),d1
		move	#$555*2,d7
.loop2:		nop
		dbf	d7,.loop2
		move.b	6(a0),d0
		sub	d1,d0
		move.l	#$800*70,d1
		divu	d0,d1
;	add	d1,d1
;		move	d1,dl_Delay
		move	d1,DELAY

;		lea	$7ffda,a2
;		move.l	#0,(a2)
;		lea	120(a0),a1
;		moveq	#7,d0
;SprtWon:	move.l	a2,(a1)+
;		dbf	d0,SprtWon

	lea	l_scr,a1
	move	#7500-1,d1
gl:	move.l	#0,(a1)+
	dbf	d1,gl

	lea	Loader(pc),a1
	lea	HardLoader,a2
	move	#EndLoader-Loader-1,d1
gl2:	move.b	(a1)+,(a2)+
	dbf	d1,gl2

		move	#$3,$96(a0)
		move.l	#bzyk,$a0(a0)		;adress
		move	#2704,$a0+4(a0)		;length in words
		move	#990,$a0+6(a0)		;period
		move	#1,$a0+8(a0)		;volume
		move.l	#bzyk,$b0(a0)		;adress
		move	#2704,$b0+4(a0)		;length in words
		move	#980,$b0+6(a0)		;period
		move	#1,$b0+8(a0)		;volume
		VBLANK
		move	#$8003,$96(a0)

		lea	l_scr,a2
		move.l	#copper,d0
		VBLANK
;		bsr	SetCopper
move.l	d0,$80(a0)
move	#0,$88(a0)

		moveq	#1,d1
Strips1:	moveq	#13,d2
		lea	(a2),a1
		move	d1,d3
stloop1:	btst	#0,d3
		beq.s	s11
		move	#-1,(a1)
s11:		btst	#1,d3
		beq.s	s12
		move	#-1,6000(a1)
s12:		btst	#2,d3
		beq.s	s13
		move	#-1,2*6000(a1)
s13:		btst	#3,d3
		beq.s	s14
		move	#-1,3*6000(a1)
s14:		lea	40*10(a1),a1
		addq	#1,d3
		cmpi	#16,d3
		dbeq	d2,stloop1
		lea	2(a2),a2
		addq	#1,d1
		cmpi	#16,d1
		bne.s	Strips1

		lea	l_scr,a2
		moveq	#1,d1
Strips2:	moveq	#14,d2
		lea	(a2),a1
		move	d1,d3
stloop2:	btst	#0,d3
		beq.s	s21
		lea	(a1),a3
		bsr.w	postaw
s21:		btst	#1,d3
		beq.s	s22
		lea	6000(a1),a3
		bsr.w	postaw
s22:		btst	#2,d3
		beq.s	s23
		lea	2*6000(a1),a3
		bsr.w	postaw
s23:		btst	#3,d3
		beq.s	s24
		lea	3*6000(a1),a3
		bsr.w	postaw
s24:		lea	2(a1),a1
		addq	#1,d3
		cmpi	#16,d3
		dbeq	d2,stloop2
		lea	40*10(a2),a2
		addq	#1,d1
		cmpi	#16,d1
		bne.s	Strips2

		wait	10
		bsr	l_SetColors

		move.l	VBR_base,a1
		lea	OldLev3(pc),a2
		move.l	$6c(a1),(a2)		;set lev3 interrupt
		move.l	(a2),OLD3
		lea	NewLev3(pc),a2
		move.l	a2,$6c(a1)

		VBLANK
		move	#$83c0,$96(a0)
		move	#$e02c,$9a(a0)

; tu uruchomic int3...

		tst.l	MEMORY
		bne.s	TuLoad
		move.l	#t7,p_what+30		;if bad mem
		move.l	#-1,p_what+34
		IFNE	EXE
memend:		bra.s	memend
		ENDC

;tu loading...
TuLoad:
		lea	$3e000,a1
		move	#1,d0		;start track
		move	#1,d1		;nr of tracks
		jsr	HardLoader

		lea	$dff000,a0
		VBLANK
		move	#$7fff,$9a(a0)
		move	#$c020,$9a(a0)

		lea	$3e000,a0
		lea	$3f000,a1
		bsr	decrunch

		lea	$dff000,a0

MainLoop:	tst	p_what+2
		bpl.s	MainLoop

		wait	40

;rrr:	btst.b	#6,$bfe001
;	bne.s	rrr

		bsr	l_FadeColors
		move	#$f,$96(a0)		;sound off

		lea	$dff000,a0
		VBLANK
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		IFEQ	EXE
		move.l	VBR_base,a1
		move.l	OldLev3(pc),$6c(a1)
		move	#$e02c,$9a(a0)
		move	#$83f0,$96(a0)
		rte
		ELSE
		jmp	$3f000
		ENDC

;-----------------------------------------------------------------------
NewLev3:	movem.l d0-a6,-(sp)
		bsr	p_PRINT
		bsr	p_PRINT
		movem.l	(sp)+,d0-a6
		move	#$20,$dff09c
		rte
;-----------------------------------------------------------------------

postaw:		ori.b	#$80,(a3)
		ori.b	#$80,40(a3)
		ori.b	#$80,2*40(a3)
		ori.b	#$80,3*40(a3)
		ori.b	#$80,4*40(a3)
		ori.b	#$80,5*40(a3)
		ori.b	#$80,6*40(a3)
		ori.b	#$80,7*40(a3)
		ori.b	#$80,8*40(a3)
		ori.b	#$80,9*40(a3)
		rts

;-----------------------------------------------------------------------
;Memory Detect done by Pillar... (30.11.1994)
;Nota:ta procedura juz musi wszedzie dzialac,chyba jest troche na wyrost
;zabespieczona przed dziwnymi konfiguracjami , ale to przeciez nie 
;szkodzi ani troche .....
;					�����r/s�s�e�t
;******************************************************
; BOOM HERE IT IS ...............
; A TERAZ ZANURZ TO W PLECHE - TAK JAK MAHANDI, I POSMARUJ POZNIEJ SMALCEM.
; NIE ZAPOMNIJ O DAWCE URYNY NA TRAWIENIE I ROPNYCH UPLAWACH DO SMAKU.

dtc_SIZEOF:	equ	65356	; rozmiar tablicy 
                                ; szukany za .5 Mb fastu

; +10Kb by Pillar/SCT on 3.4.95

MaxExtMem:		equ	78
MaxLocMem:		equ	62

MEMF_CHIP:		equ	2^1
MEMF_FAST:		equ	2^2
MEMF_CLEAR:		equ	2^16

_LVOAllocMem:		equ	-$0c6
_LVOFreeMem:		equ	-$0d2
_LVOTypeOfMem:		equ	-$216

CALLEXE:	Macro
	move.l	$4.w,a6
	jsr	\1(a6)
	Endm

; d0 - bity od 15-8 zapalone to komputer ma 1Mb Chip , zgaszone ma tylko .5Mb
; d0 - bity od 7-0 zapalone to komputer ma .5 FastMem , zgaszone to nie ma .
; d0 - bity od 16-24 zapalone to jest cos za .5 Mb fastu
; d1 - jezeli bity 7-0 w d0 sa zapalone to w d1 dostajesz offset do .5Mb
;	obszaru w pamieci Fast , w przeciwnym wypadku otrzymujesz tu NULL .


DetectMem:		moveq	#0,d0
			moveq	#0,d1
			moveq	#0,d2
			moveq	#0,d3
			lea	Word(pc),a2
			move.l	$4.w,a0
			move.l	MaxLocMem(a0),d0
			cmp.l	#$100000,d0
			sge	(a2)

			move.l	#$80000,d0
			move.l	#MEMF_FAST+MEMF_CLEAR,d1
			CALLEXE	_LVOAllocMem
			tst.l	d0
			beq.s	.Pupcia
			st	1(a2)
			move.l	d0,d3
			move.l	d0,a1
			move.l	#$80000,d0
			CALLEXE	_LVOFreeMem

.Pupcia:		tst.b	1(a2)
			bne.s	.Okej
			lea	$27ffff,a1
			CALLEXE	_LVOTypeOfMem
			tst.l	d0
			beq.s	.Kupa
			st	1(a2)
			moveq	#0,d1
			moveq	#$20,d1
			swap	d1
			move.l	d1,d3

.Kupa:			tst.b	1(a2)
			bne.s	.Okej
			move.l	$4.w,a0
			move.l	MaxExtMem(a0),d0
			beq.s	.Okej
			st	1(a2)
			sub.l	#$80000,d0
			move.l	d0,d3

.Okej:			tst.b	1(a2)
			bne.s	.Okey2
			move.l	$4.w,a0
			move.l	MaxLocMem(a0),d0
			cmp.l	#$150000,d0
			sge	1(a2)
			move.l	#$100000,d3

.Okey2:			moveq	#0,d2		; +10 Kb
			tst.b	1(a2)
			beq.s	.Okey3
			move.l	d3,a1
			adda.l	#$80000+dtc_SIZEOF,a1
			CALLEXE	_LVOTypeOfMem
			tst.l	d0
			sne	d2
.Okey3:			moveq	#0,d0
			move	(a2),d0
			swap	d2
			or.l	d2,d0
			move.l	d3,d1

			moveq	#0,d2		;add fast mem
			move	d0,d3
			andi	#$ff,d3
			bne.s	.eu2		;is fast
			move.l	#$100000,d1
			andi	#$ff00,d0
			bne.s	.eu3
			moveq	#0,d1
.eu3:			rts

.eu2:			andi.l	#$ff0000,d0
			beq.s	.eu3		;no add fast mem
			move.l	d1,d2
			addi.l	#$82000,d2	;add fast mem
			rts

;-----------------------------------------------------------------------
p_what:	dc.w	-1,0			;timerOnOff,offset (-1 if end)
	dc.l	0			;screen addr
	dc.w	2			;delay CNT
	dc.l	5,t1,30,t2,10,t3,10,t4,10,t5,20,t6,10,-1

t1:	dc.b	"@",2,10,"...CHECKING SYSTEM CONFIGURATION...",-1
even
t2:	dc.b	"@",3,50,"EXTRA MEMORY:      "
p_mem:	dc.b	"DETECTED",-1
even
t3:	dc.b	"@",3,60,"PROCESSOR:         MC680"
p_proc:	dc.b	0,"0",-1
even
t4:	dc.b	"@",3,70,"PROCESSOR CACHE:   "
p_cah:	dc.b	"NONE    ",-1
even
t5:	dc.b	"@",3,80,"COPROCESSOR:       "
p_kop:	dc.b	"DETECTED",-1
t6:	dc.b	"@",3,110,"STATUS:           CONFIGURATION OK.",-1
even

p_PRINT:	lea	p_what(pc),a1
		tst	2(a1)
		bmi.s	p_EndIt
		subi	#1,8(a1)
		bmi.s	p_print0
p_endit:	rts
p_print0:	move	#2,8(a1)
		move	2(a1),d0	;offset
		move.l	10(a1,d0.w),d1
		tst	(a1)		;timer?
		beq.s	p_print2
		subq	#1,d1
		bmi.s	p_GetNext
		move.l	d1,10(a1,d0.w)
		rts
p_GetNext:	not	(a1)
		addq	#4,d0
		move.l	10(a1,d0.w),d1
		bpl.s	.p_gn2
		moveq	#-1,d0		;if end of all text
.p_gn2:		move	d0,2(a1)
		rts
p_print2:	move.l	d1,a2		;text
		moveq	#0,d1
		move.b	(a2)+,d1
		bmi.s	p_GetNext
		cmpi.b	#'@',d1
		bne.s	p_print3
		lea	l_scr+4*6000,a3	;set new pos
		move.b	(a2)+,d1
		lea	(a3,d1.w),a3
		move.b	(a2)+,d1
		mulu	#40,d1
		lea	(a3,d1.w),a3
		move.l	a3,4(a1)
		moveq	#0,d1
		move.b	(a2)+,d1
p_print3:	subi	#32,d1
		lsl	#3,d1
		lea	fonts,a3
		move.l	4(a1),a4
		lea	(a3,d1.w),a3
		REPT	8
		move.b	(a3)+,(a4)
		lea	40(a4),a4
		ENDR
		move.l	a2,10(a1,d0.w)
		addi.l	#1,4(a1)
		rts

t7:	dc.b	"@",3,95,"   IT IS IMPOSSIBLE TO RUN CITADEL  "
;t7:	dc.b	"@",3,95,"BRAK DODATKOWEJ PAMIeCI UNIEMOzLIWIA"
	dc.b	"@",9,105,"BECAUSE OF LACK OF EXTRA MEMORY"
;	dc.b	"@",9,105,"URUCHOMIENIE CYTADELI !!!      "
	dc.b	"@",1,120,"   AT LEAST 1 MB OF MEMORY IS NEEDED!"
;	dc.b	"@",1,120,"PROGRAM WYMAGA CONAJMNIEJ 1 MB PAMIeCI!"
	dc.b	"@",1,127,"   ----------------------------------",-1

even
;-----------------------------------------------------------------------
;;d0 - copper addr
;SetCopper:
;		movem.l	a0/a1,-(sp)
;		lea	CHCOP,a1
;		move	#$82,(a1)+
;		move	d0,(a1)+
;		swap	d0
;		lea	-25(a0),a0
;		move	#$80,(a1)+
;		move	d0,(a1)+
;		move	#$88,(a1)+
;		move	#0,(a1)+
;		move.l	#-2,(a1)+
;		lea	CHCOP,a1
;		move	a1,$80+25(a0)
;		move	#0,$88+25(a0)
;		lea	$dff000,a0
;		VBLANK
;		VBLANK
;		move	#$2e,(a1)+		;copcon
;		move	#1,(a1)+
;		move	#$58,(a1)+		;bltsize
;		move	#$fffe,(a1)+
;		move	#$28,(a1)+
;		move	#$e57f,(a1)+		;refptr
;		movem.l	(sp)+,a0/a1
;		rts

;-----------------------------------------------------------------------
l_setcolors:	move	#0,d0
l_setcol:	lea	copper(pc),a1
		lea	coltab(pc),a2
		move	#31,d3				;color nr. - 1
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
		VBLANK
		VBLANK
		VBLANK
		move	d0,d1
		lsl	#2,d1
		andi	#63,d1
		move	d1,$a8(a0)
		move	d1,$b8(a0)
		addq	#1,d0
		cmpi	#16,d0
		bne.w	l_setcol
		rts

l_fadecolors:	move	#15,d0
l_fadcol:	lea	copper(pc),a1
		move	#31,d3			;no. of colors - 1
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
		VBLANK
		VBLANK
		VBLANK
		move	d0,d1
		lsl	#2,d1
		andi	#63,d1
		move	d1,$a8(a0)
		move	d1,$b8(a0)
		subq	#1,d0
		bpl.w	l_fadcol
		rts

;-----------------------------------------------------------------------
;-----------------------------------------------------------------------
****************************************************
*** PowerPacker 2.0 FAST decrunch routine (v1.5) ***
*** Resourced by BC/LUZERS			 ***

;a0.l - crunched data
;a1.l - buffer

Decrunch:
	movem.l	d1-d7/a2-a6,-(sp)
	move.l	(a0),d0			;dlugosc
	lea	4(a0),a2
	add.l	d0,a0
	lea	l0494(pc),a5
	moveq	#$18,d6
	moveq	#0,d4
	move.w	#$00FF,d7
	moveq	#1,d5
	move.l	a1,a4
	move.l	-(a0),d1
	tst.b	d1
	beq.s	l0266
	lsr.l	#1,d5
	beq.s	l02A2
l0262:	subq.b	#1,d1
	lsr.l	d1,d5
l0266:	lsr.l	#8,d1
	add.l	d1,a1
l026A:	lsr.l	#1,d5
	beq.s	l02A8
l026E:	bcs	l0310
	moveq	#0,d2
l0274:	moveq	#0,d1
	lsr.l	#1,d5
	beq.s	l02AE
l027A:	roxl.w	#1,d1
	lsr.l	#1,d5
	beq.s	l02B4
l0280:	roxl.w	#1,d1
	add.w	d1,d2
	subq.w	#3,d1
	beq.s	l0274
	moveq	#0,d0
l028A:	move.b	d5,d4
	lsr.l	#8,d5
	beq.s	l02C6
l0290:	move.b	-$0080(a5,d4.w),d0
	move.b	d0,-(a1)
	dbra	d2,l028A

	cmp.l	a1,a4
	bcs.s	l0310
	bra	l03F0

l02A2:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0262

l02A8:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l026E

l02AE:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l027A

l02B4:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0280

l02BA:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0316

l02C0:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l031C

l02C6:	move.b	$007F(a5,d4.w),d0
	move.l	-(a0),d5
	move.w	d5,d3
	lsl.w	d0,d3
	bchg	d0,d3
	eor.w	d3,d4
	and.w	d7,d4
	moveq	#8,d1
	sub.w	d0,d1
	lsr.l	d1,d5
	add.w	d6,d0
	bset	d0,d5
	bra.s	l0290

l02E2:	move.b	$007F(a5,d4.w),d0
	move.l	-(a0),d5
	move.w	d5,d3
	lsl.w	d0,d3
	bchg	d0,d3
	eor.w	d3,d4
	and.w	d7,d4
	moveq	#8,d1
	sub.w	d0,d1
	lsr.l	d1,d5
	add.w	d6,d0
	bset	d0,d5
	bra.s	l0324

l02FE:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l035E

l0304:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0364

l030A:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l036A

l0310:	moveq	#0,d2
	lsr.l	#1,d5
	beq.s	l02BA
l0316:	roxl.w	#1,d2
	lsr.l	#1,d5
	beq.s	l02C0
l031C:	roxl.w	#1,d2
	move.b	d5,d4
	lsr.l	#8,d5
	beq.s	l02E2
l0324:	moveq	#0,d3
	move.b	-$0080(a5,d4.w),d3
	cmp.w	#3,d2
	bne.s	l03AC
	bclr	#7,d3
	beq.s	l037E
	moveq	#13,d0
	sub.b	0(a2,d2.w),d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,d0
	jmp	l035A(pc,d0.w)

l0348:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0370

l034E:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0376

l0354:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l037C

l035A:	lsr.l	#1,d5
	beq.s	l02FE
l035E:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0304
l0364:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l030A
l036A:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0348
l0370:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l034E
l0376:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0354
l037C:	roxl.w	#1,d3
l037E:	moveq	#0,d1
	lsr.l	#1,d5
	beq.s	l039A
l0384:	roxl.w	#1,d1
	lsr.l	#1,d5
	beq.s	l03A0
l038A:	roxl.w	#1,d1
	lsr.l	#1,d5
	beq.s	l03A6
l0390:	roxl.w	#1,d1
	add.w	d1,d2
	subq.w	#7,d1
	beq.s	l037E
	bra.s	l03DC

l039A:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0384

l03A0:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l038A

l03A6:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l0390

l03AC:	moveq	#13,d0
	sub.b	0(a2,d2.w),d0
	move.w	d0,d1
	add.w	d0,d0
	add.w	d1,d0
	add.w	d0,d0
	jmp	l03BE(pc,d0.w)

l03BE:	lsr.l	#1,d5
	beq.s	l03F6
l03C2:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l03FC
l03C8:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0402
l03CE:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l0408
l03D4:	roxl.w	#1,d3
	lsr.l	#1,d5
	beq.s	l040E
l03DA:	roxl.w	#1,d3
l03DC:	move.b	0(a1,d3.w),-(a1)
l03E0:	move.b	0(a1,d3.w),-(a1)
	dbra	d2,l03E0

	cmp.l	a1,a4
	bcs	l026A
l03F0:	movem.l	(sp)+,d1-d7/a2-a6
	rts

l03F6:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03C2

l03FC:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03C8

l0402:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03CE

l0408:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03D4

l040E:	move.l	-(a0),d5
	roxr.l	#1,d5
	bra.s	l03DA

	or.l	#$40C020A0,d0
	bra.s	l03FC

	dc.l	$109050D0,$30B070F0,$088848C8,$28A868E8,$189858D8
	dc.l	$38B878F8,$048444C4,$24A464E4,$149454D4,$34B474F4
	dc.l	$0C8C4CCC,$2CAC6CEC,$1C9C5CDC,$3CBC7CFC,$028242C2
	dc.l	$22A262E2,$129252D2,$32B272F2,$0A8A4ACA,$2AAA6AEA
	dc.l	$1A9A5ADA,$3ABA7AFA,$068646C6,$26A666E6,$169656D6
	dc.l	$36B676F6,$0E8E4ECE,$2EAE6EEE,$1E9E5EDE,$3EBE7EFE
l0494:	dc.l	$018141C1,$21A161E1,$119151D1,$31B171F1,$098949C9
	dc.l	$29A969E9,$199959D9,$39B979F9,$058545C5,$25A565E5
	dc.l	$159555D5,$35B575F5,$0D8D4DCD,$2DAD6DED,$1D9D5DDD
	dc.l	$3DBD7DFD,$038343C3,$23A363E3,$139353D3,$33B373F3
	dc.l	$0B8B4BCB,$2BAB6BEB,$1B9B5BDB,$3BBB7BFB,$078747C7
	dc.l	$27A767E7,$179757D7,$37B777F7,$0F8F4FCF,$2FAF6FEF
	dc.l	$1F9F5FDF,$3FBF7FFF,$00010102,$02020203,$03030303
	dc.l	$03030304,$04040404,$04040404,$04040404,$04040405
	dc.l	$05050505,$05050505,$05050505,$05050505,$05050505
	dc.l	$05050505,$05050505,$05050506,$06060606,$06060606
	dc.l	$06060606,$06060606,$06060606,$06060606,$06060606
	dc.l	$06060606,$06060606,$06060606,$06060606,$06060606
	dc.l	$06060606,$06060606,$06060606,$06060607,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070707,$07070707,$07070707,$07070707,$07070707
	dc.l	$07070700

;-----------------------------------------------------------------------
coltab:
dc.w	0,$f,$e,$d,$c,$b,$a,$9,$8,$7,$6,$5,$4,$3,$2,$1
dc.w	$aaa
blk.w	15,$888

copper0:
dc.l	$1fc0000,$1060c00
dc.l	$1000300,$1800000,-2


copper:
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
dc.w	$e0,l_scr/$10000,$e2,l_scr&$ffff
dc.w	$e4,[l_scr+6000]/$10000,$e6,[l_scr+6000]&$ffff
dc.w	$e8,[l_scr+2*6000]/$10000,$ea,[l_scr+2*6000]&$ffff
dc.w	$ec,[l_scr+3*6000]/$10000,$ee,[l_scr+3*6000]&$ffff
dc.w	$f0,[l_scr+4*6000]/$10000,$f2,[l_scr+4*6000]&$ffff

dc.l	$3701ff00,$01005300,$cd01ff00,$01000300
dc.l	-2

;---------------------------------------------------------------------
Word:		dc.w	0
OldLev3:	dc.l	0

bzyk:
incbin	"DAT1:SND/BUCZENIE.SND"
fonts:
incbin	"DAT1:GFX/FONTS01.FNT"
Loader:
incbin	"CODE:BIN/HardDisk.dat"
EndLoader:
;---------------------------------------------------------------------
end:
;dl_buffer:	blk.b	$3200,0
;l_scr:		ds.b	30000		;$7530

l_scr:		equ	$72000
dl_buffer:	equ	$79530


st=s+SH
en=end+SH

**
