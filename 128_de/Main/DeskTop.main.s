	a	"DPT KnCiGo"
	z	$40
	i	$03,$15,$00,$bf,$ff,$ff,$ff,$92
	i	$49,$21,$ff,$ff,$3f,$80,$00,$01
	i	$bf,$ff,$cd,$a0,$00,$4d,$bf,$ff
	i	$c1,$a0,$00,$4d,$a7,$ff,$fd,$a4
	i	$00,$09,$bf,$ff,$fd,$84,$00,$0d
	i	$bc,$00,$09,$a4,$00,$0d,$bc,$00
	i	$0d,$a7,$ff,$f9,$a0,$00,$41,$a0
	i	$00,$4d,$bf,$ff,$cd,$80,$00,$01
	i	$ff,$ff,$ff,$09,$bf
	p	Start
if .p
	t	"TopSym"
	t	"TopMac
	t	"Sym128.erg"
	t	"CiSym"
	t	"CiMac"
	t	"DeskWindows..ext"
endif
	d	"DeskWin $400"
	n	"Dos.res"
	c	"TopDesk128  V1.3"
	jmp	NewSetDevice
	jmp	DispMarking
	jmp	ClearMultiFile
	t	"CopyFile"
	t	"SearchDisk"
	t	"SizeRectangle"
	t	"SubDir.src"
.Start	jsr	SetMyNewMode
	lda	RamTopFlag
	beq	:05
	lda	oldGraphMode
	cmp	graphMode
	beq	:10
	jsr	SwitchWin
	jmp	:10
::05	jsr	StartWin
	ldy	#4
::tloop	lda	:t,y
	cmp	$81a0,y
	bne	:10
	dey
	bpl	:tloop
	LoadB	SureFlag,1
::10	MoveB	graphMode,oldGraphMode
	lda	mouseData
	ora	#$80
	sta	mouseData
	LoadW	ModStartAdress,ModStart
	LoadB	dispBufferOn,%10000000
	ldy	#0
::loop	lda	$8403,y
	cmp	#$a0
	bne	:01
	lda	#0
	sta	MyName,y
	beq	:02
::01	sta	MyName,y
	iny
	bne	:loop
::02	jmp	StartUp
::t	b	"SURE",$0d

.Loadr0AX	sta	r0L
	stx	r0H
	rts
:MoveWr0r1	MoveW	r0,r1
	rts
:MoveWr1r0	MoveW	r1,r0
	rts
.OpenDiskFlag	b	0
.DiskDriverFlag	b	0
.NewSetDevice	jmp	SetDevice

.CopyMemHigh	b	$7f
.CopyMemLow	b	$60
.SetCopyMemLow	ldx	#>ModStart+$100
:SCML	stx	CopyMemLow
	rts

.GetPrefs2	ldx	activeWindow
	lda	windowsOpen,x
	beq	GetPrefs
	jsr	GetWinDisk
:GetPrefs	LoadW	r6,:name
	jsr	FindFile
	txa
	beq	:10
	rts
::10	MoveW	$8401,r1
	LoadW	r4,$8000
	jsr	GetBlock
	txa
	beq	:20
	rts
::20	ldy	#2
::25	lda	$8000+2,y
	sta	$8501,y	; maxMouseSpeed
	dey
	bpl	:25
	jsr	InitForIO
	lda	$8005
	ora	$8006
	sta	screencolors
	MoveB	$8000+5,$d021
	MoveB	$8000+7,$d027
	MoveB	$8000+71,$d020
	lda	$8001
	cmp	#73	; c128-Preferences ?
	bne	:26	; >nein
	MoveB	$8000+72,$88bd	; scr80colors
	MoveB	$8000+73,$88bc	; scr80polar
::26	jsr	DoneWithIO
	ldy	#62
::30	lda	$8000+8,y
	sta	$84c1,y	; mousePicData
	dey
	bpl	:30
	jmp	SetColor
::name	b	"Preferences",0
:SetColor	lda	screencolors	; Farben wiederherstellen
	sta	:col
	jsr	i_FillRam
	w	1000,$8c00
::col	b	0
	rts

.University	d	"University 6"
:BitMap	j
	b	$03,$18,$00,$c5,$aa,$aa,$aa,$55
	b	$ff,$ff,$ab,$00,$06,$56,$7f,$cb
	b	$ac,$00,$12,$59,$ff,$23,$b0,$00
	b	$42,$60,$00,$83,$c0,$01,$06,$ff
	b	$fe,$0d,$80,$02,$1a,$83,$82,$35
	b	$9f,$f2,$6a,$83,$82,$d5,$80,$03
	b	$aa,$7f,$fd,$55,$aa,$aa,$aa,$55
	b	$55,$55,$aa,$aa,$aa,$55,$55,$55
	b	$aa,$aa,$aa,$55,$55,$55,$aa,$aa
	b	$aa,$83,$55,$55,$55
	b	21
:BitX	= 3
:BitY	= 15
:TrashMap	b	$03,$18,$00,$c8,$aa,$aa,$aa,$55
	b	$7f,$55,$aa,$eb,$aa,$5f,$ff,$fd
	b	$a8,$00,$0a,$5f,$ff,$fd,$ac,$00
	b	$1a,$55,$22,$55,$ad,$22,$5a,$55
	b	$22,$55,$ad,$22,$5a,$55,$22,$55
	b	$ad,$22,$5a,$55,$22,$55,$ad,$22
	b	$5a,$55,$22,$55,$ad,$22,$5a,$55
	b	$22,$55,$ac,$c1,$9a,$56,$00,$35
	b	$af,$ff,$fa,$55,$55,$55,$aa,$aa
	b	$aa,$55,$55,$55
:TrashX	= 3
:TrashY	= 21
:PrintMap	b	$03,$18,$00,$c8,$aa,$aa,$aa,$55
	b	$55,$55,$aa,$aa,$aa,$55,$55,$55
	b	$aa,$aa,$aa,$57,$ff,$ff,$ac,$00
	b	$03,$59,$00,$65,$b3,$ff,$c9,$67
	b	$ff,$95,$c0,$00,$2d,$ff,$ff,$cb
	b	$80,$00,$46,$81,$fe,$4d,$b0,$00
	b	$5a,$80,$00,$75,$ff,$ff,$ea,$55
	b	$55,$55,$aa,$aa,$aa,$55,$55,$55
	b	$aa,$aa,$aa,$55,$55,$55,$aa,$aa
	b	$aa,$55,$55,$55
:PrintX	= 3
:PrintY	= 21

.Start2	lda	RamTopFlag
	bne	:10
	lda	ramExpSize
	beq	:09
	jsr	SearchDeskTop
	bcs	:08
	lda	#" "
	ldx	$8091
	beq	:05
	lda	#"*"
::05	sta	AutoSwapFlag
	lda	$8090
	beq	:08
	CmpWI	$88ee,$ffa0	; DrDCurDkNm
	bne	:07
	LoadW	$8090,0
	MoveW	$8400+19,r1
	LoadW	r4,$8000
	jmp	PutBlock
::07	jmp	MakeRamTop
::08	rts
::09	jmp	GetDiskDrivers
::10	jmp	ReLoadAll2
;	jmp	GetWindowStat
;	jmp	OpenNext

.JmpSub2	pha
	txa
	pha
	jsr	GotoFirstMenu
	ldx	activeWindow
	lda	windowsOpen,x
	bne	:geht
	pla
	pla
	rts
::geht	pla
	tax
	pla
.JmpSub	pha
	txa
	jsr	GetModule
	bcs	:10
	pla
	sta	r0L
	clc
	adc	r0L
	adc	r0L
	adc	ModStartAdress
	sta	r0L
	lda	ModStartAdress+1
	adc	#0
	sta	r0H
	jmp	(r0)
::10	pla
	rts
:StartUp	lda	#7
	jsr	GetModule
	MoveW	ModStart+3*3+1,r1
	SubVW	2,r1
	ldy	#0
	lda	(r1),y
	iny
	ora	(r1),y
	beq	:10
	jsr	:sub
	AddVW	2,r1
	jmp	(r1)
::10	lda	r7L
	sec
	sbc	#<ModStart
	sta	r2L
	lda	r7H
	sbc	#>ModStart
	sta	r2H
	LoadW	r7,ModStart
	MoveW	ModStart+3*3+1,r1
	SubVW	2,r1
	jsr	GetSerialNumber
	ldy	#0
	lda	r0L
	sta	(r1),y
	iny
	lda	r0H
	sta	(r1),y
	jsr	:sub
	LoadW	r0,MyName
	jsr	OpenRecordFile
	lda	#7
	jsr	PointRecord
	jsr	WriteRecord
	jsr	CloseRecordFile
	jmp	StartUp
::sub	ldy	#0
::loop	lda	(r1),y
	eor	#%1011101
	sta	(r1),y
	iny
	bne	:loop
	rts
.ModDepth	b	0
.RamTopFlag	b	0
.SureFlag	b	0
.GetTextService	ldx	#6	; im Akku Nr. des Anzeigemodus 
	b	$2c	; }bergeben
.GetIconService	ldx	#5	; im Akku 0 }bergeben
	pha
	txa
	pha
	jsr	GotoFirstMenu
	LoadW	ModStartAdress,DispJumpTable
:ServiceMod	pla
	jsr	GetModule
	LoadW	ModStartAdress,ModStart
	bcs	:10
	pla
	sta	DispMode
	jmp	ReLoadAll
