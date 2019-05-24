	n	"DeskMod G"
if .p
	t	"TopSym"
	t	"TopMac
	t	"Sym128.erg"
	t	"CiSym"
	t	"CiMac"
	t	"DeskWindows..ext"
	t	"DeskTop.main.ext"
endif
	o	ModStart
;	jmp	_SwapFile
	nop
	nop
	nop
	jmp	DeskRelabel
	jmp	DeskFormat
	jmp	StartUp
	jmp	InstallDriver

:InstallDriver	lda	firstBoot
	bpl	:10
	jsr	GetAktlDisk
	tax
	beq	:10
	cpx	#12
	beq	:05
	jmp	FehlerAusgabe
::05	rts
::10	lda	FileClassNr
	cmp	#PRINTER
	bne	:Prnt6
	LoadW	:Prnt3,PrntFileName
	LoadW	r14,:PrntZeile1_1
	jmp	:Prnt7
::Prnt6	LoadW	:Prnt3,inputDevName
	LoadW	r14,:PrntZeile1_2
::Prnt7	lda	firstBoot
	beq	:Prnt1
	PushW	r15
	LoadW	r0,:PrntDial
	jsr	NewDoDlgBox
	PopW	r15
	lda	r0L
	cmp	#OK
	beq	:Prnt1
	rts
::Prnt1	lda	FileClassNr
	cmp	#PRINTER
	beq	:Prnt8
	jsr	DA1
	txa
	bne	:rts
	jsr	:Prnt8a
	jsr	StashDrivers
	jsr	InitMouse
::rts	rts
::Prnt8	lda	c128Flag
	bpl	:Prnt8a
	jsr	DA1
	LoadW	r0,$7900
	LoadW	r1,$d9c0
	LoadW	r2,$640
	LoadB	r3L,$01
	sta	r3H	; FrontRam nach FrontRam
	PushW	r15
	jsr	MoveBData
	dec	r1H	; r1 = $d8c0
	LoadB	r0H,$81
	LoadW	r2,$100
	jsr	MoveBData
	PopW	r15
::Prnt8a	MoveW	r15,:Prnt2
	jsr	i_MoveData
::Prnt2	w	0
::Prnt3	w	PrntFileName
	w	16
	lda	firstBoot
	bpl	:Prnt8b
	jsr	RedrawAll
	jmp	StashDrivers
::Prnt8b	jsr	PrintDriveNames
	jmp	StashDrivers

::PrntDial
	b	$81
	b	DBTXTSTR,$10,$10
	w	:PrntZeile1
	b	DBVARSTR,$10,$20,r14
	b	DBVARSTR,$10,$30,r15
	b	DBTXTSTR,$10,$40
	w	:PrntZeile2
	b	OK,1,76
	b	CANCEL,16,76
	b	NULL
::PrntZeile1	b	BOLDON,"Install new ",0
::PrntZeile1_1	b	"Printer driver?",0
::PrntZeile1_2	b	"Input driver?",0
::PrntZeile2	b	" ",0
:DA1	MoveW	r15,r6
	lda	#$00
	sta	r0L
	sta	r10L
	jmp	GetFile

:StashDrivers	lda	sysRAMFlg
	and	#%00100000
	bne	:10
::05	rts
::10	lda	c128Flag
	bpl	:15
	lda	sysRAMFlg	; Flag f}r Getfile setzen
	ora	#$10
	sta	sysRAMFlg
	ldy	#7
::12	lda	:tab2,y
	sta	r0L,y
	dey
	bpl	:12
	jsr	StashRAM	; Druckertreiber nach REU
	LoadW	r0,$fd00	; Input 128
	LoadW	r1,$f940
	jmp	:20
::15	LoadW	r0,$fe80	; bzw. Input 64 nach REU
	LoadW	r1,$fac0
::20	LoadW	r2,$0180
	LoadB	r3L,0
	jsr	StashRAM
	lda	sysRAMFlg
	and	#%00100000
	beq	:05
	ldy	#7
::22	lda	:tab2,y
	sta	r0L,y
	dey
	bpl	:22
	jmp	StashRAM
::tab1	w	$d8c0,$d500,$e000-$d8c0
	b	0
::tab2	w	$8400,$7900,$0500
	b	0

