๙๚๙๚  c  	n  	o  ๏  
w  j  3d  ๆ  "&  %ย
;	*************************************************
;	*	      Cytadela HD Installer		*
;	*    Coded on 20.09.1995  by KANE of SUSPECT	*
;	*************************************************
;Gosh... today is my 20-th birthday...


;0 - pol, 1 - eng, 2 - ger
LAN:		equ	1

TTL		CYTADELA_INSTALLER
ALL:		REG	d0-a6
VBLANK:		MACRO
		cmpi.b	#$ff,6(a0)
		bne.s	*-6
		cmpi.b	#$ff,6(a0)
		beq.s	*-6
		ENDM
WAIT:		MACRO
		move	#\1,d0
.aq\@:		cmpi.b	#$ff,6(a0)
		bne.s	*-6
		cmpi.b	#$ff,6(a0)
		beq.s	*-6
		dbf	d0,.aq\@
		ENDM

row:	equ	60

section	code,code_f

s:		movem.l	ALL,-(sp)
		lea	$dff000,a0
		VBLANK
		move	#$7fff,$96(a0)
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)
		lea	copper0,a1
		move.l	a1,$80(a0)
		move	#0,$88(a0)
		move	#$8380,$96(a0)

		bsr	SetScr

		VBLANK
		lea	HIREScopper,a1
		move.l	a1,$80(a0)
		move	#0,$88(a0)
		lea	OldLev2,a1
		move.l	$68,(a1)
		lea	NewLev2(pc),a1
		move.l	a1,$68.w

		move	#$c008,$9a(a0)
		WAIT	5
		lea	t1,a1
		bsr	PRINT
		move	#2,poz
		lea	t2,a1
		bsr	PRINT
		move	#3,poz
		lea	t3,a1
		bsr	PRINT
		move	#5,poz
		lea	buf+2,a1
		bsr	PRINT

		move	#0,Klawisz

;---------------
;	bra	wpisane

KeyLoop:	tst	klawisz
		beq.s	KeyLoop
		move	Klawisz,d0
		move	#0,Klawisz

		cmpi	#$75,d0			;ESC
		beq.s	QuitWpis
		cmpi	#$77,d0			;return
		beq	Wpisane
		cmpi	#$79,d0			;enter
		beq	Wpisane
		cmpi	#$73,d0			;delete
		beq.s	Del
		cmpi	#$7d,d0			;delete
		bne.s	NieDel

Del:		lea	buf,a1
		move	(a1),d1
		beq.s	KeyLoop
		subi	#1,d1
		move.b	#0,2(a1,d1.w)
		move	d1,(a1)
		lea	buf+2,a1
		bsr	PRINT
		beq.s	KeyLoop

QuitWpis:	addi	#2,poz
		lea	t7,a1		;installation aborted
		bsr	PRINT
		addi	#1,poz
		bra	quit

NieDel:		lea	KEYtab,a1
		moveq	#-1,d1
SeekKey:	addq	#1,d1			;find key in key_tab
		move.b	(a1)+,d2
		beq.w	KeyLoop
		cmp.b	d2,d0
		bne.s	SeekKey

		lea	ASCIItab,a1
		move.b	(a1,d1.w),d0		;ASCII value

		lea	buf,a1
		move	(a1),d1
		cmpi	#58,d1
		bpl.w	KeyLoop
		move.b	d0,2(a1,d1.w)
		move.b	#0,3(a1,d1.w)
		addq	#1,d1
		move	d1,(a1)
		lea	buf+2,a1
		bsr	PRINT
		bra.w	KeyLoop

wpisane:	move	#7,poz
		lea	t4,a1
		bsr	PRINT
		addi	#1,poz
		lea	$dff000,a0
		VBLANK
		move	#$7fff,$9a(a0)
		move.l	OldLev2,$68		;system key int back
		move	#$e02c,$9a(a0)
		lea	t5,a1
		bsr	PRINT
		addi	#1,poz
		lea	$dff000,a0
		WAIT	10

		lea	buf+2,a1
		move	-2(a1),d7
		move.b	#10,(a1,d7.w)		;add return
		addq	#1,d7
		lea	CFGname,a2
		bsr	HD_doWrite
		lea	$dff000,a0
		WAIT	50

;---------------copying...


quit:		lea	$dff000,a0
		VBLANK
		move	#$7fff,$9a(a0)
		lea	NewLev2(pc),a1
		move.l	a1,$68.w
		move	#$c008,$9a(a0)
		WAIT	20
		lea	t8,a1		;press any key...
		bsr	PRINT
		move	#0,klawisz