::10	pla
	rts
.DispMode	b	0
:JmpMod	m		; 7 Bytes
	ldx	#@0
	lda	#@1
	jmp	JmpSub
/
:JmpMod2	m		; 7 Bytes
	ldx	#@0
	lda	#@1
	jmp	JmpSub2
/

if 0
:SaveWindowStat	jsr	GotoFirstMenu
	lda	#9	; ramDrive
	bne	:05
	rts
::05	jsr	SetDevice
	jsr	OpenDisk
	ldy	#0
::10	lda	SubDir1List,y
	sta	$6000,y
	dey
	bne	:10
	LoadW	a2,$6100
	ldx	#3
::loop2	stx	a1L
	jsr	GetWinDisk
	ldy	#16
::loop	lda	DiskName+2,y
	sta	(a2),y
	dey
	bpl	:loop
	AddVB	16,a2L
	ldx	a1L
	dex
	bpl	:loop2
	jsr	i_MoveData
	w	windowsOpen,$6140,4
	jsr	i_MoveData
	w	WindowTab,$6140+4,6
	jsr	i_MoveData
	w	WindowTab+11,$6140+4+6,6
	jsr	i_MoveData
	w	WindowTab+22,$6140+4+12,6
	jsr	i_MoveData
	w	WindowTab+33,$6140+4+18,6
	LoadW	r0,StatName
	jsr	DeleteFile
	LoadW	$8100,StatName
	LoadB	$8102,$03
	LoadB	$8103,$15
	LoadB	$8104,$bf
	LoadB	$8144,$82	; USR
	LoadB	$8145,3	; DATA
	LoadB	$8146,0	; SEQ
	LoadW	$8147,$6000	; LadrAdr
	LoadW	$8149,$61f0	; = 2 Bl|cke
	LoadB	$81a0,0	; kein Info
	LoadW	r9,$8100
	LoadB	r10L,0
	jmp	SaveFile
.StatName	b	"TopDesk.inf",0
endif

:DeskDosNew	JmpMod2	1,0
:DValidate	JmpMod2	1,1
:GetWindowStat	JmpMod	1,2
.GetDiskDrivers	JmpMod	1,3
;:SelectPage	JmpMod2	2,0
:EmptyAllDirs	JmpMod2	2,1
:DispInfo	jsr	GotoFirstMenu
	JmpMod	2,2
:DeskRename	JmpMod2	2,3
:DeskDuplicate	JmpMod2	2,4
;:SelectAll	JmpMod2	2,5
:GetTime	jsr	GotoFirstMenu
	JmpMod	3,0
:Ordnen	JmpMod2	3,1
:ThreeDrives	rts
;	JmpMod	3,0
:DispFileInfo	JmpMod2	4,0
;:SwapFile	JmpMod	7,0
:DeskRelabel	JmpMod2	7,1
:DeskFormat	jsr	GotoFirstMenu
	JmpMod	7,2
:InstallDriver	JmpMod	7,4
:DCopy	JmpMod2	8,0
;:SetWindows	JmpMod2	8,1
:NeuerOrdner	JmpMod2	9,0
:CopyDir	JmpMod	9,1
;:DeleteDir	JmpMod	9,2
:MakeRamTop	jsr	GotoFirstMenu
	LoadB	MyCurRec,0
	ldx	#10
	lda	#0
	jsr	JmpSub
	txa
	beq	:10
	rts
::10	jmp	ReLoadAll

:StashMain	lda	RamTopFlag
	bne	:geht
	rts
::geht	LoadB	MyCurRec,0
	ldy	#r15H-r0L
::loop	lda	r0L,y
	sta	RegBuf,y
	dey
	bpl	:loop
	JmpMod	10,2

:oldGraphMode	b	0
:wb	m
	w	@0
	b	@1
	/
:ww	m
	wb	@0,<@1
	wb	@0+1,>@1
	/
:Switch	jsr	GotoFirstMenu
	lda	graphMode
	eor	#$80
	sta	graphMode
	sta	oldGraphMode
	jsr	SetNewMode
	jsr	SetMyNewMode
	jsr	SetColor
	jsr	RedrawHead
	jsr	DispMultiCount
	jsr	SwitchWin
	jmp	RedrawAll
:SwitchWin	lda	graphMode
	bpl	:g40
	jsr	G80
	jmp	:10
::g40	lda	#" "
	sta	SchmalFlag
	jsr	G40
::10	rts
:G40	LoadW	r0,Window1
	jsr	Halbieren
	LoadW	r0,Window2
	jsr	Halbieren
	LoadW	r0,Window3
	jsr	Halbieren
	LoadW	r0,Window4
	jmp	Halbieren
:G80	LoadW	r0,Window1
	jsr	Doppeln
	LoadW	r0,Window2
	jsr	Doppeln
	LoadW	r0,Window3
	jsr	Doppeln
	LoadW	r0,Window4
	jmp	Doppeln
:SetMyNewMode	lda	graphMode
	bpl	:40
::80	LoadW	r0,:tab2
	jmp	:10
::40	LoadW	r0,:tab1
::10	ldy	#0
	lda	(r0),y
	sta	r1L
	iny
	lda	(r0),y
	sta	r1H
	ora	r1L
	beq	:end
	iny
	lda	(r0),y
	ldy	#0
	sta	(r1),y
	AddvW	3,r0
	jmp	:10
::end	rts

::tab1	wb	IconTab+6,(39-TrashX)
	wb	IconTab+14,2
	wb	IconTab+22,STARTA_X
	wb	IconTab+30,STARTB_X
	wb	IconTab+38,STARTC_X
	wb	IconTab+46,STARTD_X
	ww	RightMax,319
	wb	GraphIndex,8
	ww	HauptMenu+4,214
	ww	DispMenuRight,214
	ww	geosoben+4,80
	ww	Datei_Men}+2+3,28
	ww	Datei_Men}+4+3,112
	ww	Anzeige_Men}+2+3,57
	ww	Anzeige_Men}+4+3,170
	ww	Disk_Men}+2+3,98
	ww	Disk_Men}+4+3,180
	ww	WindowMen}+2+3,137
	ww	WindowMen}+4+3,256
	ww	Speziell_Men}+2+15,174
	ww	Speziell_Men}+4+15,267
	w	0
::tab2	wb	IconTab+6,(39-TrashX)*2
	wb	IconTab+14,2*2
	wb	IconTab+22,STARTA_X*2
	wb	IconTab+30,STARTB_X*2
	wb	IconTab+38,STARTC_X*2
	wb	IconTab+46,STARTD_X*2
	ww	RightMax,639
	wb	GraphIndex,1
	ww	HauptMenu+4,286
	ww	DispMenuRight,286
	ww	geosoben+4,104
	ww	Datei_Men}+2+3,36
	ww	Datei_Men}+4+3,145
	ww	Anzeige_Men}+2+3,73
	ww	Anzeige_Men}+4+3,224
	ww	Disk_Men}+2+3,127
	ww	Disk_Men}+4+3,234
	ww	WindowMen}+2+3,177+7
	ww	WindowMen}+4+3,332+7
	ww	Speziell_Men}+2+15,226+8
	ww	Speziell_Men}+4+15,346+8
	w	0

:STARTA_X	=	(39-BitX)
:STARTA_Y	=	32
:STARTB_X	=	(39-BitX)
:STARTB_Y	=	64
:STARTC_X	=	(39-BitX)
:STARTC_Y	=	96
:STARTD_X	=	(39-BitX)
:STARTD_Y	=	128
.IconTab	b	0,0,0,0	; Anzahl wird berechnet
	w	TrashMap
	b	(39-TrashX),191-TrashY,TrashX+DOUBLE_B,TrashY
	w	TrashService
	w	PrintMap
	b	2,193-PrintY,PrintX+DOUBLE_B,PrintY
	w	PrintService
	w	BitMap
	b	STARTA_X,STARTA_Y,BitX+DOUBLE_B,BitY
	w	OpenD8
	w	BitMap
	b	STARTB_X,STARTB_Y,BitX+DOUBLE_B,BitY
	w	OpenD9
	w	BitMap
	b	STARTC_X,STARTC_Y,BitX+DOUBLE_B,BitY
	w	OpenD10
	w	BitMap
	b	STARTD_X,STARTD_Y,BitX+DOUBLE_B,BitY
	w	OpenD11
:OpenD11	lda	#11
	b	$2c
:OpenD10	lda	#10
	b	$2c
:OpenD9	lda	#9
	b	$2c
:OpenD8	lda	#8
:OpenDa	pha
	lda	numDrives
	cmp	#2
	bcc	:10
	lda	KSFlag
	bne	:09
	jsr	CheckKlick
	bcs	:10
::09	pla
	sta	:dr
	LoadW	r4,BitMap+1
	LoadB	r3L,2
	jsr	DrawSprite
	jsr	HideOnlyMouse
	LoadB	ghostFile,$ff
	jsr	InitForIO
	MoveB	$d027,$d029	; Farbe des Ghost-Sprites von Mauszeiger
	lda	graphMode
	bmi	:g80
	lda	$d01d
	and	#%11111011
	sta	$d01d
	jmp	:gend
::g80	lda	$d01d
	ora	#%100
	sta	$d01d
::gend	jsr	DoneWithIO
	LoadB	KSFlag,0
	rts
::10	lda	:dr
	beq	:20
	lda	ghostFile
	bpl	:20
	ldx	:dr
	pla
	jsr	ChangeDrive
	LoadB	:dr,0
	LoadB	AskDiskFlag,0
	ldx	#3
