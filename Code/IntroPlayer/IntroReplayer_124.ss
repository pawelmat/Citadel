����   �  5�  L�  -W  Ah  �[  �5  �  Ӊ  �E
;	*************************************************
;	*	      Cytadela Intro Replayer		*
;	*    Re-Coded on 20.05.1995  by KANE of SUSPECT	*
;	*************************************************

EXE:	equ	0

IFEQ	EXE
;BASE:		equ	$80000
BASE:		equ	$100000
ELSE
BASE:		equ	$000000
ENDC
BASEF:		equ	$700000		;A1200 + 16bit-PCMCIA
;BASEF:		equ	$cf0000		;A500 + 2.5 SLOW
;BASEF:		equ	$480000		;A1200 + 4 32bit-FAST

VBR_BASE:	equ	BASE+$7ffee
MEMORY:		equ	BASE+$7fff8
DELAY:		equ	BASE+$7ffd8

TTL		CYTADELA_ANIM_REPLAYER
ALL:		REG	d0-a6
VBLANK:		MACRO
		cmpi.b	#$ff,6(a0)
		bne.s	*-6
		cmpi.b	#$ff,6(a0)
		beq.s	*-6
		ENDM
raster: 	macro
		movem.l	d0-a6,rej+4
		move.l	#.r\@,rej
		rts
.r\@:		movem.l	rej+4,d0-a6
		endm
jump:		macro
		move.l	#.p\@,jumpadr
		bra	\1
.p\@:
		endm
return:		macro
		move.l	jumpadr(pc),a1
		jmp	(a1)
		endm
wait:		macro
		move	#\1,d0
.w\@:		movem.l	d0-a6,rej+4
		move.l	#.t\@,rej
		rts
.t\@:		movem.l	rej+4,d0-a6
		dbf	d0,.w\@
		endm

WaitText:	macro
.wt\@:		tst	DoQuit
		bne	Quit
		tst	PrintText
		bne.s	.wt\@
		endm

WaitPicd:	macro
.wp\@:		tst	WaitPic
		bne.s	.wp\@
		endm


		org	BASE+$69000
		load	*


s:		IFEQ	EXE
		move.l	#0,VBR_base
		move.l	#BASEF,MEMORY
;		move	#$1e00,DELAY
		ENDC
;		move	DELAY,dl_delay
		lea	$dff000,a0
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)


		move	#$7fff,$9c(a0)
		move	#$00ff,$9e(a0)		;ADKONR
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		bsr	mt_init
		lea	$dff000,a0
;move	#$83c0,$96(a0)
;bra	www
		lea	HLoad,a1
		lea	HIRESpic,a2
		move	#[Dload-Hload]/4,d0
.cop1:		move.l	(a1)+,(a2)+
		dbf	d0,.cop1

		lea	DLoad,a1
		lea	DiskPic,a2
		move	#[LOend-Dload]/4,d0
.cop2:		move.l	(a1)+,(a2)+
		dbf	d0,.cop2

		bsr	SetHires		;decrunch screen
		lea	$dff000,a0
		VBLANK
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)

		VBLANK
		move.l	VBR_base,a1
		IFEQ	EXE
		lea	OldLev3(pc),a2
		move.l	$6c(a1),(a2)		;set lev3 interrupt
		lea	OldLev2(pc),a2
		move.l	$68(a1),(a2)		;set lev2 key interrupt
		ENDC
		lea	NewLev3(pc),a2
		move.l	a2,$6c(a1)
		lea	NewLev2(pc),a2
		move.l	a2,$68(a1)
		VBLANK
		move	#$8380,$96(a0)


;---------------
;tu load 1
		lea	BASE+$3f000+37790,a0	;check for disk 2
		move.l	#"CYT2",d1
		moveq	#2,d3
			bsr	dl_Check

		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)

		VBLANK
		move	#$c028,$9a(a0)
			move	#1,PrintText		;first text screen

		lea	BASE+$3f000+37790,a0		;load anim3a
		move	#0,d0				;start track *2
		move	#10*2,d1			;read tracks *2
		bsr	dl_start

		move.l	MEMORY,a1
		addi.l	#anim1+215344,a1
		lea	BASE+$3f000,a2
		move	#[37794/2]-1,d0
.copa1:		move	(a1)+,(a2)+		;kopiuj pocz.anim2
		dbf	d0,.copa1

		move.l	MEMORY,a0
		addi.l	#$48254,a0			;load anim3c
		move	#10*2,d0			;start track *2
		move	#20*2,d1			;read tracks *2
			bsr	dl_start
		lea	$dff000,a0

			WAITTEXT			;wait for text finished

;---------------
		move.l	MEMORY,a1		;anim 001
		addi.l	#anim1,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)			;set addr of block
		bsr	ReplayPart
		move.l	MEMORY,a1		;anim 002
		addi.l	#anim2,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)			;set addr of block
		bsr	ReplayPart
;bra	wwww

		move	#20,WaitPic
		bsr	SetHires

		lea	BASE+$62aae,a1
		lea	(a1),a3
		move.l	MEMORY,a2
		addi.l	#anim3b,a2
		move	#[$10f0/4]-1,d0