:myserial	w	0
:StartUp	lda	RamTopFlag
	beq	:norm
	lda	sysRAMFlg	; REU-MoveData ausschalten
	and	#$7f
	sta	sysRAMFlg
::norm	lda	c128Flag
	bpl	:010
	lda	graphMode
	bpl	:010
	and	#$7f
	sta	graphMode
	jsr	SetNewMode
::010	LoadB	iconSelFlag,0
	ldy	#3
::loop2	lda	windowsOpen,y
	pha
	lda	#0
	sta	windowsOpen,y
	dey
	bpl	:loop2
	LoadWr0	WindowTab
	jsr	DoWindows
	jsr	RedrawHead
	lda	screencolors
	sta	:col
	jsr	i_FillRam
	w	1000,$8c00
::col	b	0
	ldx	#$c0
	lda	#$95
	sec
	adc	#0
	inx
	jsr	CallRoutine
	CmpW	r0,myserial
	bne	:neu
	jmp	:allesok
::neu	LoadW	r0,:neudb
	LoadB	RecoverVector,0
	sta	RecoverVector+1
	jsr	DoDlgBox
	jmp	EnterDeskTop
::neudb	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	$0b,$10,$30
	w	:t3
	b	OK,14,72,NULL
::t1	b	BOLDON,"Please start again. Use",0
::t2	b	"the same Bootdisk as",0
::t3	b	"with TopDesk installation.",0
::allesok	LoadB	backPattern,2
	LoadW	keyVector,KeyHandler
	jsr	SetNumDrives
	ldx	numDrives
	inx
	inx
	stx	IconTab
	LoadWr0	IconTab
	jsr	NewDoIcons
	LoadW	newAppMain,DeskMain
	LoadW	otherPressVec,DeskOther
	jsr	ClearMultiFile
	lda	DispJumpTable
	bne	:10
	jsr	GetIconService
::10	LoadB	firstBoot,0
	lda	inputDevName
	bne	:30
	jsr	GetPrefs2
	lda	#10	; Input 64
	ldx	c128Flag
	bpl	:20
	lda	#15	; Input 128
::20	sta	r7L
	LoadB	r7H,1
	LoadB	Name,0
	LoadW	r6,Name
	jsr	FindFTypes
	lda	Name
	beq	:30
	LoadB	r1L,0
	LoadW	r6,Name
	jsr	NewGetFile
::30	lda	PrntFileName
	bne	:40
	LoadB	r7L,9	; Printer
	LoadB	r7H,1
	LoadB	Name,0
	LoadW	r6,Name
	jsr	FindFTypes
	lda	Name
	beq	:40
	LoadB	r1L,0
	LoadW	r6,Name
	jsr	NewGetFile
::40	LoadB	firstBoot,$ff
	jsr	SetCopyMemLow
	ldy	#0
::loop3	pla
	sta	windowsOpen,y
	iny
	cpy	#4
	bne	:loop3
	jmp	Start2

	t	"DosFormat.s"
:DeskFormat	MoveB	curDrive,Name+2	; nur Zwischenspeicher
::dloop	lda	curType
	and	#$80
	beq	:noram
	ldx	curDrive
	inx
	txa
	cmp	Name+2
	beq	:nodrive
	lda	driveType-8,x
	beq	:n8
	txa
	jsr	NewSetDevice
	txa
	beq	:dloop
::n8	lda	#8
	cmp	Name+2
	beq	:nodrive
	jsr	NewSetDevice
	jmp	:dloop
::nodrive	rts
::noram	LoadB	Name+2,0
	PushB	numDrives
	cmp	#1
	bne	:05
	ldy	#0
	sty	:abhier
	beq	:08	
::05	LoadB	numDrives,4
	tay
	dey	; g}ltige Laufwerke ermitteln
::06	lda	driveType,y
	tax
	beq	:06a	; d.h. keine nicht vorhandenen Laufwerke
	and	#%10000000	; und keine RAM-Disks
	bne	:06a
	sty	r1L
	jmp	:07