::loop	lda	windowsOpen,x
	beq	:15
	txa
	pha
	jsr	GetDisk
	pla
	tax
::15	dex
	bpl	:loop
	LoadB	AskDiskFlag,$ff
	jmp	RedrawAll
::20	ldx	numDrives	; bei numDrives=1 kein Laufwerkswechsel
	dex
	bne	:25
	pla
	cmp	curDrive
	beq	:26
::24	rts
::25	pla
	pha
	tay
	lda	driveType-8,y
	beq	:27
	pla
::26	jsr	NewSetDevice
	jmp	OpenNext
::27	pla
	rts
::dr	b	0
.DeskMain	lda	ghostFile
	beq	:rts
	lda	$3a
	sec
	sbc	#10
	sta	r4L
	lda	$3b
	sbc	#00
	sta	r4H
	lda	$3c
	sec
	sbc	#10
	sta	r5L
	LoadB	r3L,2
	jsr	PosSprite
	jsr	EnablSprite
	LoadB	mouseTop,15
::rts	rts
.DeskOther	lda	mouseData
	bpl	:10
	rts
::10	LoadW	r3,ClxL
	LoadW	r4,ClxR
	LoadB	r2L,ClyO
	LoadB	r2H,ClyU
	jsr	IsMseInRegion
	bne	:20
	jmp	EndGhost
::20	jmp	GetTime
:KSFlag	b	0
:KS8	lda	#8
	b	$2c
:KS9	lda	#9
	b	$2c
:KS10	lda	#10
	b	$2c
:KS11	lda	#11
	ldx	#1
	stx	KSFlag
	jmp	OpenDa

:mpt	m
	w	@0
	b	@1
	w	@2
	/
:HauptMenu	b	0,13
	w	0,214
	b	6
	mpt	:t1,DYN_SUB_MENU,geos_Men}
	mpt	:t2,DYN_SUB_MENU,Datei_Men}
	mpt	:t3,DYN_SUB_MENU,Anzeige_Men}
	mpt	:t4,DYN_SUB_MENU,Disk_Men}
	mpt	:t6,DYN_SUB_MENU,WindowMen}
	mpt	:t5,DYN_SUB_MENU,Speziell_Men}
::t1	b	"geos",NULL
::t2	b	"Datei",NULL
::t3	b	"Anzeige",NULL
::t4	b	"Diskette",NULL
::t5	b	"Speziell",NULL
::t6	b	"Fenster",NULL
:DISKRIGHT	=	177
:Disk_Men}	jsr	MySubMenu
	b	13,84
	w	98,DISKRIGHT
	b	$85
	mpt	:t1,MENU_ACTION,DeskRelabel
	mpt	:t2,MENU_ACTION,DeskDosNew
	mpt	:t3,MENU_ACTION,DeskFormat
	mpt	:t4,MENU_ACTION,DCopy
	mpt	:t5,MENU_ACTION,DValidate
::t1	b	"Umbenennen",GOTOX
	w	DISKRIGHT-20
	b	128,BOLDON,"N",PLAINTEXT,0
::t2	b	"L|schen",GOTOX
	w	DISKRIGHT-20
	b	128,BOLDON,"E",PLAINTEXT,0
::t3	b	"Formatieren",GOTOX
	w	DISKRIGHT-20
	b	128,BOLDON,"F",PLAINTEXT,0
::t4	b	"Kopieren",GOTOX
	w	DISKRIGHT-20
	b	128,BOLDON,"K",PLAINTEXT,0
::t5	b	"Aufr{umen",GOTOX
	w	DISKRIGHT-20
	b	128,BOLDON,"V",PLAINTEXT,0
:DATEIRIGHT	= 112
:Datei_Men}	jsr	MySubMenu
	b	13,98+14
	w	28,DATEIRIGHT
	b	$87
	mpt	:t1,MENU_ACTION,Datei|ffnen
	mpt	:t2,MENU_ACTION,DeskDuplicate
	mpt	:t3,MENU_ACTION,DeskRename
	mpt	:t4,MENU_ACTION,DispFileInfo
	mpt	:t5,MENU_ACTION,DateiDrucken
	mpt	:t6,MENU_ACTION,DeskDelete
	mpt	:t7,MENU_ACTION,Ordnen
::t1	b	"\ffnen",GOTOX
	w	DATEIRIGHT-22
	b	128,BOLDON,"Z",PLAINTEXT,0
::t2	b	"Duplizieren",GOTOX
	w	DATEIRIGHT-22
	b	128,BOLDON,"H",PLAINTEXT,0
::t3	b	"Umbenennen",GOTOX
	w	DATEIRIGHT-22
	b	128,BOLDON,"M",PLAINTEXT,0
::t4	b	"Info",GOTOX
	w	DATEIRIGHT-22
	b	128,BOLDON,"Q",PLAINTEXT,0
::t5	b	"Drucken",GOTOX
	w	DATEIRIGHT-22
	b	128,BOLDON,"P",PLAINTEXT,0
::t6	b	"L|schen",GOTOX
	w	DATEIRIGHT-22
	b	128,BOLDON,"D",PLAINTEXT,0
::t7	b	"Vorsortieren",GOTOX
	w	DATEIRIGHT-22
	b	128,BOLDON,"T",PLAINTEXT,0
:Anzeige_Men}	jsr	MySubMenu
	b	13,8*14+14
	w	57,180
	b	$88
	mpt	:t1,$00,:rout
	mpt	:t2,$00,:rout
	mpt	:t3,$00,:rout
	mpt	:t4,$00,:rout
	mpt	:t5,$00,:rout
	mpt	KBytesFlag,$00,:rout2
	mpt	:t7,$00,:rout3
	mpt	SchmalFlag,$00,SwapSchmal
::t1	b	"* Icons",0
::t2	b	"  nach Namen",0
::t3	b	"  nach Datum",0
::t4	b	"  nach Gr|~e",0
::t5	b	"  nach Typ",0
::t7	b	"* in KBytes",0
::rout	pha
	lda	#" "
	sta	:t1
	sta	:t2
	sta	:t3
	sta	:t4
	sta	:t5
	pla
	pha
	asl
	tay
	lda	:tab,y
	sta	r0L
	lda	:tab+1,y
	sta	r0H
	ldy	#0
	lda	#"*"
	sta	(r0),y
	pla
	bne	:r10
	jmp	GetIconService
::r10	jmp	GetTextService
::tab	w	:t1,:t2,:t3,:t4,:t5
::rout2	lda	#" "
	ldx	#"*"
::rout23	sta	:t7
	stx	KBytesFlag
	jsr	GotoFirstMenu
	jmp	RedrawAll
::rout3	lda	#"*"
	ldx	#" "
	jmp	:rout23

:SwapSchmal	lda	SchmalFlag
	cmp	#"*"
	beq	:10
	jsr	G40
	ldx	#"*"
	jmp	:20
::10	jsr	G80
	ldx	#" "
::20	stx	SchmalFlag
	jsr	GotoFirstMenu
	jsr	CheckAll
	jmp	RedrawAll
.KBytesFlag	b	"  in Bl|cken",0
.SchmalFlag	b	"  schmale Anzeige",GOTOX
	w	180-22
	b	128,BOLDON,"G",PLAINTEXT,0

:CheckAll	LoadW	r0,Window1
	jsr	CheckOne
	LoadW	r0,Window2
	jsr	CheckOne
	LoadW	r0,Window3
	jsr	CheckOne
	LoadW	r0,Window4
	jmp	CheckOne

:WINWDOWRIGHT	=	256
:WindowMen}	jsr	MySubMenu
	b	13,28+28+14
	w	137,WINWDOWRIGHT
	b	$84
	mpt	:t1,MENU_ACTION,SetWindows
	mpt	:t2,MENU_ACTION,CloseAll
	mpt	:t3,MENU_ACTION,SelectAll
	mpt	:t4,MENU_ACTION,SelectPage
::t1	b	"plazieren",GOTOX
	w	WINWDOWRIGHT-22
	b	128,BOLDON,"S",PLAINTEXT,0
::t2	b	"alle schlie~en",GOTOX
	w	WINWDOWRIGHT-22
	b	128,BOLDON,"C",PLAINTEXT,0
::t3	b	"Inhalt anw{hlen",GOTOX
	w	WINWDOWRIGHT-22
	b	128,BOLDON,"W",PLAINTEXT,0
::t4	b	"Ausschnitt anw{hlen",GOTOX
	w	WINWDOWRIGHT-22
	b	128,BOLDON,"X",PLAINTEXT,0
:SPCRIGHT	=	267
:Speziell_Men}	lda	#PLAINTEXT
	ldx	RamTopFlag
	beq	:10
	lda	#ITALICON
::10	sta	:t3
	jsr	MySubMenu
	b	13,28+28+14+14+14
	w	174,SPCRIGHT
	b	$86
	mpt	:t1,MENU_ACTION,NeuerOrdner
	mpt	:t2,MENU_ACTION,GetTime
	mpt	:t3,MENU_ACTION,MakeRamTop
	mpt	:t4,MENU_ACTION,Reset
	mpt	AutoSwapFlag,MENU_ACTION,AutoSwap
	mpt	:t5,MENU_ACTION,GoToBasic
