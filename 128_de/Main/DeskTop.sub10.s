	n	"DeskMod J"
if .p
	t	"TopSym"
	t	"TopMac"
	t	"Sym128.erg"
	t	"CiSym"
	t	"CiMac"
	t	"DeskWindows..ext"
	t	"DeskTop.main.ext"
endif
	o	ModStart
	jmp	MakeRamTop
	jmp	LoadRest
	jmp	StashMain

:MakeRamTop	lda	RamTopFlag
	beq	:geht
	ldy	#6
::dl	lda	:dd,y
	sta	r0L,y
	dey
	bpl	:dl
	jsr	StashRAM
	lda	curDrive
	and	#%00001101
	jsr	SetDevice
	LoadW	$88ee,$ffa0	; DrDCurDkNm
	jmp	EnterDeskTop
::dd	w	$0400,$0400,$3900-$400	; MoveData-Bereich einfach
	b	0	; ]berschreiben
::gehtnicht	ldx	#13
	rts
::geht	lda	ramExpSize
	beq	:gehtnicht
	LoadB	RamTopFlag,1
	jsr	SearchDeskTop
	bcc	:10
	rts
::10	MoveB	RamTopFlag,$8090
	MoveW	$8400+19,r1
	LoadW	r4,$8000
	jsr	PutBlock
	LoadWr0	MyName
	jsr	OpenRecordFile
	lda	#1
	jsr	PointRecord
	LoadW	a0,$0420
	LoadB	a1L,0
::loop	LoadW	r7,DataSpace
	LoadW	r2,$2000
	jsr	ReadRecord
	SubVW	DataSpace,r7
	LoadW	r0,DataSpace
	MoveW	a0,r1
	MoveW	r7,r2
	LoadB	r3L,0
	jsr	StashRAM
	jsr	:stashadr
	AddW	r7,a0
	jsr	NextRecord
	txa
	beq	:loop
	jsr	:stashadr
	MoveB	a0L,StashMainAdr
	sta	MainAdr
	MoveB	a0H,StashMainAdr+1
	sta	MainAdr+1
	ldy	#6
::dloop	lda	:data,y
	sta	r0L,y
	dey
	bpl	:dloop
	jsr	StashRAM
	lda	sysRAMFlg	; REU-MoveData ausschalten
	and	#$7f
	sta	sysRAMFlg
	jsr	i_MoveData
	w	NewGetModule,SearchDeskTop,NewGetModuleEnd-NewGetModule
	jmp	StashMain
::stashadr	ldy	a1L
	lda	a0L
	sta	ModTab,y
	iny
	lda	a0H
	sta	ModTab,y
	iny
	sty	a1L
	rts
::data	w	StashMainAdr,$0400,$1e
	b	0
:StashMainAdr	w	0
:ModTab	w	0,0,0,0,0,0,0,0,0,0,0,0



	;  NewGetModule mu~ positionsunabh{ngig sein!
:NewGetModule	rts	; f}r SearchDeskTop-Einsprung
	nop
	nop
	; Par: a - Modulnummer
	; Ret: r7 - Adresse des letzten geladenen Byte +1
	cmp	MyCurRec	; eigentlicher GetModule-Einsprung
	bne	:nichtmehrda
	clc
	rts
::nichtmehrda	sta	MyCurRec
	pha
	MoveW	ModStartAdress,r0
	LoadW	r1,$0400
	LoadB	r2L,$1e
	LoadB	r2H,0
	sta	r3L
	jsr	FetchRAM
	pla
	asl
	tay
	lda	(r0),y
	sta	r1L
	iny
	lda	(r0),y
	sta	r1H
	iny
	lda	(r0),y
	sec
	sbc	r1L
	sta	r2L
	iny
	lda	(r0),y
	sbc	r1H
	sta	r2H
;	MoveW	ModStartAdress,r0	; noch gesetzt
;	LoadB	r3L,0
	jsr	FetchRAM
	lda	r0L
	clc
	adc	r2L
	sta	r7L
	lda	r0H
	clc
	adc	r2H
	sta	r7H
	clc
	rts
:NewGetModuleEnd

:SearchRAMDisk	ldy	#8	; SearchRAMDisk + 2 = :loop !!
::loop	lda	driveType-8,y
	beq	:keinsda
	bmi	:habeins
	iny
	bne	:loop
::keinsda	ldx	#13	; DEV_NOT_FOUND
	rts
::habeins	tya
	jsr	NewSetDevice
	jmp	OpenDisk
:StashMain	LoadB	r2H,$78
	lda	c128Flag
	bpl	:64
	LoadB	r2H,$38
::64	LoadB	r2L,$ff
	MoveW	MainAdr,r1
	LoadW	r0,$400
	SubW	r1,r2
	MoveW	r1,TopMainAnf
	MoveW	r2,TopMainLen
	LoadW	r1,$100
	LoadW	r0,RamStart
	jsr	CRC
	MoveW	r2,Pr}fSumme
	LoadW	r0,$400
	MoveW	TopMainAnf,r1
	MoveW	TopMainLen,r2
	jsr	StashRAM
	PushB	curDrive
	jsr	SearchRAMDisk
	txa
	beq	:05
	jmp	:gehtnicht