.copa2:		move.l	(a1)+,(a2)+		;kopiuj klatke anim3b
		dbf	d0,.copa2
		move.l	#"KUPA",(a3)
		WAITPICD			;finished decrunch time?

		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)
		move	#1,PrintText


		move.l	MEMORY,a0
		addi.l	#anim3b+$10f0,a0		;load anim3b
		move	#30*2,d0			;start track *2
		move	#24*2,d1			;read tracks *2
		bsr	dl_start
		lea	$dff000,a0
		WAITTEXT			;wait for text finished

		lea	anim3a,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)			;set addr of block
		bsr	ReplayPart
;---------------
		move	#20,WaitPic
		bsr	SetHires
		WAITPICD			;finished decrunch time?
		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)
		move	#1,PrintText

		move.l	MEMORY,a0
		addi.l	#anim4,a0			;load anim4,5
		move	#54*2,d0			;start track *2
		move	#26*2,d1			;read tracks *2
		bsr	dl_start
		lea	$dff000,a0
		WAITTEXT			;wait for text finished

		move.l	MEMORY,a1		;anim 004
		addi.l	#anim4,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart

;---------------
		VBLANK
		move	#1,DoPlay		;stop music
		bsr	mt_End

		move.l	MEMORY,a0
		addi.l	#anim6+1402,a0		;check for disk 3
		move.l	#"CYT3",d1
		moveq	#3,d3
		bsr	dl_Check

		bsr	mt_init
		move.b	#32,mt_SongPos
		move	#0,DoPlay		;start music
		lea	$dff000,a0
		move	#20,WaitPic
		bsr	SetHires
		move.l	MEMORY,a1
		addi.l	#anim4+282882,a1
		move.l	MEMORY,a2
		addi.l	#anim6,a2
		move	#[1406/2]-1,d0
.copa3:		move	(a1)+,(a2)+		;kopiuj 1 klatki anim6
		dbf	d0,.copa3
		WAITPICD			;finished decrunch time?
		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)
		move	#1,PrintText

		move.l	MEMORY,a0
		addi.l	#anim6+1402+$2c00,a0		;load anim6a
		move	#1*2,d0				;start track *2
		move	#21*2,d1			;read tracks *2

;		move.l	MEMORY,a0
;		addi.l	#anim6+1402,a0			;load anim6a
;		move	#0*2,d0				;start track *2
;		move	#22*2,d1			;read tracks *2

		bsr	dl_start
		lea	$dff000,a0
		WAITTEXT			;wait for text finished

		move.l	MEMORY,a1		;anim 005A
		addi.l	#anim5a,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart
		move.l	MEMORY,a1		;anim 005B
		addi.l	#anim5b,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart
		move.l	MEMORY,a1		;anim 005C
		addi.l	#anim5c,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart
		move.l	MEMORY,a1		;anim 005D
		addi.l	#anim5d,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart

;---------------
		move	#20,WaitPic
		bsr	SetHires
		WAITPICD			;finished decrunch time?
		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)
		move	#1,PrintText

		move.l	MEMORY,a0
		addi.l	#anim6+1402+$3c800,a0		;load anim6b
		move	#22*2,d0			;start track *2
		move	#20*2,d1			;read tracks *2
		bsr	dl_start
		lea	$dff000,a0
		WAITTEXT			;wait for text finished

		move.l	MEMORY,a1		;anim 006
		addi.l	#anim6,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart

;---------------
		move	#20,WaitPic
		bsr	SetHires
		WAITPICD			;finished decrunch time?
		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)
		move	#1,PrintText

		move.l	MEMORY,a0
		addi.l	#anim7,a0			;load anim7,8
		move	#42*2,d0			;start track *2
		move	#20*2,d1			;read tracks *2
		bsr	dl_start
		lea	$dff000,a0
		WAITTEXT			;wait for text finished

		move.l	MEMORY,a1		;anim 007
		addi.l	#anim7,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart
		move.l	MEMORY,a1		;anim 008
		addi.l	#anim8,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart

;---------------
		move	#20,WaitPic
		bsr	SetHires
		WAITPICD			;finished decrunch time?
		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)
		move	#1,PrintText

		move.l	MEMORY,a0
		addi.l	#anim7+$37000,a0		;load anim9
		move	#62*2,d0			;start track *2
		move	#10*2,d1			;read tracks *2
		bsr	dl_start
		lea	$dff000,a0
		WAITTEXT			;wait for text finished

		move.l	MEMORY,a1		;anim 009
		addi.l	#anim9,a1
		move.l	AnimsAdr,a2
		move.l	a1,(a2)
		bsr	ReplayPart

;---------------
		move	#20,WaitPic
		bsr	SetHires
		WAITPICD			;finished decrunch time?
		lea	$dff000,a0
		move.l	#HIREScopper,$80(a0)
		move	#0,$88(a0)
		move	#1,PrintText
		WAITTEXT			;wait for text finished

;---------------

quit:		move	#0,DoReplay
		move	#0,PrintText
		move	#0,WaitPic
		move	#1,dl_NoQuit
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#1,DoPlay		;stop music
		bsr	mt_End
		lea	cytadela,a0		;disk 3?
		move.l	#"CYT3",d1
		moveq	#3,d3
		bsr	dl_Check
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)

		move	#1,dl_NoQuit
		lea	cytadela,a0		;cytadela pic
		move	#72*2,d0		;start track *2
		move	#4*2,d1			;read tracks *2
		bsr	dl_start
www:
		lea	cytadela,a0		;decrunch pic
		lea	iff_Screen,a1
		bsr	Decrunch
		lea	iff_screen+60480,a1	;disk colors
		lea	CYTcopper,a2
		moveq	#15,d7