;	mpt	:t2,MENU_ACTION,EmptyAllDirs
;	mpt	:t4,MENU_ACTION,SaveWindowStat
::t1	b	"Neuer Ordner",GOTOX
	w	SPCRIGHT-20
	b	128,BOLDON,"O",PLAINTEXT,0
::t2	b	"Uhr stellen",GOTOX
	w	SPCRIGHT-20
	b	128,BOLDON,"A",PLAINTEXT,0
::t3	b	PLAINTEXT,"RamDeskTop",GOTOX
	w	SPCRIGHT-20
	b	128,BOLDON,"L",PLAINTEXT,0
::t4	b	"Reset",GOTOX
	w	SPCRIGHT-20
	b	128,BOLDON,"R",PLAINTEXT,0
::t5	b	"Basic",0
;::t2	b	"Ordner entleeren",0
;::t4	b	"Arbeit sichern",0
:AutoSwapFlag	b	"  autom. Tauschen",0
:CloseAll	jsr	GotoFirstMenu
	lda	#0
	ldx	#3
::loop	sta	windowsOpen,x
	dex
	bpl	:loop
	jsr	ClearMultiFile
	jmp	RedrawAll

:AutoSwap	jsr	GotoFirstMenu
	ldx	#$2a
	lda	AutoSwapFlag
	cmp	#$20
	beq	:10
	ldx	#$20
::10	stx	AutoSwapFlag
	lda	RamTopFlag
	bne	:15
	jsr	SearchDeskTop
	bcc	:20
::15	rts
::20	MoveB	RamTopFlag,$8090	; immer 0, aber egal
	MoveB	AutoSwapFlag,$8091
	MoveW	$8400+19,r1
	LoadW	r4,$8000
	jsr	PutBlock
	rts

.RecoverActiveWindow	ldx	activeWindow
	jsr	GetEqualWindows
	ldx	#3
::loop	lda	a6L,x
	bne	ReloadActiveWindow2
	dex
	bpl	:loop
	ldx	activeWindow
	jsr	ReLoad2
	bcc	:10
	jsr	FehlerAusgabe
::10	jmp	RecoverLast
.ReloadActiveWindow	ldx	activeWindow
	jsr	GetEqualWindows
:ReloadActiveWindow2	ldx	#3
::g20	lda	a6L,x
	bne	:g10
	dex
	bpl	:g20
	jmp	:10	; nur aktives Window aktualisieren
::g10	ldx	#3
::g30	lda	a6L,x
	beq	:g40	; > bei ungleich
	txa
	pha
	jsr	ReLoad2
	bcc	:e10
	jsr	FehlerAusgabe
	pla
	rts
::e10	pla
	tax
::g40	dex
	bpl	:g30
::09	ldx	activeWindow
	jsr	ReLoad2
	bcc	:e20
	jsr	FehlerAusgabe
::e20	jmp	RedrawAll
::10	ldx	activeWindow
	jsr	ReLoad2
	bcc	:e30
	jsr	FehlerAusgabe
::e30	jmp	Redraw
:EndGhost	ldx	#0
	stx	ghostFile
	stx	mouseTop
	pha
	lda	#2
	sta	r3L
	jsr	DisablSprite
	pla
	rts

:GoToBasic	jsr	GotoFirstMenu
	lda	#0
	sta	r5L
	sta	r5H
	sta	$5000
	LoadW	r0,$5000
	lda	c128Flag
	bpl	:10
	lda	#0
	sta	$1c00
	sta	$1c01
	sta	$1c02
	sta	$1c03
	beq	:20
::10	lda	#0
	sta	$800
	sta	$801
	sta	$802
	sta	$803
::20	jmp	ToBasic
.TestTopDesk	lda	c128Flag
	bpl	:11
	lda	graphMode
	bpl	:11
::05	clc
	rts
::11	lda	driveType
	and	#$80
	beq	:05
	lda	driveType+1
	and	#$80
	beq	:05
	ldy	#r15H-r0L
::loop	lda	r0L,y
	pha
	dey
	bpl	:loop
	PushB	curDrive
	LoadB	sysDBData,1
	lda	#8
	jsr	:sub
	txa
	beq	:15
	lda	#9
	jsr	:sub
	txa
	beq	:15
	LoadW	r0,:db
	jsr	NewDoDlgBox
::15	pla
	jsr	SetDevice
	jsr	OpenDisk
	ldy	#0
::loop2	pla
	sta	r0L,y
	iny
	cpy	#r15H-r0L+1
	bne	:loop2
	lda	sysDBData
	cmp	#1
	bne	:20
	clc
	rts
::20	sec
	rts
::sub	jsr	SetDevice
	jsr	OpenDisk
	LoadW	r6,MyName
	jmp	FindFile
::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	OK,2,72,CANCEL,17,72,NULL
::t1	b	"Kein DeskTop auf den",0
::t2	b	"RAM-Disks A und B!",0

.AskDiskFlag	b	$ff
.ReLoadAll	ldy	#3
::loop	lda	windowsOpen,y
	bne	Reset2
	dey
	bpl	:loop
	bmi	ReLoadAll2
:Reset	jsr	GotoFirstMenu
:Reset2	jsr	ClearScreen
.ReLoadAll2	ldx	#03
::10	txa
	pha
	lda	activeWindow,x
	pha
	tax
	lda	windowsOpen,x
	beq	:15
	LoadB	AskDiskFlag,0
	jsr	ReLoad2
	LoadB	AskDiskFlag,$ff
	bcc	:13
	pla
	tax
	lda	#0
	sta	windowsOpen,x
	beq	:17
::13	pla
	pha
	tax
	jsr	DrawWindow
::15	pla
::17	pla
	tax
	dex
	bpl	:10
:Rts	rts

.RedrawHead	lda	#2
	jsr	SetPattern
	jsr	i_Rectangle
	b	0,15
	w	0,319
	jsr	MaxTextWin
	jsr	DoHauptMenu
	lda	#0
	jsr	SetPattern
	jsr	i_Rectangle
	b	1,13
	w	221+DOUBLE_W,237+DOUBLE_W
	lda	#$ff
	jsr	FrameRectangle
	jmp	InitClock

:geos_Men}
	jsr	DA_Init
	txa
	beq	:05
	brk
::05	jsr	MySubMenuDA
.geosoben	b 13
.geosunten	b 28		; wird berechnet!
	w 0,80
.geosanz	b 1		; wird eingesetzt!
	mpt	DeskInfoText,MENU_ACTION,DispInfo
	mpt	SwitchText,MENU_ACTION,Switch
	mpt	DASpace + 0*17,MENU_ACTION,DA_Call
	mpt	DASpace + 1*17,MENU_ACTION,DA_Call
	mpt	DASpace + 2*17,MENU_ACTION,DA_Call
	mpt	DASpace + 3*17,MENU_ACTION,DA_Call
	mpt	DASpace + 4*17,MENU_ACTION,DA_Call
	mpt	DASpace + 5*17,MENU_ACTION,DA_Call
	mpt	DASpace + 6*17,MENU_ACTION,DA_Call
	mpt	DASpace + 7*17,MENU_ACTION,DA_Call
:DeskInfoText	b	"TopDesk Info",0
:SwitchText	b	"switch 40/80",0

:maxDesks	= 8	; maximale Anzahl der angezeigten DA's
:DA_Init	; Erstellung der Liste der DA's
	; der aktuellen Diskette
	LoadB	MyCurRec,0	; da DASpace=$6000
	ldx	activeWindow
	lda	windowsOpen,x
	beq	:l05
	LoadB	AskDiskFlag,0
	jsr	GetAktlDisk
	ldx	#$ff
	stx	AskDiskFlag
	tax
	bne	:l05
::10	ldy	#3
::dloop	lda	:data,y
	sta	r6L,y
	dey
	bpl	:dloop
	LoadW	r10,0	; Keine Class-Angabe
	jsr	FindFTypes
	txa
	beq	:l10
::l05	LoadB	r7H,maxDesks
::l10	lda	#maxDesks	; Anzahl ermitteln
	sec
	sbc	r7H
	clc
	adc	#02	; Men}punktanzahl ermitteln
	sta	a0	; und merken
	ora	#$80
	sta	geosanz	; und speichern
	LoadB	a1,14	; Untere Men}grenze
	ldx	#a0	; berechnen
	ldy	#a1
	jsr	BBMult
	ldx	a0
	inx
	txa		; Ergebnis zur
	clc		; oberen Grenze aufaddieren
	adc	geosoben
	sta	geosunten	; und speichern
	ldx	#0
::err	rts
::data	w	DASpace
	b	DESK_ACC,maxDesks
:DA_Call	; Nummer des Men}punktes in a
	tax
	dex		; minus 2
	dex
	stx	a0L
	jsr	GotoFirstMenu
	LoadB	a1,17
	ldx	#a0
	ldy	#a1
	jsr	BBMult	; mal 17
	lda	a0L
	clc
	adc	#<DASpace	; plus #DASpace
	sta	r6L
	lda	a0H
	adc	#>DASpace
	sta	r6H	; ergibt Filenamen des DA's

	LoadW	r0,Name
	ldx	#r6
	ldy	#r0
	jsr	CopyString
	LoadW	r6,Name
	LoadB	r0L,0
	jsr	StashMain
:DA_Call2	jsr	GetFile	; DA laden und ausf}hren
:DAReturn	txa
	pha
	jsr	SetMyNewMode
	jsr	SetColor
	jsr	RedrawHead
	pla
	tax
	bne	:05
	ldx	activeWindow
	jsr	ReLoad2
	bcc	:10
