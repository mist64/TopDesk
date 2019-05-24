	n	"DeskMod A"
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
	jmp	DeskDosNew
	jmp	_Validate
	rts
	w	0
;	jmp	GetWindowStat
	jmp	GetDDrivers
;:INV_TRACK	=	2

:GetDDrivers	lda	ramExpSize
	beq	:noram
::rts	rts
::noram	lda	c128Flag
	bmi	:rts	; C128 hat seine Driver schon
	lda	driveType
	cmp	driveType+1	; zwei Gleichartige Laufwerke ?
	beq	:rts	; >ja
	lda	driveType
	cmp	curType
	bne	:10
	lda	driveType+1
::10	pha
	jsr	GetDriver	; Treiber nach $7200 laden
	txa
	beq	:20
	LoadB	DiskDriverFlag,$80
::20	pla
	sta	DiskDriverFlag
	rts

:GetDriver	; Par: a - DriveTyp
	pha
	jsr	MaxTextWin
	pla
	pha
	tax
	dex
	bne	:10
	LoadB	DriverType,$34
	bne	:30
::10	dex
	bne	:20
	LoadB	DriverType,$37
	bne	:30
::20	;dex
	;bne	:flash
	LoadB	DriverType,$38
;	bne	:30
::30	LoadW	r6,DriverName
	jsr	FindFile
	txa
	beq	:40
	LoadB	r7L,14	; autoexec
	LoadB	r7H,1
	LoadW	r10,KonfClass
	LoadW	r6,KonfName
	jsr	FindFTypes
	txa
	bne	:34
	lda	r7H
	bne	:34
	LoadW	r6,KonfName
	jsr	FindFile
	txa
	beq	:35
::34	pla
	LoadB	numDrives,1
	tax
	rts
::35	MoveW	$8401,r1
	LoadW	r4,$8000
	jsr	GetBlock
	pla
	asl
	tax
	lda	$8004,x
	sta	r1L
	lda	$8005,x
	sta	r1H
	jmp	:45
::40	pla
	MoveW	$8401,r1
::45	LoadW	r7,$7200
	LoadW	r2,$d90
	jsr	ReadFile
	txa
	bne	:50
	LoadB	CopyMemHigh,$71
	ldx	#0
::50	rts
:DriverName	b	"Drive 15"
:DriverType	b	"x1",0
:KonfClass	b	"Configure",0

:DeskDosNew	jsr	DeskDosSub1
	jsr	DosNew
	ldx	activeWindow
	jsr	GetSubDirXList
	jsr	ClearList
	ldx	activeWindow
	lda	#0
	sta	aktl_Sub,x	; aktl Ebene setzen
::loop	jsr	RemSubName	; alle SubDir-namen entfernen
	bcc	:loop
	LoadB	DialBoxFlag,0
	jmp	RecoverActiveWindow

:DeskDosSub1	LoadB	DialBoxFlag,25	; irgendein Wert, m|glichst hoher Wert
	jsr	GotoFirstMenu
	jsr	GetAktlWinDisk
	LoadW	r6,DiskName+2
	lda	DiskName
	tax
	lda	driveType-65,x
	sta	r7L
	rts

:_Validate	jsr	ClearMultiFile2
	jsr	GetAktlDisk
	tax
	bne	:err
	jsr	Validate
	txa
	beq	:10
::err	cpx	#12
	beq	:10
	jmp	FehlerAusgabe
::10	jmp	ReloadActiveWindow

;DosNew
;l|scht eine Diskette
;Par: r6 - name der Diskette
;Ret: x - Fehlernummer
;Des: a,y,r0-r15
:DosNew
	jsr	SearchDisk
	txa
	bne	:end
	LoadW	r0,:box
	jsr	NewDoDlgBox
	ldy	r0L
	cpy	#CANCEL
	beq	:canceled
	jsr	ClearBAM
	lda	curType
	jsr	Get1stDirBlock
	LoadW	r4,diskBlkBuf
	jsr	EnterTurbo
	txa
	bne	:20
	jsr	InitForIO
::10	jsr	ReadBlock
	txa
	bne	:20
	ldy	#2