::06a	dec	numDrives	; Eine ermittelte RAM-Disk wird nicht
	tya		; als zu formatierendes Laufwerk an-
	asl		; geboten, in dem das zugeh|rige
	tax		; Icon in der Dialogbox nicht 
	lda	:icontab,x	; dargestellt wird, durch
	sta	r0L	; MoveW 0,:icontab+RamLaufw*2 .
	lda	:icontab+1,x
	sta	r0H
	ldy	#0
	tya
	sta	(r0),y
	iny
	sta	(r0),y
	sta	MyCurRec	; beim n{chsten Mal Modul erneut laden
	txa		; da Icontabelle modifiziert wurde
	lsr
	tay
::07	dey
	bpl	:06
	ldx	numDrives	; nur ein g}ltiges Laufw. ?
	dex
	bne	:08	; >nein
	lda	#0
	sta	:abhier
	sta	MyCurRec	; beim n{chsten Mal Modul erneut laden
	lda	r1L	; da Icontabelle modifiziert wurde
	clc
	adc	#8
	jsr	NewSetDevice

::08	PopB	numDrives
	lda	curDrive
::08geht	clc
	adc	#57
	sta	:dr
::09	LoadW	a1,Name+2
	LoadW	r0,:db
	inc	DialBoxFlag
	jsr	NewDoDlgBox
	lda	r0L
	cmp	#$02	; Abbruch-Feld geklickt?
	beq	:99	; >ja
	cmp	#$12	; Laufwerk ge{ndert ?
	bne	:10	; >nein
	jmp	:09
::10	lda	:dr
	sec
	sbc	#57
	jsr	NewSetDevice
	lda	curType
	cmp	#2	; Soll auf 1571 formatiert werden ?
	bne	:99a	; >nein
	LoadW	r0,:db2
	jsr	NewDoDlgBox	; "Doppelseitig formatieren?"
	LoadB	r1L,0	; Doppelseitig-Flag
	lda	r0L
	cmp	#2
	beq	:99	; Abbruch 
	cmp	#YES
	bne	:99a
	LoadB	r1L,1	; Doppelseitig-Flag
::99a	LoadW	r0,Name+2
	jsr	DosFormat
	txa
	beq	:99
	inc	DialBoxFlag
	jmp	FehlerAusgabe
::99	jmp	RedrawAll
::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$10+11
	w	:t2
	b	$0b,$10,$10+22
	w	:t3
	b	$0d,$10,$10+40,a1,16
	b	$02,17,72
::abhier	b	$12,2,72
	w	:icon1
	b	$12,5,72
	w	:icon2
	b	$12,8,72
	w	:icon3
	b	$12,11,72
	w	:icon4
	b	NULL
::t1	b	"Insert disk to be formatted",0
::t2	b	"in drive "
::dr	b	". einlegen ",0
::t3	b	"and enter name:",0
::icontab	w	:icon1,:icon2,:icon3,:icon4
::icon1	w	IconA,0
	b	ICON_X,ICON_Y
	w	:icon1+8
	LoadB	:dr,"A"
	LoadB	$851d,$12
	jmp	RstrFrmDialogue
::icon2	w	IconB,0
	b	ICON_X,ICON_Y
	w	:icon2+8
	LoadB	:dr,"B"
	LoadB	$851d,$12
	jmp	RstrFrmDialogue
::icon3	w	IconC,0
	b	ICON_X,ICON_Y
	w	:icon3+8
	LoadB	:dr,"C"
	LoadB	$851d,$12
	jmp	RstrFrmDialogue
::icon4	w	IconD,0
	b	ICON_X,ICON_Y
	w	:icon4+8
	LoadB	:dr,"D"
	LoadB	$851d,$12
	jmp	RstrFrmDialogue
::db2	b	$81
	b	$0b,$10,$10
	w	:2t1
	b	$0b,$10,$20
	w	:2t2
	b	$0b,$10,$30
	w	:2t3
	b	$02,17,72
	b	YES,2,72
	b	NO,9,72
	b	NULL
::2t1	b	BOLDON,"Format the disk",0
::2t2	b	"on both sides? ",0
::2t3	b	PLAINTEXT,0
:IconA

	b	$02,$10,$00,$a0,$ff,$fe,$80,$03
	b	$80,$03,$83,$03,$87,$83,$87,$83
	b	$8c,$c3,$8c,$c3,$8f,$c3,$98,$63
	b	$98,$63,$98,$63,$80,$03,$80,$03
	b	$ff,$ff,$7f,$ff
:IconB

	b	$02,$10,$00,$a0,$ff,$fe,$80,$03
	b	$80,$03,$8f,$c3,$8c,$63,$8c,$63
	b	$8c,$63,$8f,$c3,$8c,$63,$8c,$63
	b	$8c,$63,$8f,$c3,$80,$03,$80,$03
	b	$ff,$ff,$7f,$ff
:IconC

	b	$02,$10,$00,$a0,$ff,$fe,$80,$03
	b	$80,$03,$87,$c3,$8c,$63,$98,$03
	b	$98,$03,$98,$03,$98,$03,$98,$03
	b	$8c,$63,$87,$c3,$80,$03,$80,$03
	b	$ff,$ff,$7f,$ff
:IconD

	b	$02,$10,$00,$a0,$ff,$fe,$80,$03
	b	$80,$03,$8f,$c3,$8c,$63,$8c,$63
	b	$8c,$63,$8c,$63,$8c,$63,$8c,$63
	b	$8c,$63,$8f,$c3,$80,$03,$80,$03
	b	$ff,$ff,$7f,$ff,$04,$b1

:ICON_X	= .x
:ICON_Y	= .y


:DeskRelabel	ldx	activeWindow
	jsr	GetEqualWindows
	ldx	activeWindow
	lda	#1
	sta	a6L,x
	LoadB	DialBoxFlag,25	; irgendein Wert, m|glichst hoher Wert
	jsr	GetAktlWinDisk
	LoadW	r6,DiskName+2
	jsr	Relabel
	txa
	bne	:end
	sta	a5H
	ldx	#3
::loop	stx	a5L
	lda	a6L,x
	beq	:10
	inc	a5H
	txa
	jsr	GetWinName
	IncW	r1
	IncW	r1
	ldy	#00
::20	lda	(r6),y
	beq	:30
	sta	(r1),y
	iny
	bne	:20
::30	cpy	#16
	beq	:10
	lda	#PLAINTEXT
	sta	(r1),y
	iny
	bne	:30
::10	ldx	a5L
	dex
	bpl	:loop
	ldx	a5H
	dex
	bne	:40
::end	LoadB	DialBoxFlag,0
	jmp	RecoverLast
::40	LoadB	DialBoxFlag,0
	jmp	RedrawAll

; Relabel
; belegt eine Diskette mit einem neuen Namen
; Par: r6 - Zeiger auf den Diskettennamen
; Ret: x=0 kein Fehler
;      r6 - neuer Diskettenname
; Des: a,y,r0-r5
:Relabel
	jsr	SearchDisk
	txa
	bne	:err
	ldy	#0
::a10	lda	(r6),y
	sta	diskBlkBuf,y
	beq	:a20
	iny
	bne	:a10
::a20	PushW	r6
	LoadW	r5,diskBlkBuf	;DoDlgBox vorbereiten
	LoadW	r0,:renbox
	jsr	NewDoDlgBox
	PopW	r6
	ldy	r0L	;auf Abbruch
	cpy	#CANCEL	;pr}fen
	beq	:13	;ja :13
	lda	diskBlkBuf	;auf Leerstring pr}fen
	bne	:15	;nein :15
::13	ldx	#CANCEL_ERR
::err	rts
::15	jsr	GetDirHead	;
	txa
	bne	:err
	ldy	#15	;Diskname
::20	lda	#$a0
	sta	curDirHead+144,y
	dey
	bpl	:20
	ldy	#0
::30	lda	diskBlkBuf,y	;in die BAM
	sta	(r6),y	;und in die ]bergabe
	beq	:40	;}bertragen
	sta	curDirHead+144,y
	iny
	cpy	#16
	bne	:30
::40	jmp	PutDirHead
::renbox
	b	$81
	b	DBTXTSTR
	b	10,20
	w	:rentext
	b	DBTXTSTR
	b	10,30
	w	:rentxt2
	b	DBGETSTRING
	b	10,40,r5,16
	b	CANCEL
	b	16,72
	b	NULL

::rentext	b	BOLDON,"Please enter the new",0
::rentxt2	b	"disk name:",PLAINTEXT,0