.cco:		move	(a1)+,2(a2)
		lea	4(a2),a2
		dbf	d7,.cco

		bsr	mt_init
		move.b	#70,mt_SongPos
		lea	$dff000,a0
		VBLANK
		move.l	#CYTcopper,$80(a0)
		move	#0,$88(a0)
		move	#0,DoPlay		;start music

;---------------
		lea	sinus1+32(pc),a1	;cytadela picture
		bsr	Wjazd
		lea	sinus3+32(pc),a1
		bsr	Wjazd
		lea	sinus4+32(pc),a1
		bsr	Wjazd

		move	#850,d7		;wait or mouse
.wtl:		VBLANK
		btst.b	#6,$bfe001
		beq.s	.wt2
		dbf	d7,.wtl
.wt2:
		lea	sinus2+32(pc),a1
		bsr	Wjazd

;---------------
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		bsr	mt_end

		move	#1,dl_NoQuit
		lea	$58000,a0		;protection
		move	#76*2,d0		;start track *2
		move	#1*2,d1			;read tracks *2
		bsr	dl_start
		lea	$58000,a0
		lea	$5a000,a1
		lea	(a1),a2
		bsr	Decrunch

		jsr	(a2)			;jump to protection

		movem.l	ALL,-(sp)
		lea	$6000,a0		;disk 4?
		move.l	#"CYT4",d1
		moveq	#4,d3
		bsr	dl_Check
		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)

		move	#1,dl_NoQuit
		lea	$5020,a0		;load server
		move	#34*2,d0
		move	#8*2,d1
		bsr	dl_start
		lea	$5020,a0
		lea	$5100,a1
		bsr	Decrunch

		lea	$dff000,a0
		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		bsr	mt_end
		movem.l	(sp)+,ALL
wwww:
		swap	d2
		IFEQ	EXE
		move.l	VBR_base,a1
		move.l	OldLev2(pc),$68(a1)
		move.l	OldLev3(pc),$6c(a1)
		move	#$83f0,$96(a0)
		move	#$e02c,$9a(a0)
		rts

		ELSE
		jmp	$5100
		ENDC


;---------------------------------------------------------------------
kal:		dc.w	0
licznik:	dc.w	0

ReplayPart:	move.l	AnimsAdr,a2		;part to be raplayed
		move.l	(a2)+,d0
		move.l	d0,a1
		move.l	(a2)+,d0
		move	d0,licznik		;ramkowanie
		move	2(a2),iff_timer
		move	6(a2),iff_timer+2
		move.l	a2,iff_speed

;move	#0,$7fffa
move	#1,kal
		move.l	a2,-(sp)
		bsr	iff_REPLAY		;main routine
		move.l	(sp)+,a2
		move	#0,DoReplay
;	btst.b	#6,$bfe001
;	beq.s	.rp_mouse
	tst	DoQuit
	bne.s	.rp_mouse
.al1:		move.l	(a2)+,d0
		bpl.s	.al1
		move.l	a2,AnimsAdr
		lea	$dff000,a0
;		VBLANK
;		VBLANK
;		VBLANK
;		VBLANK
		move.l	#copper0,$80(a0)
		move	#0,$88(a0)

.dupa:
tst	kal
bne.s	.dupa

;move	#0,kal
;.dupa:
;tst	$7fffa
;bne.s	.dupa
		rts

.rp_mouse:	move.l	#QUIT,(sp)
		bra.s	.al1

;---------------------------------------------------------------------
Wjazd:		lea	p1(pc),a2
		lea	p2(pc),a3
		moveq	#31,d7
SinLoop:	VBLANK
		cmpi.b	#$30,6(a0)
		bne.s	*-6
		moveq	#0,d0
		move.b	-(a1),d0
		addi	#$2a,d0
		cmpi	#256+$26,d0
		bmi.s	.s1
		move.l	#$1020000,(a2)		;no pic
		move.l	#$1020000,4(a2)
		move.l	#$2601ff00,(a3)
		move.l	#$01006b00,4(a3)
		bra.s	.sLoop
.s1:		cmpi	#256,d0
		bmi.s	.s2
		andi.l	#255,d0			;lower
		ror.l	#8,d0
		ori.l	#$0001ff00,d0
		move.l	d0,(a3)
		move.l	#$01006b00,4(a3)
		move.l	#$1020000,(a2)
		move.l	#$1020000,4(a2)
		bra.s	.sLoop
.s2:		andi.l	#255,d0			;upper
		ror.l	#8,d0
		ori.l	#$0001ff00,d0
		move.l	d0,(a2)
		move.l	#$01006b00,4(a2)
		move.l	#$1020000,(a3)
		move.l	#$1020000,4(a3)
.sLoop:		dbf	d7,SinLoop
		rts
Sinus1:
DC.B	$00,$0C,$19,$25,$31,$3E,$4A,$56,$61,$6D,$78,$83,$8E,$98,$A2,$AB
DC.B	$B5,$BD,$C5,$CD,$D4,$DB,$E1,$E7,$EC,$F1,$F4,$F8,$FB,$FD,$FE,$FF

Sinus2:
DC.B	$ff,$F4,$E7,$DB,$CF,$C2,$B6,$AA,$9F,$93,$88,$7D,$72,$68,$5E,$55
DC.B	$4B,$43,$3B,$33,$2C,$25,$1F,$19,$14,$0F,$0C,$08,$05,$03,$02,$01