::d	b	0
::05	LoadB	:d,0
	LoadW	r6,MyName
	jsr	FindFile
	txa
	bne	:06
	lda	r5L
	cmp	#2
	beq	:05a
	DecW	r5
	jmp	:05b
::05a	AddVW	$1e,r5
::05b	ldy	#0
	lda	(r5),y
	sta	:d
	LoadW	r6,MyName
	LoadB	r10L,0
	jsr	MoveFileInDir
	LoadW	r0,MyName
	jsr	DeleteFile
::06	LoadW	r9,TopInfo
	LoadB	r10L,0
	jsr	SaveFile
	txa
	beq	:ne1
	jmp	:err
::err2	jsr	CloseRecordFile
::err	LoadW	r6,MyName
	LoadB	r10L,0
	jsr	MoveFileInDir
	LoadW	r0,MyName
	jsr	DeleteFile
	ldy	curDrive
	iny
	jsr	SearchRAMDisk+2
	txa
	bne	:ne0
	jmp	:05
::ne0	jmp	:gehtnicht
::ne1	LoadW	r6,MyName
	MoveB	:d,r10L
	jsr	MoveFileInDir
	LoadW	r0,MyName
	jsr	OpenRecordFile
	jsr	AppendRecord
	LoadW	r7,NewEDT128
	LoadW	r2,NewEDT128Len
	jsr	WriteRecord
	txa
::err1	bne	:err2
	jsr	AppendRecord
	MoveB	TopMainLen,r7L	; LadeAdr = Stashl{nge + $400
	lda	TopMainLen+1
	clc
	adc	#4
	sta	r7H
	PushW	r7
	lda	#<FileTab1
	sec
	sbc	r7L
	sta	r2L
	lda	#>FileTab1
	sbc	r7H
	sta	r2H
	bmi	:10	; kein 2. Datensatz erzeugen
	jsr	WriteRecord
	txa
	beq	:10
	pla
	pla
	jmp	:err1
::10	jsr	CloseRecordFile
	MoveW	$8400+19,r1
	LoadW	r4,$8000
	jsr	GetBlock
	LoadB	$8047,<NewEDT128
	sta	$804b
	LoadB	$8048,>NewEDT128
	sta	$804c
	LoadB	$8060,$40	; lauff{hig unter Geos 64 u. 128 (40/80)
	lda	#0
	sta	$8061	; kein Autor
	sta	$80a0	; kein Infotext
	PopW	$8086	; Ladeadresse 2. Datensatz
	jsr	PutBlock
::gehtnicht	stx	:x
	pla
	jsr	NewSetDevice
::20	ldy	#r15-2
::loop	lda	RegBuf,y
	sta	r0L,y
	dey
	bpl	:loop
	ldx	:x
	rts
::x	b	0

:TopInfo	w	MyName
	b	3,21
	b	$03,$18,$00,$bf,$ff,$ff,$ff,$80
	b	$00,$01,$80,$00,$01,$80,$00,$01
	b	$80,$00,$01,$80,$00,$01,$9c,$22
	b	$09,$92,$53,$19,$92,$8a,$a9,$92
	b	$8a,$49,$9c,$fa,$09,$94,$8a,$09
	b	$92,$8a,$09,$80,$00,$01,$80,$00
	b	$01,$80,$00,$01,$80,$00,$01,$80
	b	$00,$01,$80,$00,$01,$80,$00,$01
	b	$ff,$ff,$ff,$09,$00
	b	$83,6,1
	w	0,0,0
	b	"TopDeskTemp V1.0",0

:LoadRest	LoadW	r6,MyName
	jsr	FindFile
	txa
	beq	:10
	rts	; Load NormTopDesk
::10	MoveW	$8400+19,r1
	LoadW	r4,$8100
	jsr	GetBlock
	PushW	$8186
	LoadW	r0,MyName
	jsr	OpenRecordFile
	jsr	NextRecord
	PopW	r7
	LoadW	r2,-1
	jsr	ReadRecord
	jmp	Start


:NewEDT128
::05	ldx	#6
::loop2	lda	TopData,x
	sta	r0L,x
	dex
	bpl	:loop2
	jsr	FetchRAM
	txa
	bne	:NormTop
	LoadW	r1,$100
	LoadW	r0,RamStart
	jsr	CRC
	CmpW	r2,Pr}fSumme
	bne	:NormTop
::10	jmp	RamStart
::name	s	17
::NormTop	ldy	#0
::loop	lda	$8400+3,y
	cmp	#$0a
	beq	:03
	sta	:name,y
	iny
	cpy	#16
	bne	:loop
::03	lda	#0
	sta	:name,y
	LoadW	r0,:name
	jsr	DeleteFile
	LoadW	$88ee,$ffa0	; DrDCurDkNm
	jmp	EnterDeskTop
:TopData	w	$0400
:TopMainAnf	w	0
:TopMainLen	w	0
	b	0
:NewEDT128End
:NewEDT128Len	= NewEDT128End-NewEDT128

:DataSpace
