	n	"InstallDriveD"
	c	"InstallDriveV1.2"
	a	"Walter Knupe"
	f	14
	z	$40
	i	$03,$15,$00,$bf,$00,$ff,$fe,$01
	i	$00,$06,$02,$7f,$ca,$04,$00,$12
	i	$09,$ff,$22,$10,$00,$42,$20,$00
	i	$82,$40,$01,$04,$ff,$fe,$08,$80
	i	$02,$10,$83,$82,$20,$9f,$f2,$40
	i	$83,$82,$80,$80,$03,$00,$7f,$fc
	i	$00,$00,$80,$00,$60,$00,$18,$52
	i	$a9,$14,$54,$ab,$94,$54,$aa,$14
	i	$64,$91,$98,$09,$bf
if .p
	t	"TopSym"
	t	"TopMac"
	t	"Sym128.erg"
	t	"CiMac"
endif
:DRIVER_LEN	= $d80
:Start	MoveW	$8400+19,MyInfo
	lda	firstBoot
	bmi	:appl
	jsr	TestNumDrives
	jsr	TestRAMDisk
	jsr	LoadDrivers
	MoveW	MyInfo,r1
	LoadW	r4,$8000
	jsr	GetBlock
	ldx	$8086
	beq	:end
	jsr	InstallDriver
::end	jmp	Quit
::appl	lda	c128Flag
	bpl	:40
	lda	graphMode
	bpl	:40
	eor	#$80
	sta	graphMode
	jsr	SetNewMode
::40	lda	#2
	jsr	SetPattern
	jsr	i_Rectangle
	b	0,199
	w	0,319
	jsr	TestNumDrives
	jsr	TestRAMDisk
	jsr	LoadDrivers
	lda	#0
	jsr	SetPattern
	jsr	i_Rectangle
	b	7,98
	w	30,160
	lda	#$ff
	jsr	FrameRectangle
	IncW	r4
	inc	r2H
	lda	#$ff
	jsr	FrameRectangle
	jsr	i_PutString
	w	79
	b	19,BOLDON,"Drive D",GOTOXY,46,0,32,"kein Laufwerk"
	b	GOTOXY,46,0,46,"1541",GOTOXY,46,0,60,"1571"
	b	GOTOXY,46,0,74,"1581",PLAINTEXT,0
	jsr	i_FrameRectangle
	b	24,34
	w	136,154
	b	$ff
	jsr	i_FrameRectangle
	b	38,48
	w	136,154
	b	$ff
	jsr	i_FrameRectangle
	b	52,62
	w	136,154
	b	$ff
	jsr	i_FrameRectangle
	b	66,76
	w	136,154
	b	$ff
	LoadW	r0,Menu
	jsr	DoMenu
	LoadW	otherPressVec,MouseService
	lda	driveType+3
	and	#%11000000
	bne	:error
	ldx	driveType+3
	inx
	stx	ButtonNum
	jmp	DrawButtons
::error	lda	firstBoot
	bpl	:noappl
	LoadW	r0,:db
	jsr	DoDlgBox
::noappl	jmp	EnterDeskTop

::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	$0b,$10,$30
	w	:t3
	b	OK,17,72,NULL
::t1	b	"Laufwerk D kann nicht installiert",0
::t2	b	"werden, da bereits durch RAM-",0
::t3	b	"oder Shadow-Disk belegt.",0
:MyInfo	w	0

:ButtonNum	b	0
:lastButtonNum	b	0
:DrawButtons	lda	#1
	jsr	:sub
	jsr	i_Rectangle
	b	25,33
	w	137,153
	lda	#2
	jsr	:sub
	jsr	i_Rectangle
	b	39,47
	w	137,153
	lda	#3
	jsr	:sub
	jsr	i_Rectangle
	b	53,61
	w	137,153
	lda	#4
	jsr	:sub
	jsr	i_Rectangle
	b	67,75
	w	137,153
	rts
::sub	tax
	lda	#2
	cpx	ButtonNum
	beq	:s10
	lda	#0
::s10	jsr	SetPattern
	rts

:TestNumDrives	lda	driveType+2
	beq	:10
	rts
::10	lda	firstBoot
	bpl	:noappl
	LoadW	r0,:db
	jsr	DoDlgBox
::noappl	jmp	EnterDeskTop
::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	$0b,$10,$30
	w	:t3
	b	$0b,$10,$40
	w	:t4
	b	OK,17,72,NULL
::t1	b	"Zur Installation von Laufwerk D",0
::t2	b	"m}ssen Laufwerk A-C bereits",0
::t3	b	"mit KONFIGUREREN installiert",0
::t4	b	"worden sein.",0

:TestRAMDisk	ldx	#0
::loop	lda	driveType,x
	and	#%10000000
	bne	:ja
	inx
	cpx	#3
	bne	:loop
	beq	:nein
::ja	rts
::nein	lda	firstBoot
	bpl	:noappl
	LoadW	r0,:db
	jsr	DoDlgBox
::noappl	jmp	EnterDeskTop
::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	$0b,$10,$30
	w	:t3
	b	OK,17,72,NULL
::t1	b	"Zur Installation von Laufwerk D",0
::t2	b	"mu~ mindestenes eine RAM-Disk",0
::t3	b	"unter den Laufwerken A-C sein.",0


:LoadDrivers	LoadW	r10,KonfClass
	lda	c128Flag
	bpl	:64
	LoadW	r10,Konf128Class