Sinus3:
DC.B	$00,$06,$0C,$12,$18,$1E,$23,$28,$2D,$31,$35,$38,$3B,$3D,$3E,$3F
DC.B	$40,$3F,$3E,$3D,$3B,$38,$35,$31,$2D,$28,$23,$1E,$18,$12,$0C,$06

Sinus4:
DC.B	$00,$01,$03,$05,$07,$09,$0B,$0C,$0E,$0F,$10,$11,$12,$13,$13,$13
DC.B	$14,$13,$13,$13,$12,$11,$10,$0F,$0E,$0C,$0B,$09,$07,$05,$03,$01

;---------------------------------------------------------------------
NewLev3:	movem.l ALL,-(sp)

	tst	kal
	beq.s	.dupa
	subi	#1,licznik
	bpl.s	.dupa
	move	#0,kal
.dupa:

		tst	WaitPic
		beq.s	.nl0
		subi	#1,WaitPic		;ramkuj rys. i decrunch
		bra.s	.nl3

.nl0:		tst	DoReplay
		beq.s	.nl1

		subi	#1,iff_timer
		bne.s	.nl1
		move.l	iff_speed,a1
		subi	#1,iff_timer+2
		bne.s	.nl2
		lea	8(a1),a1
		move.l	a1,iff_speed
		move	6(a1),iff_timer+2
.nl2:		move	2(a1),iff_timer
		move	#1,ok_go

.nl1:		tst	PrintText
		beq.s	.nl3
		move.l	rej,a1
		jsr	(a1)
.nl3:		tst	doPlay			;stop music?
		bne.s	.nl6
		bsr	mt_music

.nl6:		btst.b	#7,$bfe001		;quit after fire
		beq.s	.nl5
		btst.b	#6,$bfe001		;quit after mouse
		bne.s	.nl4
.nl5:		move	#1,DoQuit

.nl4:		movem.l	(sp)+,ALL
		move	#$20,$dff09c
		rte

DoPlay:		dc.w	0
DoQuit:		dc.w	0
DoReplay:	dc.w	0		;1 - replay anim
WaitPic:	dc.w	0		;ramkowanie rys. i decrunchu
;---------------------------------------------------------------------
NewLev2:	movem.l	ALL,-(sp)
		moveq	#0,d0
		tst.b	$bfed01
		move.b	$bfec01,d0
		move	#$0008,$dff09c		;zero interrupt
		tst	d0
		beq.s	cc_NoKey

cc_m:		cmpi.b	#$75,d0			;ESC - quit
		bne.s	cc_suwak
		move	#1,DoQuit
		bra	cc_NoKey

;		cmpi.b	#$93,d0			;n - ntsc
;		beq.s	cc_m1
;		cmpi.b	#$4f,d0			;F9 - ntsc
;		bne.s	cc_suwak
;cc_m1:		eori	#32,Ntsc
;		move	Ntsc,d0
;		move	d0,$dff1dc
;		bra.w	cc_NoKey

cc_suwak:	cmpi.b	#$bd,d0			;s - przesuw
		beq.s	cc_s0
		cmpi.b	#$7f,d0			;spacja - przesuw
		beq.s	cc_s0
		cmpi.b	#$4d,d0			;F10 - przesuw
		bne.s	cc_pause
cc_s0:		lea	suwak+31,a1
		move	#[198/2]-1,d1
cc_s1:		eori.b	#$11,(a1)
		lea	32(a1),a1
		dbf	d1,cc_s1
		bra.w	cc_NoKey

cc_pause:
;	cmpi.b	#$cd,d0			;pauza - kick out!
;	bne.s	cc_pause2
;	eori	#1,iff_pause
;	bra.s	cc_NoKey
;
;cc_pause2:
;	cmpi.b	#$cf,d0			;pauza - kick out!
;	bne.s	cc_pause3
;	move	#1,iff_pause
;	bra.s	cc_NoKey
;
;cc_pause3:
;	cmpi.b	#$ce,d0			;pauza - kick out!
;	bne.s	cc_NoKey
;	move	#0,iff_pause

cc_NoKey:	move.b	#$41,$bfee01
		nop
		nop
		nop
		move.b	#0,$bfec01
		move.b	#0,$bfee01
		movem.l	(sp)+,ALL
		rte

SetHires:	lea	HiresPic,a0
		lea	iff_Screen,a1
		bsr	Decrunch
		lea	$dff000,a0
		rts

;---------------------------------------------------------------------
Level3Code:	lea	HIREScopper,a3
		lea	iff_Screen+[200*80*4],a4
		moveq	#15,d4
		JUMP	p_setcolors
		WAIT	40

l3_1:		raster
		bsr	p_PRINT
;		cmpi	#13,p_linie
;		beq.s	l3_2
;		bsr	p_PRINT
		cmpi	#13,p_linie
		bne.s	l3_1
;l3_2:
		WAIT	550
;		WAIT	30

		move	#0,p_linie		;set next text
		move.l	#iff_Screen+[4*80*35]+10,p_ScreenAdr
		lea	HIREScopper,a3
		moveq	#15,d4
		JUMP	l_FadeColors

;	lea	$dff000,a0
;	move.l	#copper0,$80(a0)
;	move	#0,$88(a0)

		raster
		move.l	#Level3Code,Rej
		move	#0,PrintText
		rts

Printtext:	dc.w	0	;1 - print text, 0 - replay anim
;---------------------------------------------------------------------
iff_helptab:	dc.b	0,3,12,15,48,48+3,48+12,48+15,192
		dc.b	192+3,192+12,192+15,240,240+3,240+12,240+15
