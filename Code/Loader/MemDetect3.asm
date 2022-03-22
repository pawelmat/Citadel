����  8  8  8  8  8  8  8  8  8  8; BOOM HERE IT IS ...............
; A TERAZ ZANURZ TO W PLECHE - TAK JAK MAHANDI, I POSMARUJ POZNIEJ SMALCEM.
; NIE ZAPOMNIJ O DAWCE URYNY NA TRAWIENIE I ROPNYCH UPLAWACH DO SMAKU.

dtc_SIZEOF	equ	65356	; rozmiar tablicy 
                                ; szukany za .5 Mb fastu

; +10Kb by Pillar/SCT on 3.4.95

MaxExtMem		equ	78
MaxLocMem		equ	62

MEMF_CHIP		equ	2^1
MEMF_FAST		equ	2^2
MEMF_CLEAR		equ	2^16

_LVOAllocMem		equ	-$0c6
_LVOFreeMem		equ	-$0d2
_LVOTypeOfMem		equ	-$216

CALLEXE	Macro
	move.l	$4.w,a6
	jsr	\1(a6)
	Endm

; d0 - bity od 15-8 zapalone to komputer ma 1Mb Chip , zgaszone ma tylko .5Mb
; d0 - bity od 7-0 zapalone to komputer ma .5 FastMem , zgaszone to nie ma .
; d0 - bity od 16-24 zapalone to jest cos za .5 Mb fastu
; d1 - jezeli bity 7-0 w d0 sa zapalone to w d1 dostajesz offset do .5Mb
;	obszaru w pamieci Fast , w przeciwnym wypadku otrzymujesz tu NULL .

			SECTION	MemDetect,CODE

s:			movem.l	d2-d7/a0-a6,-(sp)
			moveq	#0,d0
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
			movem.l	(sp)+,d2-d7/a0-a6
			rts

Word:	dc.w	0
