	n	"DeskMod B"
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
;	jmp	SelectPage
	nop
	nop
	nop
	jmp	EmptyAllDirs
	jmp	DispInfo
	jmp	Rename
	jmp	Duplicate
;	jmp	SelectAll

:DispInfo	LoadW	r0,:db
	jmp	NewDoDlgBox
::db	b	$01
	b	32,138
	w	54,265
	b	$0b,$10,$10
	w	:t1
	b	$0b,$10,$20
	w	:t2
	b	$0b,$10,$30
	w	:t3
	b	$0b,$10,$30+10
	w	:t4
	b	$0b,$10,$30+20
	w	:t5
	b	$0b,$0a,$5e
	w	:t7
	b	$0e,NULL
::t1	b	BOLDON,"TopDesk",PLAINTEXT," Version 1.2",0
::t2	b	"geschrieben von",BOLDON,0
::t3	b	"Walter Knupe",0
::t4	b	"H.J. Ciprina",0
::t5	b	"Volker Goehrke",PLAINTEXT,0
::t7	b	"(C) 1991 by GEOS-USER-CLUB, GbR",0


:EmptyAllDirs	rts
if 0
	jsr	GotoFirstMenu
	jsr	GetAktlDisk
::05	lda	curDirHead
	bne	:10
	jsr	GetDirHead
	jmp	ReLoadAll
::10	sta	r1L
	MoveB	curDirHead+1,r1H
	LoadW	r4,$8000
	jsr	GetBlock
	lda	#00
	sta	$8020
	ldy	#$21
::20	lda	#00
	sta	$8000,y
	tya
	clc
	adc	#$20
	bcs	:30
	tay
	bne	:20
::30	jsr	PutBlock
	MoveW	$8000,curDirHead
	jmp	:05
endif

:RenameFlag	b	0
:Duplicate	ldx	MultiCount
	dex
	bpl	:geht
	rts
::geht	lda	#$ff
	bne	RenameDupl
:Rename	ldx	MultiCount
	dex
	bpl	:geht
	rts
::geht	lda	#0
:RenameDupl	sta	RenameFlag
	jsr	GetAktlDisk
	tax
	beq	:05
	jsr	ClearMultiFile2
	cpx	#12
	beq	:15
	jmp	FehlerAusgabe
::05	LoadW	r2,MultiFileTab
::10	jsr	GetMark
	tax
	bmi	:20
	jsr	GetFileName
	jsr	MyRename
	bcc	:10
::15	rts
::20	LoadB	DialBoxFlag,0
	jmp	RecoverActiveWindow

:MyRename	lda	RenameFlag
	beq	:05
	LoadW	r6,Name
	jsr	FindFile
	txa
	bne	:err
	lda	$8400+22
	cmp	#11	; Directory
	bne	:05
	ldx	#10
	bne	:err
::05	LoadB	:t2,0
	ldy	#0
::10	lda	Name,y
	sta	Name2,y
	beq	:20
	iny
	bne	:10
::20	LoadB	DialBoxFlag,2
	LoadW	a1,Name2
	LoadW	r0,:db
	jsr	NewDoDlgBox
	lda	r0L
	cmp	#2
	bne	:22
	clc
	rts
::22	LoadW	r6,Name2
	jsr	FindFile
	txa
	beq	:schonda
	cpx	#5
	beq	:geht
::err	jsr	FehlerAusgabe
	sec
	rts
::schonda	LoadB	:t2,BOLDON
	bne	:20
::geht	lda	RenameFlag
	beq	:25
	LoadW	r12,Name	; Filename
	LoadW	r10,DiskName+2	; SourceDisk (ohne 'x:')
	MoveW	r10,r11
	LoadW	r13,Name2	; NewFilename 
	ldx	messageBuffer+1
	lda	aktl_Sub,x
	sta	DestinationDir	; Ziel-Dir setzen
	PushB	CopyMemLow
	LoadB	CopyMemLow,DuplCopyMem
	jsr	CopyFile
	PopB	CopyMemLow
	txa
	bne	:err
	clc
	rts
::25	LoadW	r0,Name2
	LoadW	r6,Name
	jsr	RenameFile
	txa
	beq	:30
	jmp	:err
::30	clc
	rts
::db	b	$81
	b	$0b,$10,$10
	w	:t2
	b	$0b,$10,$20
	w	:t1
	b	$0d,$10,$35,a1,16
	b	$02,17,72
	b	NULL
::t1	b	"Neuen Filenamen eingeben:",0
::t2	b	0,"Name schon vergeben!",PLAINTEXT,0

:ModEnde
:DuplCopyMem	= >ModEnde+$100