::15	lda	#0
	sta	diskBlkBuf,y
	tya
	clc
	adc	#32
	tay
	bcc	:15
	jsr	WriteBlock
	txa
	bne	:20
	lda	diskBlkBuf+1
	sta	r1H
	lda	diskBlkBuf
	sta	r1L
	bne	:10
::20	jsr	DoneWithIO
	jmp	PutDirHead
::canceled	ldx	#CANCEL_ERR
::end	rts
::box	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0c,$10,$20,r6
	b	$0b,$10,$30
	w	:t2	
	b	OK
	b	4,72
	b	CANCEL
	b	17,72
	b	NULL
::t1	b	"Inhalt von",NULL
::t2	b	"l|schen?",NULL

	t	"Validate+Undelet"

if 0
:GetWindowStat	lda	#9
	jsr	SetDevice
	LoadW	r6,StatName
	jsr	FindFile
	txa
	beq	:05
	rts
::05	MoveW	$8401,r1
	LoadW	r7,$6800
	LoadW	r2,$200
	jsr	ReadFile
	ldy	#0
::loop	lda	$6800,y
	sta	SubDir1List,y
	dey
	bne	:loop
;	jsr	i_MoveData
;	w	$6940,windowsOpen,4
	LoadW	a2,$6800+$f0
	LoadW	a3,SubDir4List
	LoadB	a4L,4
	jsr	:sub
	LoadW	a3,SubDir3List
	jsr	:sub
	LoadW	a3,SubDir2List
	jsr	:sub
	LoadW	a3,SubDir1List
	jsr	:sub
	jsr	i_MoveData
	w	$6940+4,WindowTab,6
	jsr	i_MoveData
	w	$6940+4+6,WindowTab+11,6
	jsr	i_MoveData
	w	$6940+4+12,WindowTab+22,6
	jsr	i_MoveData
	w	$6940+4+18,WindowTab+33,6
	jmp	RedrawAll

::sub	; Par:	a2 - DiskName - $10
	; 	a3 - Zeiger auf SubDirXList
	; 	a4L  WindowNummer + 1
	AddVW	$10,a2
	dec	a4L
	ldy	a4L
	lda	$6940,y
	bne	:s05
	rts
::s05	ldy	#16
::loop2	lda	(a2),y
	sta	DiskName,y
	dey
	bpl	:loop2
	LoadW	r6,DiskName
	jsr	SearchDisk
	txa
	bne	:err
	ldx	a4L
	jsr	GetDiskName
	ldy	#1
::loop3	sty	a4H
	lda	(a3),y
	bmi	:endloop
	ldx	a4L
	sta	aktl_Sub,x	; aktl Ebene setzen
	jsr	GetDirName
	txa
	bne	:err
	lda	a4L
	jsr	GetSubName2
	ldy	a4H
	iny
	bne	:loop3
::endloop	ldx	a4L
	jsr	ReLoad2
	ldx	a4L
	jsr	DrawWindowB
	ldx	#0
	rts
::err	inc	53280
	rts
:GetDirName	; Errmitteln eines Directory-Namens
	; Par: a - Nummer
	; Ret: Name
	sta	:num
	jsr	i_FillRam
	w	$0b00,$7000
	b	0
	LoadW	r3,$7000
	ldy	#7
::dloop	lda	:data,y
	sta	r10L,y
	dey
	bpl	:dloop
	jsr	FindDirFiles
	LoadW	a5,$7000
::loop	ldy	#16
	lda	(a5),y
	beq	:endloop
	sta	r1L
	iny
	lda	(a5),y
	sta	r1H
	LoadW	r4,$8000
	jsr	GetBlock
	lda	$8000+OFF_DIR_NUM
	cmp	:num
	beq	:habsie
	AddVW	18,a5
	jmp	:loop
::endloop	ldx	#1
	rts
::habsie	ldy	#0
::hloop	lda	(a5),y
	sta	Name,y
	iny
	cpy	#16
	bne	:hloop
	ldx	#0
	rts
::num	b	0
::data	b	%10000000,0,144,0,%11000000,11,18,4
endif

:KonfName