KeyLoop2:	tst	klawisz
		beq.s	KeyLoop2

		lea	$dff000,a0
		VBLANK
quit2:		lea	copper0,a1
		move.l	a1,$80(a0)

		move.l	4.w,a6
		lea	gfxname,a1
		moveq	#0,d0
		jsr	-552(a6)
		move.l	d0,a0
		move.l	$26(a0),$dff080

		lea	$dff000,a0
		move	#$7fff,$9a(a0)
		move	#$7fff,$9c(a0)

		move.l	OldLev2,$68
		move	#$83f0,$96(a0)
		move	#$e02c,$9a(a0)
		movem.l	(sp)+,ALL
		moveq	#0,d0
		rts


;---------------------------------------------------------------------

NewLev2:	move.l	d0,-(sp)
		moveq	#0,d0
		tst.b	$bfed01
		move.b	$bfec01,d0
		move	#$0008,$dff09c		;zero interrupt
		tst	d0
		beq.s	cc_NoKey

		move	d0,klawisz

cc_NoKey:	move.b	#$41,$bfee01
		nop
		nop
		nop
		move.b	#0,$bfec01
		move.b	#0,$bfee01
		move.l	(sp)+,d0
		rte

;-----------------------------------------------------------------------
;input: a1 - tekst

PRINT:		movem.l	ALL,-(sp)
		LEA	screen,a2
		move	poz,d0
		mulu	#row*8,d0
		lea	1(a2,d0.w),a2
		lea	(a2),a3
		moveq	#2*row,d0
		moveq	#0,d1
.fill1:		move.l	d1,(a3)+		;cl line
		dbf	d0,.fill1
		lea	fonts,a4
p_loop:		moveq	#0,d0
		move.b	(a1)+,d0
		bne.s	p_1
		movem.l	(sp)+,ALL
		rts
p_1:		subi	#32,d0
		lsl	#3,d0
		move.b	(a4,d0.w),(a2)
		move.b	1(a4,d0.w),row(a2)
		move.b	2(a4,d0.w),2*row(a2)
		move.b	3(a4,d0.w),3*row(a2)
		move.b	4(a4,d0.w),4*row(a2)
		move.b	5(a4,d0.w),5*row(a2)
		move.b	6(a4,d0.w),6*row(a2)
		lea	1(a2),a2
		bra.s	p_loop

;-----------------------------------------------------------------------
SetScr:		lea	ScrAddr,a1
		lea	screen,a2
		move.l	a2,d0
		move	d0,6(a1)
		swap	d0
		move	d0,2(a1)
		swap	d0
		addi.l	#160*row,d0
		move	d0,8+6(a1)
		swap	d0
		move	d0,8+2(a1)

		move	#[40*row]-1,d0
.fill1:		move.l	#-1,160*row(a2)		;cls
		move.l	#0,(a2)+
		dbf	d0,.fill1
		rts


;-----------------------------------------------------------------------
;CITADEL Hard Disk loader - by KANE/SCT, 18.09.1995

wait2:	macro
.w\@:	cmp.b	#$ff,6(a0)
	bne.s	*-6
	cmp.b	#$ff,6(a0)
	beq.s	*-6
	dbf	d0,.w\@
	endm

;-----------------------------------------------
;INPUT:
; LOAD: a0 - [name], a1 - buffer, d0 - disk nr (1,2,3,4,5), d1 - start TR
; WRITE: a0 - name, a1 - addr, d0 - length, d1 - "SAVE"
;OUTPUT: d0 - NULL (ok), d1 - length

HD_seek:	movem.l	a0-a6/d2-d7,-(sp)
		cmpi.l	#"SAVE",d1
		beq.s	HD_write
		cmpi	#5,d0
		bne.s	HD_not5
		lea	4(a0),a0		;skip df0:
		bsr	HD_load
		bra.s	HD_end
HD_not5:	subq	#1,d0
		add	d0,d0
		add	d0,d0
		lea	DiskAdr(pc),a0
		move.l	(a0,d0.w),a0		;disk structure
		lea	-4(a0),a0
HD_find:	lea	6(a0),a0
		move	-2(a0),d0
		cmpi	d0,d1
		bne.s	HD_find
		bsr	HD_load