;INPUT:
;	A1.l	-	IFF-ANIM structure pointer

iff_REPLAY:	movem.l	d0-a6,-(sp)
	VBLANK
	move	#10,WaitPic
		lea	iff_DoubleTab(pc),a2
		lea	iff_HelpTab(pc),a3
		moveq	#0,d0
iff_DoubLoop:	move	d0,d1
		andi	#15,d1
		move.b	(a3,d1.w),d1
		move	d0,d2
		lsr	#4,d2
		andi	#15,d2
		move.b	(a3,d2.w),d2
		lsl	#8,d2
		ori	d2,d1
		move	d1,(a2)+
		addq	#1,d0
		cmpi	#256,d0
		bne.s	iff_DoubLoop

		lea	$dff000,a0
		lea	4(a1),a1	;skip ANIM
		lea	iff_copper+2,a2
		moveq	#15,d0
iff_CMAP:	move	(a1)+,(a2)
		lea	4(a2),a2
		dbf	d0,iff_CMAP

;----------------------------BODY-----------------------------------
;---------------decompress (ByteRun) and convert

iff_BODY:	move.l	iff_Scron(pc),a2
		lea	40*100*6(a2),a4
		lea	4(a1),a1

iff_convert:	moveq	#0,d0
		move.b	(a1)+,d0
		bmi.s	iff_negval
iff_copy:	moveq	#0,d1
		move.b	(a1)+,d1
		add	d1,d1
		move	iff_DoubleTab(pc,d1.w),(a2)+
		dbf	d0,iff_copy
		cmpa.l	a4,a2		;end of pic?
		bmi.s	iff_convert
		bra.w	iff_ANIM

iff_negval:	neg.b	d0
		moveq	#0,d1
		move.b	(a1)+,d1
		add	d1,d1
		move	iff_DoubleTab(pc,d1.w),d1
iff_negloop:
		move	d1,(a2)+	;if minus value
		dbf	d0,iff_negloop
		cmpa.l	a4,a2		;end of pic?
		bmi.s	iff_convert
		bra.w	iff_ANIM

iff_DoubleTab:	ds.w	256
;-------------------------------------------------------------------
;----------------------------ANIMATE--------------------------------
;-------------------------------------------------------------------
iff_ANIM:
		move.l	iff_scron(pc),a2
		move.l	iff_scron+4(pc),a4
		move	#[100*6*10]-1,d0
iff_SecondPlane:move.l	(a2)+,(a4)+		;copy to buffor2
		dbf	d0,iff_SecondPlane

.wp:	tst	WaitPic		;ramkuj rysowanie pierwszego.
	bne.s	.wp

		VBLANK
		bsr.w	iff_ChangeScreen
		lea	iff_copper,a3
		MOVE.L	a3,$80(A0)		;set copperlist
		move	#0,$88(a0)

	move	#1,DoReplay
;	move	#0,iff_pause
	move	#0,ok_go

iff_ANIMLOOP:	tst	ok_go
		beq.s	iff_ANIMLOOP
		move	#0,ok_go
		VBLANK

;	btst.b	#6,$bfe001
;	beq	iff_END
	tst	DoQuit
	bne	iff_END

		bsr.w	iff_ChangeScreen
		move.l	a1,d0
		addq	#1,d0
		andi.l	#-2,d0
		move.l	d0,a1		;even

		cmpi.l	#"KUPA",(a1)		;czy zmiana adresu?
		bne.s	iff_k1
		move.l	MEMORY,a1
		addi.l	#anim3b+4,a1
		bra.s	iff_DLTA

iff_k1:		cmpi.l	#"DLTA",(a1)+
		bne	iff_END

;----------------------------DLTA-----------------------------------
iff_DLTA:	lea	iff_DoubleTab(pc),a3
		move.l	iff_scron+4(pc),a2	;screen addr
		lea	iff_Ytab,a4

		moveq	#0,d6
		move.b	(a1)+,d6		;get column CNT
	cmpi	#20*6,d6
	bpl.w	iff_END
iff_FracLoop:	move.b	(a1)+,d0
		beq.s	iff_NextRow
		ext	d0
		subq	#2,d0
		lea	(a2),a6
		lea	102*240(a2),a5

iff_Sections:	moveq	#0,d1
		move.b	(a1)+,d1
		beq.s	iff_SameLoop
		bpl.s	iff_ShiftLoop

		andi	#$7f,d1
		subq	#1,d1
	cmpi	#100,d1
	bhi.s	iff_END
iff_CopyLoop:	moveq	#0,d2
		move.b	(a1)+,d2
		add	d2,d2
		move	(a3,d2.w),(a6)
		lea	40*6(a6),a6
		dbf	d1,iff_CopyLoop
		bra.s	iff_RepSections

iff_ShiftLoop:	add	d1,d1
		move	(a4,d1.w),d1
		lea	(a6,d1.l),a6
		bra.s	iff_RepSections

iff_SameLoop:	moveq	#0,d1
		move.b	(a1)+,d1
		subq	#1,d1
	cmpi	#100,d1
	bhi.s	iff_END
		moveq	#0,d2
		move.b	(a1)+,d2
		add	d2,d2
		move	(a3,d2.w),d2		;double
iff_CopySame:	move	d2,(a6)
		lea	40*6(a6),a6
		dbf	d1,iff_CopySame
iff_RepSections:
	cmpa.l	a5,a6
	bpl.s	iff_END

		dbf	d0,iff_Sections
	lea	1(a1),a1

iff_NextRow:	lea	2(a2),a2
		dbf	d6,iff_FracLoop

iff_EndDlta:	bra	iff_ANIMLOOP

;-------------------------------------------------------------------
iff_END:
;		bsr.w	iff_ChangeScreen
		movem.l	(sp)+,d0-a6
;		lea	iff_copper,a1
		rts

;---------------------------SCREEN----------------------------------
iff_ChangeScreen:
		lea	iff_scron(pc),a4
		move.l	(a4),a2
		move.l	4(a4),d1
		move.l	d1,(a4)
		move.l	a2,4(a4)

		moveq	#5,d2
		lea	iff_addr,a4
iff_SetBAddr:	move	d1,6(a4)
		swap	d1
		move	d1,2(a4)
		swap	d1
		addi	#40,d1
		lea	8(a4),a4
		dbf	d2,iff_SetBAddr
		rts

;-------------------------------------------------------------------
iff_Ytab:
VALUE:	SET	0
	REPT	100
	dc.w	VALUE
VALUE:	SET VALUE+240
	ENDR
	blk.l	158,0

;-------------------------------------------------------------------
;a3 - copper, a4 - color tab, d4 - color nr-1

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
		raster
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

;-----------------------------------------------------------------------
p_TextAdr:	dc.l	HText
p_ScreenAdr:	dc.l	iff_Screen+[4*80*35]+10
p_Linie:	dc.w	0

p_PRINT:	move.l	p_TextAdr,a1
		moveq	#0,d0
		move.b	(a1)+,d0
		cmpi.b	#10,d0
		bne.s	p_NotRet
		addi	#1,p_linie
		move	p_linie(pc),d0
		mulu	#4*80*10,d0
		addi.l	#iff_Screen+[4*80*35]+10,d0
		move.l	d0,p_ScreenAdr
		move.l	a1,p_TextAdr
		rts
p_NotRet:	move.l	a1,p_TextAdr
		subi	#32,d0
		lsl	#3,d0
		lea	fonts,a1
		move.l	p_ScreenAdr,a2
		addi.l	#1,p_ScreenAdr
		lea	(a1,d0.w),a1
		moveq	#6,d2
p_pr0:		move.b	(a1)+,d0
		move	d0,d1
		not	d1
		or.b	d0,(a2)
		and.b	d1,80(a2)
		and.b	d1,160(a2)
		and.b	d1,240(a2)
		lea	4*80(a2),a2
		dbf	d2,p_pr0
		rts

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

;-------------------------------------------------------------------
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


;-----------------------------------------------------------------------
;SpaceBalls '9Fingers' trackloader...
;INPUT:	a0	- addr
;	d0	- start track (*2 !)
;	d1	- nr. of tracks to read (*2 !)
; dl_DISK:.w	- drive nr (0,1,2,3)
;OUTPUT:
;	d0	- 0 if all OK, -1 if error (no disk)

************************************************************************

;a0 - destination, d1 - disk id "CYT1", d3 - diskNR: 1,2,...5
;out: d0 - drive nr found ok
dl_check:	move	#1,dl_NoQuit
		moveq	#0,d2
dl_LOOP:
;		moveq	#40,d4
;		lea	$dff000,a0
;dl_LWAIT:	VBLANK
;		dbf	d4,dl_LWAIT
		movem.l	a0/d1/d2/d3,-(sp)
		move	d2,dl_DISK	;disk Nr
		moveq	#0,d0		;start
		moveq	#2,d1		;nr of tracks
		move	#-1,dl_COUNTER
		bsr	dl_FindDisk
		movem.l	(sp)+,a0/d1/d2/d3
		tst	d0
		bpl.w	dl_DiskID	;if smth read
		movem.l	a0/d1/d2/d3,-(sp)
		moveq	#0,d0		;start
		moveq	#2,d1		;nr of tracks
		bsr	dl_FindDisk
		movem.l	(sp)+,a0/d1/d2/d3
		tst	d0
		bpl.s	dl_DiskID	;if smth read

dl_bad:		addq	#1,d2
		cmpi	#3,d2
		bne.s	dl_LOOP
;... obrazek dysku
		lea	Napisy+12,a1
		lea	Napisy+[17*14*2],a2
		move	d3,d4
		subq	#1,d4
		add	d4,d4
		lea	(a2,d4.w),a2
		moveq	#[14*2]-1,d0
.cnr:		move	(a2),(a1)		;disk nr
		lea	14(a1),a1
		lea	14(a2),a2
		dbf	d0,.cnr

		lea	DiskPic+$2670,a1	;disk colors
		lea	DISKcopper,a2
		moveq	#31,d7
.cco:		move	(a1)+,2(a2)
		lea	4(a2),a2
		dbf	d7,.cco

		move.l	a0,-(sp)
		lea	$dff000,a0
		VBLANK
		move.l	#DISKcopper,$80(a0)
		move	#0,$88(a0)
		move.l	(sp)+,a0
		bra.w	dl_check

dl_DiskID:	cmp.l	(a0),d1
		bne.s	dl_bad
		move	d2,d0
		lea	$dff000,a0
		move	#0,dl_NoQuit
		rts

dl_Noquit:	dc.w	0

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
lbC000020:	bsr.w	lbC00006E
		btst	#0,d0
		beq.b	lbC000032
		move.w	d0,-(sp)
		moveq	#0,d0
		bsr.w	lbC00015A
		move.w	(sp)+,d0
lbC000032:	addq.w	#1,d0
		lea	dl_COUNTER(pc),a3
	tst	dl_NoQuit
	bne.s	.dlc
	tst	DoQuit
	bne.s	dl_Abort
.dlc:		addq.w	#1,(a3)
		dbra	d1,lbC000008
		andi.w	#$FFFE,(a3)
		bsr.w	lbC000228
		moveq	#0,d0
		rts				;quit here if all OK

dl_Abort:	andi.w	#$FFFE,(a3)
		bsr.w	lbC000228
		moveq	#0,d0
		move.l	#Quit,(sp)
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

dl_FindDisk:	bsr.s	dl_SetDma		;check drive for disk
		bsr.w	lbC0001F6		;if no disk - quit
		tst.w	d5
		bne.b	lbC000052
		bra.w	lbC000004

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
		move.w	(6,a2),d4
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
		addi.b	#$2c,d1
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
		moveq	#45,d5
lbC000214:
.wp1:		cmp.b	#$ff,6(a6)
		bne.b	.wp1
.wp2:		cmp.b	#$ff,6(a6)
		beq.b	.wp2

		subq	#1,d5			;if no such drive
		bmi.s	lbC000224

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
;dl_BUFFER:	blk.b	$3600,0


;-------------------------------------------------------------------
copper0:dc.l	$1800000,$1000300,-2

iff_copper:
	dc.w	$180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
	dc.w	$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0

iff_addr:
	dc.w	$e0,0/$10000,$e2,0&$ffff
	dc.w	$e4,[0+40]/$10000,$e6,[0+40]&$ffff
	dc.w	$e8,[0+80]/$10000,$ea,[0+80]&$ffff
	dc.w	$ec,[0+120]/$10000,$ee,[0+120]&$ffff
	dc.w	$f0,[0+160]/$10000,$f2,[0+160]&$ffff
	dc.w	$f4,[0+200]/$10000,$f6,[0+200]&$ffff

	dc.w	$108,200,$10a,200
	dc.l	$920038,$9400d0

;	dc.l	$8e3883,$90ffc1
	dc.l	$8e3a83,$90ffd1
	dc.l	$1020000,$1040000
;	dc.w	$1fc,0,$106,0,$10c,0

	dc.l	$3701ff00
	dc.l	$01006b00
	dc.w	$108,-40,$10a,-40
	dc.l	$3801ff00
	dc.w	$108,200,$10a,200


suwak:
VALUE:	SET	$3901ff00
	REPT	198/2
	dc.l	VALUE
	dc.w	$108,-40,$10a,-40
	dc.l	$1020000
	dc.l	VALUE+$01000000
	dc.w	$108,200,$10a,200
	dc.l	$1020000
VALUE:	SET	VALUE+$02000000
	ENDR


	dc.l	$ff01ff00
	dc.l	$01000300
	dc.l	-2


;-------------------------------------------------------------------
HIREScopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0

dc.w	$108,3*80,$10a,3*80
dc.l	$920038,$9400d0
dc.l	$8e3881,$90ffc3
dc.l	$10200aa,$1040000
;dc.w	$1fc,0,$106,0,$10c,0

dc.w	$e0,iff_screen/$10000,$e2,iff_screen&$ffff
dc.w	$e4,[iff_screen+80]/$10000,$e6,[iff_screen+80]&$ffff
dc.w	$e8,[iff_screen+2*80]/$10000,$ea,[iff_screen+2*80]&$ffff
dc.w	$ec,[iff_screen+3*80]/$10000,$ee,[iff_screen+3*80]&$ffff

dc.l	$3601ff00,$0100c300
dc.l	$fe01ff00,$01000300
dc.l	-2

;-------------------------------------------------------------------
DISKcopper:
dc.w	$180,0,$182,0,$184,0,$186,0,$188,0
dc.w	$18A,0,$18C,0,$18E,0,$190,0,$192,0
dc.w	$194,0,$196,0,$198,0,$19A,0,$19C,0
dc.w	$19E,0
dc.w	$1a0,0,$1a2,0,$1a4,0,$1a6,0,$1a8,0
dc.w	$1aA,0,$1aC,0,$1aE,0,$1b0,0,$1b2,0
dc.w	$1b4,0,$1b6,0,$1b8,0,$1bA,0,$1bC,0
dc.w	$1bE,0

dc.w	$108,4*16,$10a,4*16
dc.l	$920068,$9400a0
dc.l	$8e3881,$90ffc3
dc.l	$1020000,$1040000

dc.w	$e0,DiskPic/$10000,$e2,DiskPic&$ffff
dc.w	$e4,[DiskPic+16]/$10000,$e6,[DiskPic+16]&$ffff
dc.w	$e8,[DiskPic+2*16]/$10000,$ea,[DiskPic+2*16]&$ffff
dc.w	$ec,[DiskPic+3*16]/$10000,$ee,[DiskPic+3*16]&$ffff
dc.w	$f0,[DiskPic+4*16]/$10000,$f2,[DiskPic+4*16]&$ffff

dc.l	$5001ff00,$01005300
dc.l	$cb01ff00,$01000300

dc.l	$920068,$940098
dc.w	$108,14,$10a,14
dc.w	$e0,Napisy/$10000,$e2,Napisy&$ffff
dc.w	$e4,[Napisy+14]/$10000,$e6,[Napisy+14]&$ffff
dc.w	$180,0,$182,$555,$184,$999,$186,$dde
dc.l	$1020088
dc.l	$d801ff00,$01002300
dc.l	$e901ff00,$01000300
dc.l	-2


;-------------------------------------------------------------------
CYTcopper:
	dc.w	$180,0,$182,0,$184,0,$186,0,$188,0,$18a,0,$18c,0,$18e,0
	dc.w	$190,0,$192,0,$194,0,$196,0,$198,0,$19a,0,$19c,0,$19e,0

dc.w	$e0,iff_screen/$10000,$e2,iff_screen&$ffff
dc.w	$e4,[iff_screen+40]/$10000,$e6,[iff_screen+40]&$ffff
dc.w	$e8,[iff_screen+2*40]/$10000,$ea,[iff_screen+2*40]&$ffff
dc.w	$ec,[iff_screen+3*40]/$10000,$ee,[iff_screen+3*40]&$ffff
dc.w	$f0,[iff_screen+4*40]/$10000,$f2,[iff_screen+4*40]&$ffff
dc.w	$f4,[iff_screen+5*40]/$10000,$f6,[iff_screen+5*40]&$ffff

	dc.w	$108,5*40,$10a,5*40
	dc.l	$920038,$9400d0

	dc.l	$8e0171,$9037d1
	dc.l	$1020000,$1040000

p1:	dc.l	$1020000		;$2a01ff00
	dc.l	$1020000		;$01006b00
	dc.l	$ffdffffe
p2:	dc.l	$2601ff00		;$1020000 *2
	dc.l	$01006b00
	dc.l	$2601ff00
	dc.l	$01000300
	dc.l	-2

;-------------------------------------------------------------------
iff_screen:	equ	BASE+$70400	;$c400, $fa00 (hires screen)
HIRESpic:	equ	BASE+$64000	;$31ec
HText:		equ	BASE+$671ec	;$f00 (+$80)
dl_buffer:	equ	BASE+$6d180	;$3200

DiskPic:	equ	BASE+$3c300	;$26b0
Napisy:		equ	BASE+$3e9b0	;$364 (do $3f000 wolne)

Cytadela:	equ	BASE+$5a000	;load

iff_timer:	dc.w	4,0		;frame timing
iff_speed:	dc.l	0
ok_go:		dc.w	0
iff_scron:	dc.l	iff_screen,iff_screen+[110*40*6]
OldLev2:	dc.l	0
OldLev3:	dc.l	0
Ntsc:		dc.w	32
;iff_pause:	dc.w	1

LastDrive:	dc.w	0		;last disk nr. read

JumpAdr:	dc.l	0
rej:		dc.l	Level3Code
		blk.l	18,0

AnimsAdr:	dc.l	anims
;ramkowanie,   speed, ile ramek, speed, ...,-1
anims:
	dc.l	anim1,$121,1,1,90,1,4,300,-1
	dc.l	anim2,$88,6,16,30,300,-1
;	dc.l	anim3A,$  ,10,1,6,59,20,300,-1
	dc.l	anim3A,$1a0,10,1,6,159,20,300,-1
	dc.l	anim4,$70,7,1,5,300,-1
	dc.l	anim5A,$94,55,1,8,4,50,300,-1
	dc.l	anim5B,$b9,25,1,50,300,-1
	dc.l	anim5C,$8e,20,1,8,4,80,300,-1
	dc.l	anim5D,$ef,15,1,8,23,30,300,-1
	dc.l	anim6,$13e,14,1,6,300,-1
	dc.l	anim7,$a1,7,1,6,19,30,300,-1
	dc.l	anim8,$d1,70,1,6,19,15,300,-1
	dc.l	anim9,$cc,7,19,60,300,-1
	dc.l	-1

;-------------------------------------------------------------------
fonts:
incbin	"DAT1:GFX/FONTS01.FNT"
;incbin	"kane3:GFX/FONTS01.FNT"

END:

Hload:
incbin	"DAT1:GFX/panel_hires.rawb.pp"		;$31ec
;incbin	"kane3:GFX/panel_hires.rawb.pp"		;$31ec
Tload:
incbin	"DATA:STORE/HISTORIA.TXT"		;$f00+$100
;incbin	"kane2:STORE/HISTORIA.TXT"		;$f00+$100
DLoad:
incbin	"DAT1:GFX/DYSK.RAWB"			;$26b0
;incbin	"kane3:GFX/DYSK.RAWB"			;$26b0
Nload:
incbin	"DAT1:GFX/DYSK_napisy_POL.rawb"		;$364
;incbin	"kane3:GFX/DYSK_napisy_POL.rawb"	;$364
LOend:

;-------------------------------------------------------------------
mt_data:	equ	BASE+$5100
>extern		"DAT1:MODS/mod.intro_dela.pro",mt_data,-1
>extern		"DAT1:ANIM2/disk_1.anim",BASEF+anim1,-1

anim1:	equ	$5000
anim2:	equ	$5000+170414
anim3A:	equ	BASE+$3f000
anim3B:	equ	$5164
anim4:	equ	$37860
anim5A:	equ	$4894c
anim5B:	equ	$50df4
anim5C:	equ	$57f88
anim5D:	equ	$6059c
anim6:	equ	$5000
anim7:	equ	$5000
anim8:	equ	$1994c
anim9:	equ	$3968e

endall:

*... 20.05.1995...*