::05	jsr	FehlerAusgabe
	ldx	#0
	rts
::10	jsr	RedrawAll
	ldx	#0
	rts

.KeyHandler	lda	menuNumber
	beq	:05
	rts
::05	ldy	#0
::10	lda	KeyTab,y
	beq	:20
	cmp	keyData
	beq	:30
	iny
	bne	:10
::20	lda	keyData
	bpl	:25
	and	#$7f
	cmp	#$30
	bcc	:25
	cmp	#$3a
	bcs	:25
	sec
	sbc	#$31
	bpl	:24
	lda	#9
::24	jmp	SelectFileA
::25	rts
::30	tya
	asl
	tay
	lda	KeyServiceTab+1,y
	tax
	lda	KeyServiceTab,y
	jmp	CallRoutine
:ShortCutKey	m
	b	@0+$80
	/
:KeyTab	ShortCutKey	"m"
	ShortCutKey	"d"
	ShortCutKey	"r"
	ShortCutKey	"q"
	ShortCutKey	"v"
	ShortCutKey "s"
	ShortCutKey "n"
	ShortCutKey "f"
	ShortCutKey "e"
	ShortCutKey "z"
	ShortCutKey "h"
	ShortCutKey "k"
	ShortCutKey "p"
	ShortCutKey "o"
	b	1,3,5,14	; F1,F3,F5,F7
	ShortCutKey	1
	ShortCutKey	3
	ShortCutKey	5
	ShortCutKey	14
	ShortCutKey	"w"
	ShortCutKey	"x"
	ShortCutKey	"c"
	ShortCutKey	"l"
	ShortCutKey	"t"
	ShortCutKey	"a"
	b	16,17,8,30	; CRSR
	ShortCutKey	20	; Pfeil nach links - Taste
	ShortCutKey	"b"
	ShortCutKey	"g"
	b	NULL
:KeyServiceTab	w	DeskRename,DeskDelete,Reset,DispFileInfo
	w	DValidate,SetWindows,DeskRelabel,DeskFormat
	w	DeskDosNew,Datei|ffnen,DeskDuplicate,DCopy
	w	PrintService,NeuerOrdner
	w	OpenD8,OpenD9,OpenD10,OpenD11,KS8,KS9,KS10,KS11
	w	SelectAll,SelectPage,CloseAll,MakeRamTop
	w	Ordnen,GetTime
	w	ScrollUp,ScrollDown,ScrollLeft,ScrollRight
	w	CloseService2,BackWindow
	w	SwapSchmal
:ScrollUp	lda	#WN_SCROLL_U
	b	$2c
:ScrollDown	lda	#WN_SCROLL_D
	b	$2c
:ScrollLeft	lda	#WN_SCROLL_L
	b	$2c
:ScrollRight	lda	#WN_SCROLL_R
	sta	messageBuffer
	MoveB	activeWindow,messageBuffer+1
	tax
	lda	windowsOpen,x
	beq	:10
	jmp	Handler
::10	rts

:SelectFileA	pha
	ldy	activeWindow
	lda	windowsOpen,y
	bne	:10
	pla
	rts
::10	sty	messageBuffer+1
	jsr	MyDCFilesSub
	MoveB	r2L,a2L
	MoveW	a5,a3
	pla
	pha
	jsr	GetFileRect
	pla
	tax
	jmp	File_Selected
:BackWindow2	LoadB	messageBuffer,WN_HIDE
	MoveB	activeWindow,messageBuffer+1
	tax
	lda	windowsOpen,x
	beq	:10
	jmp	BackWindow
::10	rts

.TypTab	w	:t0,:t1,:t2,:t3,:t4,:t5,:t6,:t7,:t8,:t9,:ta,:tb,:tc,:td,:te,:tf
::t0	b	"Nicht-GEOS",0
::t1	b	"BASIC",0
::t2	b	"Assembler",0
::t3	b	"Data",0
::t4	b	"Systemdatei",0
::t5	b	"Hilfsprogramm",0
::t6	b	"Anwendung",0
::t7	b	"Dokument",0
::t8	b	"Zeichensatzdatei",0
::t9	b	"Druckertreiber",0
::ta	b	"Eingabetreiber (64)",0
::tb	b	"Directory",0
::tc	b	"Startprogramm",0
::td	b	"Tempor{r",0
::te	b	"selbstausf}hrend",0
::tf	b	"Eingabetreiber (128)",0

.OpenNext	ldx	activeWindow	; eventuell selektierte Files
	lda	windowsOpen,x	; deselektieren
	beq	:05
	stx	messageBuffer+1
	jsr	DispMarking
	jsr	ClearMultiFile
::05	jsr	GetNext	; freie WindowNummer holen
	bcc	:11
	jmp	OpenNext10	; >keine mehr frei
::11	txa
	pha
	jsr	GetDiskName
	txa
	beq	:0xx
	pla
	jmp	FehlerAusgabe
::0xx	ldx	curType
	dex
	bne	:0x1
	lda	curDirHead+3
	bpl	:0x1
	pla
	ldx	#$80
	jmp	FehlerAusgabe
::0x1	pla
	pha
	jsr	GetDiskInfo
	pla
	pha
	tax
	lda	curDrive	; Laufwerk merken
	sta	winDrives,x
	lda	#0
	sta	windowOffs,x
	sta	xOffsL,x
	sta	xOffsH,x
	jsr	GetSubDirXList
	jsr	ClearList
	pla
	tax
:OpenNextNr	lda	#0
	sta	aktl_Sub,x	; aktl Ebene setzen
	txa
	pha
	jsr	ReLoad2
	txa
	beq	:0xx
	pla
	jmp	FehlerAusgabe
::0xx	jsr	GetStartPos
	pla
	pha
	tax
	sec
	jsr	SpeedWinMax
	pla
	tax
	jsr	OpenWindow
	jsr	GetPrefs
	lda	DiskDriverFlag
	bpl	OpenNext10
	lda	MyCurRec
	cmp	#1
	bne	OpenNext10
	jsr	GetDiskDrivers
:OpenNext10	rts

.ReLoad2	jsr	GetWinTabAdr
	pha
	LoadWr0	FILE_ANZ*82
	jsr	ClearRam
	pla
	tax
.ReLoad	; NeuEinladen der Files / Icons
	; Par:	x : WindowNummer (0-3)
	; Ret:	x : Fehlernummer, bei x=0 ist c=0, sonst 1
	txa
	pha
	jsr	GetDisk
	bcc	:f10
	pla
	rts
::f10	pla
	tax
	jsr	GetWinTabAdr
	pha		; ehem. x-Reg. retten
	PushW	r1
	LoadWr0	FILE_ANZ*18
	jsr	ClearRam
	PopW	r3
	pla
	pha
	tax
	lda	aktl_Sub,x	; aktuelles Verzeichnis
	sta	r10L
	lda	windowOffs,x
	sta	r11H	; aktueller Offset
	LoadB	r11L,16	; Anzahl der Files
	LoadB	r12L,%11000000	; gel|schte Files nicht einlesen
	LoadB	r12H,$80	; alle Filetypen
	ldx	#4
	lda	DispMode
	beq	:10
	lda	#0
	sec
	sbc	#<ModStart
	sta	r0L
	lda	CopyMemHigh
	sbc	#>ModStart
	sta	r0H
	LoadW	r1,ModStart
	jsr	ClearRam
	LoadB	MyCurRec,0
	LoadW	r3,ModStart+2
	ldx	#01
	LoadB	r11L,144	; Anzahl der Files korrigieren
	LoadB	r11H,0	; OffSet auf 0 setzen
	lda	#30
	b	$2c
::10	lda	#18
	sta	r13L	; Anzahl der Bytes pro Eintrag
	stx	r13H	; davon x }berlesen
	jsr	FindDirFiles
	txa
	beq	:15
	pla
	cmp	#11	; Puffer}berlauf?
	bne	:14
	ldy	#3
	lda	#0
::14a	sta	windowsOpen,y
	dey
	bpl	:14a
	jsr	FehlerAusgabe
	sec
	rts
::14	sec
	rts
::15	pla
	tax
	lda	r14L
	clc
	adc	windowOffs,x
	sta	fileAnz,x
	lda	#16
	sec
	sbc	r11L
	sta	fileNum,x
	txa
	pha
	jsr	GetDiskInfo
	pla
	pha
	tax
	lda	DispMode
	beq	:20
	lda	windowOffs,x
	jsr	SortFileBuffer
::20	pla
	tax
	lda	DispMode
	sta	winMode,x
	ldx	#0
	clc
	rts
;.Stashdata	w	$6000,$2000,8000
;	b	0
.MainAdr	w 	0

.WindowTab
:Window1	b	15	; y oben
	b	15+90	; y unten
	w	2	; x links
:WR1	w	2+270	; x rechts
	b	$ff	; alle Gadgets
	w	WinName1
	w	Handler
:Window2	b	107	; y oben
	b	107+90	; y unten
	w	2	; x links
:WR2	w	2+270	; x rechts
	b	$ff	; alle Gadgets
	w	WinName2
	w	Handler
:Window3	b	24	; y oben
	b	24+90	; y unten
	w	30	; x links
:WR3	w	30+270	; x rechts
	b	$ff	; alle Gadgets
	w	WinName3
	w	Handler
:Window4	b	44	; y oben
	b	44+90	; y unten
	w	50	; x links
:WR4	w	50+265	; x rechts
	b	$ff	; alle Gadgets
	w	WinName4
	w	Handler
:StartWin	lda	:f
	beq	:10
::05	rts
::10	lda	graphMode
	bpl	:05
	LoadW	WR1,2+270*2
	LoadW	WR2,2+270*2
	LoadW	WR3,30+270*2
	LoadW	WR4,50+265*2
	LoadB	:f,1
	rts
::f	b	0

.FILE_ANZ	= 16	; nicht {ndern !
:MOVE_OFFS	= 60
:WinTabAdr	w	FileTab1,FileTab2,FileTab3,FileTab4
.winDrives	s	4
.windowOffs	s	4
:xOffsL	s	4
:xOffsH	s	4
.fileNum	s	4
.fileAnz	s	4
.aktl_Sub	s	4
.subTab	s	8
:freeAnz	s	8
:maxAnz	s	8
.winMode	s	4
.NameTab	w	WinName1,WinName2,WinName3,WinName4
:WinName1	b	"x:"
	s	78	; Pfadname: "D:Disk/Sub1/Sub2/Sub3"
:WinName2	b	"x:"	; beim "/" bit 7 gesetzt!
	s	78
:WinName3	b	"x:"
	s	78
:WinName4	b	"x:"
	s	78
:SubDirListTabL	b	<SubDir1List,<SubDir2List,<SubDir3List,<SubDir4List
:SubDirListTabH	b	>SubDir1List,>SubDir2List,>SubDir3List,>SubDir4List

.GetDiskName	; Einlesen des Diskettennamens
	; Par:	x: WindowNummer
	; Alt:	WinNameX
	; Des:	a,x,y,diskBlkBuf
	txa
	pha
	jsr	OpenDisk
	txa
	beq	:10
	pla
	rts
::10	pla
	jsr	GetWinName
	lda	curDrive
	clc
	adc	#57
	ldy	#0
	sta	(r1),y
	AddvW	2,r1
	ldy	#00
::20	lda	(r5),y
	cmp	#$a0
	bne	:30
	lda	#$1b
::30	sta	(r1),y
	iny
	cpy	#16
	bne	:20
	lda	#00
	sta	(r1),y
	ldx	#0
	rts

.GetSubName	; Der Name, der in Name steht, wird als Subdirectory-Name im
	; Titelstring des aktuellen Fensters eingetragen
	lda	activeWindow
.GetSubName2	jsr	GetWinName
	lda	#"/"+$80
	sta	(r1),y
	iny
	tya
	clc
	adc	r1L
	sta	r1L
	bcc	:10
	inc	r1H
::10	LoadWr0	Name
	LoadB	r2L,17
	jmp	FormString

.RemSubName	; Der zuletzt im Titelstring des aktuellen Fensters eingetragene SubDir-
	; Name wird entfernt
	lda	activeWindow
	jsr	GetWinName
::10	lda	(r1),y
	cmp	#"/"+$80
	beq	:20
	dey
	bne	:10
	sec
	rts
::20	lda	#0
	sta	(r1),y
	clc
	rts
.PrintDiskInfo	PushW	r0
	ldx	messageBuffer+1
	jsr	GetWorkArea
	bcs	:10
	jsr	RestoreTextWin
::10	SubVW	10,r4
	ldx	r2H
	inx
	inx
	stx	r2L
	txa
	clc
	adc	#8
	sta	r2H
	lda	r3L
	clc
	adc	#10
	sta	r11L
	lda	r3H
	adc	#00
	sta	r11H
	ldx	r2H
	dex
	stx	r1H
	jsr	SetTextWin
	bcs	:21
	lda	messageBuffer+1
	asl
	pha
	tax
	lda	freeAnz,x
	sta	r0L
	lda	freeAnz+1,x
	sta	r0H
	jsr	:sub
	LoadWr0	:t4
	jsr	NewPutString
	pla
	tax
	lda	maxAnz,x
	sec
	sbc	freeAnz,x
	sta	r0L
	lda	maxAnz+1,x
	sbc	freeAnz+1,x
	sta	r0H
	jsr	:sub
	LoadWr0	:t3
	jsr	NewPutString
::20	jsr	RestoreTextWin
::21	PopW	r0
	rts
	; 		==>

::sub	lda	KBytesFlag
	cmp	#" "
	beq	:kbytes
	lda	#%11000000
	jsr	NewPutDecimal
	LoadWr0	:t1
	jmp	NewPutString
::kbytes	lsr	r0H
	ror	r0L
	lsr	r0H
	ror	r0L
	lda	#%11000000
	jsr	NewPutDecimal
	LoadWr0	:t2
	jmp	NewPutString
::t1	b	" Bl|cke",0
::t2	b	" KBytes",0
::t3	b	" belegt ",0
::t4	b	" frei    ",0

:GetAkltDiskInfo	lda	activeWindow
:GetDiskInfo	pha
	LoadW	r5,curDirHead
	jsr	CalcBlksFree
	pla
	asl
	tax
	lda	r4L
	sta	freeAnz,x
	lda	r4H
	sta	freeAnz+1,x
	lda	r3L
	sta	maxAnz,x
	lda	r3H
	sta	maxAnz+1,x
	rts

.NormHandler	; Behandlung der Messages Activate,Close,Restore
	lda	messageBuffer
::20	cmp	#WN_CLOSE
	bne	:40
	jsr	DispMarking
	jsr	ClearMultiFile
	ldx	activeWindow
	lda	winDrives,x
	jsr	SetDevice
	ldx	activeWindow
	jsr	CloseWindow
	jsr	GetZielPos
	ldx	activeWindow
	clc
	jsr	SpeedWinMax	; actives Win. nach Ziel bewegen
	ldy	#00	; n{chstes Window aktivieren
::w10	lda	activeWindow,y
	tax
	lda	windowsOpen,x
	bne	:w15
	iny
	cpy	#4
	bne	:w10
	ldx	#$ff
::w15	txa
	bmi	:w19
	clc
	jmp	FrontWindow
::w19	rts
::40	cmp	#WN_RESTORE
	bne	:99
	jsr	PrintDriveNames
::99	rts

.PrintDriveNames	MoveB	numDrives,a7L
	LoadWr0	University
	jsr	LoadCharSet
	lda	graphMode
	bpl	:40
	jsr	UseSystemFont
::40	dec	a7L
::loop	ldx	a7L
	lda	:data,x
	sta	r1H
	LoadW	r11,(272+16)+DOUBLE_W
	jsr	PutDrive
	dec	a7L
	bpl	:loop
	jsr	i_PutString
	w	5+DOUBLE_W
	b	198,0
	LoadW	r0,PrntFileName
	jsr	NewPutString
	jmp	UseSystemFont
::data	b	55,87,119,151
:PutDrive	; schreibt DriveName
; Par:	x: Index f}r driveType  / r11;r1H f}r NewPutStr
; Ret:	r0 - Zeiger auf den String
	txa
	pha
	lda	driveType,x
	and	#%0000 0011
	tay
	dey
	bne	:10
	LoadB	:ty,"4"
	bne	:30
::10	dey
	bne	:20
	LoadB	:ty,"7"
	bne	:30
	dey
	bne	:30
::20	LoadB	:ty,"8"
::30	lda	driveType,x
	bpl	:40
	lda	#PLAINTEXT
	sta	:nr
	sta	:nr+1
	LoadW	r0,:dr
	SubVB	10,r11L	; nur low, da immer noch }ber 256
	jmp	:50
::40	LoadB	:nr+1,":"
	LoadW	r0,:nr
::50	pla
	ldy	#0
	clc
	adc	#"A"
	sta	(r0),y
	jmp	NewPutString
::dr	b	"x:RAM "
::nr	b	PLAINTEXT,PLAINTEXT,"15"
::ty	b	"41",0

:CheckKlick	; Ermittlung, ob Knopf gehalten oder nicht
	LoadB	dblClickCount,20
::10	lda	dblClickCount
	beq	:30
	lda	mouseData
	bpl	:10
	sec	; Maus-Knopf nicht gehalten
	rts
::30	clc	; Maus-Knopf gehalten
	rts

:Handler	ldx	messageBuffer+1	; File/Icontabellenadresse nach r0
	jsr	GetWinTabAdr
	jsr	MoveWr1r0
	lda	messageBuffer
	cmp	#WN_ACTIVATE
	beq	:002
	cmp	#WN_ACTIVATE2
	bne	:03
	lda	ghostFile
	beq	:002
	bpl	:02
;	clc
;	ldx	messageBuffer+1
;	jsr	FrontWindow
::002	lda	messageBuffer+1
	pha
	MoveB	activeWindow,messageBuffer+1
	jsr	DispMarking
	pla
	sta	messageBuffer+1
	jsr	ClearMultiFile
	jsr	EndGhost
	ldx	messageBuffer+1
	lda	winMode,x
	cmp	DispMode
	beq	:n10
	jsr	ReLoad2
	bcc	:n05
	jmp	FehlerAusgabe
::n05	sec
	bcs	:n20
::n10	clc
::n20	jsr	FrontWindow
	ldx	activeWindow
	lda	winDrives,x
	jmp	NewSetDevice
::02	jmp	MoveService
::03	cmp	#WN_USER
	bne	:03a
	jmp	:10
::03a	jsr	EndGhost
	cmp	#WN_REDRAW
	beq	:05
	cmp	#WN_SCROLL_D
	bne	:03b
	jmp	:30
::03b	cmp	#WN_SCROLL_U
	bne	:03c
	jmp	:50
::03c	cmp	#WN_SCROLL_L
	beq	:06
	cmp	#WN_SCROLL_R
	beq	:08
	cmp	#WN_CLOSE
	bne	:04	
	jmp	CloseService
::04	jmp	NormHandler
::05	jsr	PrintDiskInfo
	ldx	messageBuffer+1
	jsr	GetWorkArea
	bcs	:05a
	jsr	DispSizeRectangle
	jsr	MyDispFiles
	txa
	beq	:05a
	jsr	FehlerAusgabe2
::05a	jmp	MaxTextWin

::06	; Scroll-Links-Bearbeitung
	ldy	#0
	b	$2c
::08	; Scroll-Rechts-Bearbeitung
	ldy	#6
	jsr	CheckKlick
	bcs	:08a
	ldx	messageBuffer+1
	lda	:tab1,y
	sta	xOffsL,x
	iny
	lda	:tab1,y
	sta	xOffsH,x
	iny
	jmp	:09
::08a	iny
	iny
	ldx	messageBuffer+1
	lda	xOffsL,x
	cmp	:tab1,y
	bne	:08a1
	iny
	lda	xOffsH,x
	cmp	:tab1,y
	beq	:09
	dey
::08a1	iny
	iny
	lda	xOffsL,x
	clc
	adc	:tab1,y
	sta	xOffsL,x
	iny
	lda	xOffsH,x
	adc	:tab1,y
	sta	xOffsH,x
::09	jsr	GetWorkArea
	jsr	MyDispFiles
	txa
	beq	:e10
	jsr	FehlerAusgabe2
::e10	rts
::tab1	w	0,(6*MOVE_OFFS),MOVE_OFFS
	w	-(6*MOVE_OFFS),-(6*MOVE_OFFS),-MOVE_OFFS
::10	jsr	MyCheckFiles
	txa
	bmi	:20
	pha
	jsr	MyDCFilesSub
	MoveB	r2L,a2L
	MoveW	a5,a3
	pla
	pha
	jsr	GetFileRect
	pla
	tax
	jmp	File_Selected
::20	jsr	TestCBMKey
	bcs	:25
	jsr	EndGhost
	jsr	DispMarking
	jsr	ClearMultiFile
::25	rts
::30	; Scroll-down-Bearbeitung
	jsr	GetAktlDisk
	bcc	:31
	rts
::31	jsr	CheckKlick
	bcs	:33
	ldx	messageBuffer+1
	lda	fileNum,x
	cmp	#16
	beq	:31a
	rts
::31a	lda	#12
	clc
	adc	windowOffs,x
	sta	windowOffs,x
	PushW	r0
	jsr	MoveWr0r1
	LoadWr0	FILE_ANZ*82
	jsr	ClearRam
	PopW	r0
::33	ldx	messageBuffer+1
	lda	fileNum,x
	cmp	#5
	bcs	:33a
	rts
::33a	PushW	r0
	AddVW	FILE_ANZ*18,r0	; r0>Anfang Icons
	jsr	MoveWr0r1	; r1=r0
	inc	r0H	; r0=r0+4*64
	LoadW	r2,(FILE_ANZ-4)*64
	jsr	MoveData
	PopW	r1
	PushW	r1
	AddVW	FILE_ANZ*18+(FILE_ANZ-4)*64,r1
	LoadWr0	4*64
	jsr	ClearRam
	ldx	messageBuffer+1
	lda	#4
	clc
	adc	windowOffs,x
	sta	windowOffs,x
	sta	r11H
	jsr	GetWorkArea
	ldx	activeWindow
	jsr	ReLoad
	PopW	r0
	jsr	MyDispFiles
	txa
	beq	:e20
	jsr	FehlerAusgabe2
::e20	rts
::50	; Scroll-up-Bearbeitung
	ldx	messageBuffer+1
	lda	windowOffs,x
	bne	:53
	rts
::53	jsr	GetAktlDisk
	bcc	:53a
	rts
::53a	jsr	CheckKlick
	bcs	:54
	ldx	messageBuffer+1
	lda	windowOffs,x
	sec
	sbc	#12
	sta	windowOffs,x
	PushW	r0
	jsr	MoveWr0r1
	LoadWr0	FILE_ANZ*82
	jsr	ClearRam
	PopW	r0
::54	PushW	r0
	AddVW	FILE_ANZ*18,r0	; r0>Anfang Icons
	jsr	MoveWr0r1	; r1=r0
	inc	r1H	; r1=r1+4*64
	LoadW	r2,(FILE_ANZ-4)*64
	jsr	MoveData
	PopW	r1
	PushW	r1
	AddVW	FILE_ANZ*18,r1
	LoadWr0	4*64
	jsr	ClearRam
	ldx	messageBuffer+1	;CheckKlick
	lda	windowOffs,x
	sec
	sbc	#4
	bpl	:55
	lda	#0
::55	sta	windowOffs,x
	sta	r11H
	jsr	GetWorkArea
	ldx	activeWindow
	jsr	ReLoad
	PopW	r0
	jsr	MyDispFiles
	txa
	beq	:e30
	jsr	FehlerAusgabe2
::e30	rts

.MultiFileIcon	b	$03,$18,$00,$bf,$ff,$ff,$ff,$80
	b	$00,$01,$80,$00,$01,$a0,$81,$09
	b	$b1,$81,$41,$aa,$a5,$69,$a4,$a5
	b	$49,$a0,$a5,$49,$a0,$a5,$49,$a0
	b	$9d,$29,$80,$00,$01,$87,$50,$01
	b	$84,$10,$01,$84,$53,$01,$87,$54
	b	$81,$84,$57,$81,$84,$54,$01,$84
	b	$53,$81,$80,$00,$01,$80,$00,$01
	b	$ff,$ff,$ff,$09,$00,$09,$b7
:PrintFlag	b	0
:PrintService
:DateiDrucken	lda	#$ff
	b	$2c
:Datei|ffnen	lda	#0
	sta	PrintFlag
	jsr	GotoFirstMenu
	ldx	MultiCount
	dex
	bmi	:15
	bne	:10
	jsr	DispMarking
	jsr	GetMark
	jsr	GetFileName
	bcs	:15
	jmp	OpenFile
::10	LoadB	DialBoxFlag,0
	LoadWr0	NoMultiFileBox
	jmp	NewDoDlgBox
::15	rts
:NoMultiFileBox	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	$0b,$10,$30
	w	:t3
	b	OK,17,72
	b	NULL
::t1	b	BOLDON,"Diese Operation kann nicht",0
::t2	b	"mit Multi-File ausgef}hrt",0
::t3	b	"werden",0

;SizeRectangle
;Par: r0  - Zahl, die der Maximalgr|~e entspricht
;     r1  - Darzustellende Zahl
;     r2-r4 Rechteck
:DispSizeRectangle	PushW	r0
	lda	messageBuffer+1
	asl
	tax
	lda	maxAnz,x
	sta	r0L
	sec
	sbc	freeAnz,x
	sta	r1L
	lda	maxAnz+1,x
	sta	r0H
	sbc	freeAnz+1,x
	sta	r1H
	lda	r3L
	clc
	adc	#5
	sta	r4L
	lda	r3H
	adc	#00
	sta	r4H
	jsr	SizeRectangle
	PopW	r0
	rts

.DISPSIZE	= $500
.DispJumpTable	s	DISPSIZE
.MyDispFiles	=	DispJumpTable
.DispFiles	=	MyDispFiles+3
.MyCheckFiles	=	DispFiles+3
.CheckFiles	=	MyCheckFiles+3
.GetFileRect	=	CheckFiles+3
.SortFileBuffer	=	GetFileRect+3	; nur im Text-Modus
.GetRealPos	=	SortFileBuffer+3	; nur im Text-Modus

.GetFileName	; Einlesen eines Filenames des aktuellen Fensters
	; Par:	a : Nummer (0-143)
	; Ret:	r0: Adresse (Name)
	; 	c = 1: Name mit Nummer a nicht vorhanden
	; 	(Dir hat weniger als a Files oder Diskettenfehler)
	pha
	jsr	GetAktlDisk
	tax
	beq	:05
	pla
	sec
	rts
::05	pla
	sta	r11H
	LoadB	Name,0
	ldx	activeWindow
	LoadB	r11L,1
	LoadW	r3,Name
	ldy	#3
::dloop	lda	:data,y
	sta	r12L,y
	dey
	bpl	:dloop
	lda	aktl_Sub,x
	sta	r10L
	jsr	FindDirFiles
	lda	Name
	beq	:10
	ldy	#15
::loop	lda	Name,y
	cmp	#$a0
	bne	:f10
	dey
	bpl	:loop
::f10	lda	#0
	sta	Name+1,y
	clc
	rts
::10	sec
	rts
::data	b	%11000000,$80,16,4

:File_Selected	; Auswertung einer File-Selection
	;      x: Nummer des Files in der Darstellung (0-15)
	MoveB	dblClickCount,a9L
	stx	a1L
	ldx	activeWindow
	lda	a1L
	cmp	fileNum,x
	bcc	:002
::001	jsr	EndGhost
	jsr	DispMarking
	jmp	ClearMultiFile
::0015	lda	MultiCount
	cmp	#01
	bne	:001
	jsr	GetIndex
	cmp	MultiFileTab
	beq	:001
	jsr	SwapFile
	jmp	:001
::002	lda	ghostFile
	bne	:0015
	ldx	a1L
	jsr	TestCBMKey
	bcc	:003
	jmp	Multi_Select
::003	lda	a9L	; DoppelKlick ?
	bne	:004	; >ja
	txa
	ldx	activeWindow
	jsr	CheckDispMark
	bcs	:004
	jmp	:p_d_k
::004	jsr	DispMarking
	jsr	ClearMultiFile
	jsr	GetIndex
	pha
	jsr	MarkFile
	jsr	DispMarking
	lda	a9L	; DoppelKlick?
	bne	:020	; >ja
	pla
	sta	:dbl
	LoadB	dblClickCount,20
::112	rts
::dbl	b	0
::020	pla
	cmp	:dbl	; DoppelKlick auf gleichem File?
	bne	:112	; >nein
	lda	a1L
	jsr	GetName2
	LoadB	PrintFlag,0
	jmp	OpenFile
::p_d_k	; Pause-Doppelklick
	lda	DispMode
	beq	:p10
	LoadW	a2,TextSprite+1
	jmp	:p20
::p10	LoadB	a2H,0
	sta	a3H
	lda	a1L
	sta	a2L
	LoadB	a3L,64
	ldx	#a2
	ldy	#a3
	jsr	DMult
	ldx	activeWindow
	jsr	GetWinTabAdr
	AddVW	FILE_ANZ*18+1,r1
	AddW	r1,a2
::p20	LoadB	r3L,2
	MoveW	a2,r4
	lda	MultiCount
	cmp	#1
	beq	:p20a
	LoadW	r4,MultiFileIcon+1
::p20a	ldy	#63
	lda	(r4),y
	pha
	lda	#21
	sta	(r4),y
	jsr	DrawSprite
	jsr	HideOnlyMouse
	pla
	ldy	#63
	sta	(r4),y
	jsr	InitForIO
	jsr	DoneWithIO
	LoadB	ghostFile,1
	jsr	InitForIO
	MoveB	$d027,$d029	; Farbe des Ghost-Sprites von Mauszeiger
	lda	graphMode
	bmi	:g80
::g40	lda	$d01d
	and	#%11111011
	sta	$d01d
	jmp	:gend
::g80	lda	SchmalFlag
	cmp	#"*"
	beq	:g40
	lda	$d01d
	ora	#%100
	sta	$d01d
::gend	jsr	DoneWithIO
	rts

:OpenFile	jsr	ClearMultiFile2
	jsr	MaxTextWin
::04	jsr	GetAktlDisk
	bcc	:05
	rts
::05	LoadB	a7L,0
	jsr	CheckKlick
	bcs	:d10
	LoadB	a7L,1
::d10	jsr	GetSubDirXList
	LoadW	r6,Name
	MoveB	PrintFlag,r1L
	jsr	NewGetFile
	txa
	bne	:10a
	jmp	:10
::10a	cmp	#SUB_DIR
	beq	:10b
	jmp	:15
::10b	lda	a7L
	beq	:w10
	lda	r10L
	sta	OpenNextNr+1
	jsr	GetNext	; freie WindowNummer holen
	bcc	:11
	jmp	:w09	; >keine mehr frei
::11	stx	:new
	lda	#0
	sta	windowOffs,x
	jsr	GetSubDirXList
	ldx	activeWindow
	lda	SubDirListTabL,x
	sta	r1L
	lda	SubDirListTabH,x
	sta	r1H
	ldy	#63
::w05	lda	(r1),y
	sta	(r0),y
	dey
	bpl	:w05
	lda	:new
	jsr	GetWinName
	jsr	MoveWr1r0
	lda	activeWindow
	jsr	GetWinName
::w07	lda	(r1),y
	sta	(r0),y
	dey
	bpl	:w07
	ldx	activeWindow
	ldy	:new
	lda	winDrives,x
	sta	winDrives,y
	tya
	jsr	GetSubName2
	lda	r10L
	sta	OpenNextNr+1
	ldx	activeWindow
	jsr	GetSubDirXList
	jsr	UpperDir
	ldx	:new
	jsr	OpenNextNr
::w08	LoadB	OpenNextNr+1,0
	rts
::w09	ldx	activeWindow
	jsr	GetSubDirXList
	jsr	UpperDir
	LoadB	OpenNextNr+1,0
	rts
::new	b	0
::w10	ldx	activeWindow
	lda	r10L
	sta	aktl_Sub,x
	txa
	pha
	jsr	GetSubName
	pla
	tax
	jsr	NewDirLoad
	txa
	beq	:e10
	jsr	FehlerAusgabe
::e10	; rts
::10
::14	rts
::15	cmp	#14	; INCOMPATIBLE
	bne	:16
	jsr	StashMain
	jsr	TestTopDesk
	bcs	:18
	lda	graphMode
	eor	#$80
	sta	graphMode
	jsr	SetNewMode
	jmp	:04
::16	cpx	#15
	bne	:17
	jsr	SetNumDrives
	jsr	MaxTextWin
	LoadWr0	:db
	jmp	NewDoDlgBox
::17	cpx	#16
	bne	:18
	jsr	SetNumDrives
	jsr	MaxTextWin
	LoadWr0	:db2
	jmp	NewDoDlgBox
::18	; bei x=18 ist auf RAM A und B kein DeskTop gewesen!
	jsr	SetNumDrives
	rts
::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	OK,17,72,NULL
::t1	b	"Dieses Programm ist nur",0
::t2	b	"unter GEOS 64 lauff{hig.",0
::db2	b	$81
	b	$0b,$10,$10
	w	:t1b
	b	$0b,$10,$20
	w	:t2b
	b	OK,17,72,NULL
::t1b	b	"Programmstart von Laufwerk",0
::t2b	b	"C bzw. D nicht m|glich.",0
:activeFile	b	$ff
:Multi_Select	jsr	InvertRectangle
	ldx	activeWindow
	lda	a1L
	jsr	CheckDispMark
	bcc	:10
	tax
	jmp	MarkFile
::10	tax
	jmp	UnMarkFile
:TextSprite	b	$03,$18,$00,$15,$00,$98,$fe,$66
	b	$7f,$80,$00,$01,$80,$00,$01,$80
	b	$00,$01,$80,$00,$01,$80,$00,$01
	b	$80,$00,$01,$fe,$66,$7f,$1b,$00
	b	$09,$b1

:TestCBMKey	jsr	InitForIO
	LoadB	$dc00,$7f
	lda	$dc01
	and	#$20
	pha
	jsr	DoneWithIO
	pla
	clc
	bne	:10
	sec
::10	rts
:GetIndex	ldx	activeWindow
	lda	DispMode
	beq	:110
	lda	a1L
	jsr	GetRealPos
	tax
	jmp	:111
::110	lda	a1L
	clc
	adc	windowOffs,x
	tax
::111	rts

.GetName2	; Kopieren des Namens Nr. a (0-15) des aktuellen Fensters nach Name
	sta	r0L
	LoadB	r0H,0
	LoadW	r1,18
	ldx	#r0
	ldy	#r1
	jsr	DMult
	ldx	activeWindow
	jsr	GetWinTabAdr
	AddW	r1,r0
	LoadW	r1,Name
	LoadB	r2L,17
	jmp	FormString


:CloseService2	LoadB	messageBuffer,WN_CLOSE
	MoveB	activeWindow,messageBuffer+1
	tax
	lda	windowsOpen,x
	bne	CloseService
	rts
:CloseService	jsr	CheckKlick
	bcc	:05
	ldx	messageBuffer+1
	lda	aktl_Sub,x
	bne	:10
::05	lda	activeWindow
	jsr	GetWinName
	lda	#"x"
	ldy	#00
	sta	(r1),y
	jmp	NormHandler
::10	jsr	RemSubName
	ldx	messageBuffer+1
	jsr	GetSubDirXList
	jsr	UpperDir
	sta	aktl_Sub,x
	jsr	NewDirLoad
	txa
	beq	:e10
	jsr	FehlerAusgabe
::e10	rts

.MarkFile	; Markierung eines Files in der Multi-File-Tabelle
	; Par: x: Nummer des Files (0-143)
	ldy	MultiCount
	txa
	sta	MultiFileTab,y
	inc	MultiCount
	jmp	DispMultiCount
.UnMarkFile	; L|schen der Markierung
	; Par: x: Nummer des Files (0-143)
	ldy	#144	; Nummer in MultiFileTab suchen
	txa
::10	cmp	MultiFileTab-1,y
	beq	:20
	dey
	bne	:10
	rts
::20	lda	MultiFileTab,y	; alle folgenden Eintr{ge nachr}cken
	sta	MultiFileTab-1,y
	iny
	cpy	#144
	bne	:20
	LoadB	MultiFileTab+143,$ff
	dec	MultiCount
	jmp	DispMultiCount
.ClearMultiFile2	txa
	pha
	jsr	DispMarking
	pla
	tax
.ClearMultiFile	; x bleibt erhalten !
	ldy	#145
	lda	#$ff
::10	sta	MultiFileTab-1,y
	dey
	bne	:10
	LoadB	MultiCount,0
	jmp	DispMultiCount
.GetMark	; markierte Filenummer holen
	; Ret:	a : Filenummer
	lda	MultiFileTab
	bmi	:10
	pha
	tax
	jsr	UnMarkFile
	ldx	activeWindow
	pla
::10	rts
	t	"DeskMain2"