HD_end:		lea	$dff000,a0
		move.l	d1,d0
		lsr.l	d0
		divu	#60000,d0
		addq.w	#1,d0
		mulu	#15,d0
		wait2
HD_quit:	movem.l	(sp)+,a0-a6/d2-d7
		moveq	#0,d0
		rts

HD_Write:	move.l	d0,d7
		bsr.s	HD_SetPath
		bsr	HD_doWrite
		bra.s	HD_quit

;-----------------------------------------------
oldopenlib:	equ	-$198
closelibrary:	equ	-$19e

open:		equ	-$01e
close:		equ	-$024
lock:		equ	-$054
unlock:		equ	-$05a
examine:	equ	-$066
read:		equ	-$02a
mode_oldfile:		equ	1005
;-----------------------------------------------
HD_SetPath:	move	l_offset,d0
		bne.s	HD_CfgOK
		movem.l	a0/a1/d7,-(sp)
		lea	PrefName,a2		;load config (path)
		lea	l_name,a1
		pea	(a1)
		bsr.s	HD_DoLoad
		move.l	(sp)+,a1
		lea	RestName,a0
		move	d1,d0
		subq	#2,d0
HD_CopRest:	move.b	(a0)+,d1
		addq	#1,d0
		move.b	d1,(a1,d0.w)
		bne.s	HD_CopRest
		move	d0,l_offset
		movem.l	(sp)+,a0/a1/d7
HD_CfgOK:	lea	l_name,a2
HD_CopLoop:	move.b	(a0)+,d1
		addq	#1,d0
		move.b	d1,-1(a2,d0.w)
		bne.s	HD_CopLoop
		rts

HD_load:	bsr	HD_SetPath

;a2 - name, a1 - buffer

HD_DoLoad:		lea	-20(sp),sp
			move.l	a2,load_loadname(sp)
			move.l	a1,load_buffer(sp)
			move.l	$4.w,a6
			lea	dosname,a1
			jsr	oldopenlib(a6)
			move.l	d0,dosbase(sp)
			move.l	d0,a6
			move.l	load_loadname(sp),d1
			move.l	#mode_oldfile,d2
			jsr	open(a6)
			tst.l	d0
			beq	load_filerror
			move.l	d0,load_filehandle(sp)

			move.l	load_loadname(sp),d1
			move.l	#mode_oldfile,d2
			jsr	lock(a6)
			move.l	d0,load_filelock(sp)

			move.l	d0,d1
			move.l	a0,-(sp)
			lea	load_fileinfoblock,a0
			move.l	a0,d2
			move.l	(sp)+,a0
			jsr	examine(a6)

			move.l	load_filelock(sp),d1
			jsr	unlock(a6)

			lea	load_fileinfoblock,a0
			move.l	load_filehandle(sp),d1
			move.l	load_buffer(sp),d2
			move.l	#$fffff,d3
			jsr	read(a6)
			move.l	d0,-(sp)		;length

load_seekerror:		move.l	load_filehandle+4(sp),d1
			jsr	close(a6)

load_filerror:		move.l	$4.w,a6
			move.l	dosbase+4(sp),a1
			jsr	closelibrary(a6)
			move.l	(sp)+,d1
			lea	20(sp),sp
			rts

;*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
write:		equ	-$030
mode_newfile:	equ	1006
;*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ
;a2 - name, a1 - buffer, d7 - length

HD_doWrite:		lea	-12(sp),sp
			move.l	a1,(sp)		;addr
			move.l	a2,4(sp)	;name
			move.l	d7,8(sp)	;length
			move.l	$4.w,a6
			lea	dosname,a1
			jsr	oldopenlib(a6)
			lea	wdosbase,a0
			move.l	d0,(a0)
			move.l	d0,a6

			move.l	4(sp),a0
			move.l	a0,d1
			move.l	#mode_newfile,d2
			jsr	open(a6)
			tst.l	d0
			beq	wr_writerror

			lea	wr_filehandle,a0
			move.l	d0,(a0)
			move.l	d0,d1
			move.l	(sp),d2
			move.l	8(sp),d3
			jsr	write(a6)

			move.l	wr_filehandle,d1
			jsr	close(a6)

wr_writerror:		move.l	$4.w,a6
			move.l	wdosbase,a1
			jsr	closelibrary(a6)
			lea	12(sp),sp
			moveq	#0,d0
			rts

;*ญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญญ

dosbase:		equ	0
load_filehandle:	equ	4
load_filelock:		equ	8
load_buffer:		equ	12
load_loadname:		equ	16