::64	LoadB	r7L,14
	LoadB	r7H,1
	LoadW	r6,KonfName
	jsr	FindFTypes
	txa
	bne	:err
	lda	r7H
	bne	:err2
	LoadW	r0,KonfName
	jsr	OpenRecordFile
	txa
	beq	:geht
::err2	lda	firstBoot
	bpl	:noappl
	LoadW	r0,:db
	jsr	DoDlgBox
::noappl	jmp	EnterDeskTop
::geht	lda	#2
	jsr	PointRecord
	LoadW	r7,Driver1541Space
	LoadW	r2,-1
	jsr	ReadRecord
	txa
	bne	:err
	jsr	NextRecord
	txa
	bne	:err
	LoadW	r7,Driver1571Space
	LoadW	r2,-1
	jsr	ReadRecord
	txa
	bne	:err
	jsr	NextRecord
	txa
	bne	:err
	LoadW	r7,Driver1581Space
	LoadW	r2,-1
	jsr	ReadRecord
	txa
	bne	:err
	rts
::err	lda	firstBoot
	bpl	:noappl2
	LoadW	r0,:db2
	jsr	DoDlgBox
::noappl2	jmp	EnterDeskTop
::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	OK,17,72,NULL
::t1	b	BOLDON,"KONFIGURIEREN ist nicht",0
::t2	b	"zu finden !",PLAINTEXT,0
::db2	b	$81
	b	$0b,$10,$10
	w	:t3
	b	$0b,$10,$20
	w	:t4
	b	OK,17,72,NULL
::t3	b	"Fehler beim Lesen der ",0
::t4	b	"DiskDriver",0
:KonfClass	b	"Configure",0
:Konf128Class	b	"128 Config",0
:KonfName	s	17

:MouseService	lda	mouseData
	bmi	:10
	rts
::10	LoadW	r0,:data
::loop2	ldy	#0
	lda	(r0),y
	bmi	:weg
	ldy	#6
::loop	lda	(r0),y
	sta	r1H,y
	dey
	bne	:loop
	jsr	IsMseInRegion
	bne	:true
	AddVW	7,r0
	jmp	:loop2
::weg	rts
::true	ldy	#0
	lda	(r0),y
	sta	ButtonNum
	tax
	jsr	InstallDriver
	bcc	:ok
	LoadB	ButtonNum,1	; no drive
::ok	jmp	DrawButtons
::data	b	1,25,33
	w	137,153
	b	2,39,47
	w	137,153
	b	3,53,61
	w	137,153
	b	4,67,75
	w	137,153
	b	$ff

:mpt	m
	w	@0
	b	@1
	w	@2
	/
:Menu	b	0,14
	w	0,29
	b	$01
	mpt	:t1,SUB_MENU,DateiMen}
::t1	b	"Datei",0
:DateiMen}	b	15,15+2*14+1
	w	0,110
	b	$82
	mpt	:t1,MENU_ACTION,SaveConf
	mpt	:t2,MENU_ACTION,Quit
::t1	b	"Konfiguration speichern",0
::t2	b	"verlassen",0

:Quit	lda	sysRAMFlg
	and	#%00100000
	beq	:end
	LoadW	r0,$8400
	LoadW	r1,$7900
	LoadW	r2,$500
	jsr	StashRAM
::end	jmp	EnterDeskTop
:SaveConf	jsr	GotoFirstMenu
	MoveW	MyInfo,r1
	LoadW	r4,$8000
	jsr	GetBlock
	txa
	bne	:10
	MoveB	ButtonNum,$8086
	jmp	PutBlock
::10	rts

:InstallDriver	dex
	bne	:05
	PushB	numDrives
	PushB	curDrive
	LoadB	numDrives,4
	lda	#11
	jsr	SetDevice
	jsr	PurgeTurbo
	pla
	jsr	SetDevice
	PopB	numDrives
::end	lda	#0
	sta	driveType+3
	rts
::05	txa
	pha
	asl
	tax
	lda	DriverTab-2,x
	sta	r0L
	lda	DriverTab-1,x
	sta	r0H
	LoadW	r1,$8300+3*DRIVER_LEN
	LoadW	r2,DRIVER_LEN
	LoadB	r3L,0
	jsr	StashRAM
	pla
	sta	driveType+3
	lda	#$00	
	sta	turboFlags+3
	PushB	numDrives
	LoadB	numDrives,4
	PushB	curDevice
::loop	lda	#11
	jsr	SetDevice
	txa
	bne	:15
	jsr	OpenDisk
	cpx	#13	; Device not found
	bne	:20
::15	lda	firstBoot
	bpl	:noappl
	LoadW	r0,:db
	jsr	DoDlgBox
	lda	r0L
	cmp	#2
	bne	:loop
::noappl	pla
	jsr	SetDevice
	PopB	numDrives
	jsr	:end
	sec
	rts
::20	pla
	jsr	SetDevice
	PopB	numDrives
	clc
	rts
::db	b	$81
	b	$0b,$10,$10
	w	:t1
	b	OK,4,72,CANCEL,17,72,NULL
::t1	b	"Bitte Laufwerk einschalten!",0

:DriverTab	w	Driver1541Space,Driver1571Space,Driver1581Space
:Driver1541Space
:Driver1571Space	= Driver1541Space+DRIVER_LEN
:Driver1581Space	= Driver1571Space+DRIVER_LEN