;-----------------------------------------------

diskAdr:	dc.l	disk1,disk2,disk3,disk4,disk5
disk1:
dc.b	0,1,"C01",0
dc.b	0,7,"C02",0
dc.b	0,53,"C03",0
dc.b	0,57,"C04",0
disk2:
dc.b	0,0,"C05",0
dc.b	0,10,"C06",0
dc.b	0,30,"C07",0
dc.b	0,54,"C08",0
disk3:
dc.b	0,0,"C09",0
dc.b	0,1,"C10",0
dc.b	0,22,"C11",0
dc.b	0,42,"C12",0
dc.b	0,62,"C13",0
dc.b	0,72,"C14",0
dc.b	0,76,"C15",0
disk4:
dc.b	0,0,"C24",0
dc.b	0,1,"C16",0
dc.b	0,12,"C17",0
dc.b	0,18,"C18",0
dc.b	0,21,"C19",0
dc.b	0,24,"C20",0
dc.b	0,34,"C21",0
dc.b	0,43,"C22",0
dc.b	0,60,"C23",0
disk5:



;-----------------------------------------------------------------------
	section texts,data_f
	IF LAN=1
t1:	dc.b	"        CITADEL INSTALLER (C) 1995 VIRTUAL DESIGN",0
t2:	dc.b	"        -----------------------------------------",0
T3:	DC.B	"   ENTER INSTALLATION PATH (MUST EXIST!) EG. DH1:GAMES",0
T4:	DC.B	"INSTALLATION OF 'THE CITADEL' IN PROGRESS...",0
T5:	DC.B	"SAVING INSTALLATION PATH AS 'S:CITADEL.CFG'...",0

T6:	DC.B	"COPYING DISK 0",0

T7:	DC.B	"INSTALLATION ABORTED!",0
T8:	DC.B	"PRESS ANY KEY TO RETURN TO DOS...",0
	ENDC


;-----------------------------------------------------------------------
	section various,data_f

KEYtab:
dc.b	$fd,$fb,$f9,$f7,$f5,$f3,$f1,$ef,$ed,$eb,$e9,$ad,$8d,$8b,$e5
dc.b	$df,$dd,$db,$d9,$d7,$d5,$d3,$d1,$cf,$cd
dc.b	$bf,$bd,$bb,$b9,$b7,$b5,$b3,$b1,$af
dc.b	$9d,$9b,$99,$97,$95,$93,$91,$7f,$e7,0
ASCIItab:
dc.b	"1234567890-:.//QWERTYUIOPASDFGHJKLZXCVBNM _"
even

gfxname:	dc.b	"graphics.library",0
even
dosname:	dc.b	"dos.library",0
even

CFGname:	dc.b	"S:Citadel.cfg",0
even


buf:	dc.w	4
dc.b	"DH0:"
blk.b	128,0

script:
dc.b	1
dc.b	0


wr_filehandle:	dc.l	0
wdosbase:	dc.l	0

even
prefname:	dc.b	"S:CITADEL.CFG",0
RestName:	dc.b	"/CITADEL/DATA/",0
even
l_offset:	dc.w	0
l_name:		blk.b	128,0


poz:		dc.w	1
klawisz:	dc.w	0
OldLev2:	dc.l	0
;-----------------------------------------------------------------------

	section infoblock,bss_c
ds.l	0
load_fileinfoblock:	ds.b	280

;-----------------------------------------------------------------------
	section copper,data_c
	
copper0:dc.l	$1800000,$1000300,-2
HIREScopper:
dc.w	$180,0,$182,$eee,$184,$003,$186,$eee

dc.w	$108,0,$10a,0
dc.l	$920050,$9400c0
dc.l	$8e3881,$90ffc3
dc.l	$1020000,$1040000
dc.w	$1fc,0,$106,0,$10c,0

ScrAddr:
dc.w	$e0,0,$e2,0
dc.w	$e4,0,$e6,0

dc.l	$5001ff00,$0100a300
dc.l	$f001ff00,$01000300
dc.l	-2

;-------------------------------------------------------------------

	section fonts,data_f
fonts:
incbin	"DAT1:store/FONTS01.FNT"

	section	screen,bss_c
screen:	ds.b	50*160*2

	section	buffer,bss_c
	ds.b	$800
buffer:	ds.b	$4000

	section dane,bss_f
dane:	ds.b	300000

end:




