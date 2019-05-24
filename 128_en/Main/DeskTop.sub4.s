; Datum: 6.8.91
:curHeight	=	$29
	n	"DeskMod D"
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
;	jmp	FileInfo

; FileBox-Position:
:FIB_OBEN	=	40
:FIB_UNTEN	=	180
:FIB_LINKS	=	70+DOUBLE_W
:FIB_RECHTS	=	250+DOUBLE_W

:FileInfo	jsr	GetAktlDisk
	tax
	beq	:05
	jsr	ClearMultiFile2
	cpx	#12
	beq	:07
	jmp	FehlerAusgabe
::05	ldx	MultiCount
	dex
	bpl	:geht
::07	rts
::geht	LoadW	r2,MultiFileTab
::10	jsr	GetMark
	tax
	bmi	:20
	jsr	GetFileName
	LoadB	DialBoxFlag,2
	jsr	DispThisInfo
	txa
	beq	:10
	jmp	FehlerAusgabe
::20	LoadB	DialBoxFlag,0
	jmp	RecoverLast
:DbText	m	; x,y,adr
	b	$0b,@0,@1
	w	@2
	/

:Text	= fileHeader+$a0
:AlternateFlag	b	0
:DispThisInfo	; File-Info des Files Name darstellen
	LoadW	r6,Name
	jsr	FindFile
	txa
	bne	:err
	PushW	r1
	PushW	r5
	jsr	i_FillRam
	w	$ff,$8100
	b	0
	lda	$8400+22
	beq	:10
	MoveW	$8400+19,r1
	LoadW	r4,$8100
	jsr	GetBlock
	txa
	beq	:10
	PopW	r5
	PopW	r1
::err	rts
::10	LoadW	r0,Name
	jsr	StringLen
	lsr	r1L
	lda	#(FIB_RECHTS-FIB_LINKS)/2-10
	sec
	sbc	r1L
	sta	:titelpos+1	
	LoadW	a1,$8100+77
	LoadW	a3,$8100+97
	LoadW	a4,:ta
	ldx	$8100+70
	beq	:20
	LoadW	a4,:tb
::20	lda	$8400+22
	tay
	lda	AutTab,y
	bne	:22
	LoadW	a3,:tn	; kein Autor anzeigen
::22	tya
	asl
	tay
	lda	TypTab,y
	sta	a2L
	lda	TypTab+1,y
	sta	a2H
	LoadB	AlternateFlag,0
	LoadW	r0,:db
	jsr	NewDoDlgBox
	PopW	r5
	PopW	r1
	ldx	AlternateFlag
	beq	:err2
	ldy	#0
	lda	$8400
	sta	(r5),y
	sta	fileHeader+68
	LoadW	r4,$8000
	jsr	PutBlock
	txa
	bne	:err2
	MoveW	dirEntryBuf+19,r1
	lda	$8400+22
	beq	:err2
	LoadW	r4,fileHeader
	jmp	PutBlock
::err2	rts
::ta	b	"sequential",0
::tb	b	"VLIR"
::tn	b	0

::db	b	$01
	b	FIB_OBEN,FIB_UNTEN
	w	FIB_LINKS,FIB_RECHTS
	DbText	50,10,:boldtext
::titelpos	DbText	70,12,Name
	DbText	10,30,:t1
	DbText	10,40,:t2
	DbText	10,50,:t3
	DbText	10,60,:t7
	DbText	10,70,:t4
	DbText	10,80,:t5
	DbText	60,91,:t6
	b	$0c,55,30,a1	; Klasse
	b	$0c,55,40,a2	; Filetyp
	b	$0c,55,50,a3	; Autor
	b	$0c,55,60,a4	; Struktur
	b	$13
	w	:PutSize
	b	$13
	w	:PutDate
	b	$13
	w	:Layout
	b	17
	w	:Check
	b	$13
	w	EditText
	b	18,21,4
	w	CloseIcon
	b	NULL
::boldtext	b	BOLDON,0
::t1	b	PLAINTEXT,"Class:",0
::t2	b	"Type:",0
::t3	b	"Author:",0
::t4	b	"Date:",0
::t5	b	"size: ",0
::t6	b	"Write protect",BOLDON,0
::t7	b	"structure:",0
::PutSize	MoveW	$8400+28,r0
	LoadW	r11,FIB_LINKS+55
	LoadB	r1H,FIB_OBEN+80
	lda	KBytesFlag
	cmp	#"*"
	beq	:ps10
	lda	r0L
	pha
	lsr	r0H
	ror	r0L
	lsr	r0H
	ror	r0L
	pla
	and	#%0000 0011
	beq	:noround
	inc	r0L
	lda	r0L
	bne	:noround
	inc	r0H
::noround	lda	#%11000000
	jsr	PutDecimal
	LoadW	r0,:KBytes
	jmp	PutString
::ps10	lda	#%11000000
	jsr	PutDecimal
	LoadW	r0,:Blocks
	jmp	PutString
::Blocks	b	" Blocks",0
::KBytes	b	" KByte(s)",0
::PutDate	LoadW	r11,FIB_LINKS+55
	LoadB	r1H,FIB_OBEN+70
	ldy	#0
	sty	a4L
::pd05	lda	:tab1,y
	tay
	lda	$8400,y
	sta	r0L
	LoadB	r0H,0
	ldy	a4L
	lda	:tab3,y
	beq	:pd07
	lda	r0L
	cmp	#10
	bcs	:pd07
	lda	#"0"
	jsr	PutChar
::pd07	lda	#%11000000
	jsr	PutDecimal
	ldy	a4L
	lda	:tab2,y
	beq	:pd10
	jsr	PutChar
	inc	a4L
	ldy	a4L
	bne	:pd05
::pd10	lda	#PLAINTEXT
	jmp	PutChar
::tab1	b	25,24,23,26,27
::tab2	b	".","."," ",":",0
::tab3	b	0,0,1,0,1
::Layout	jsr	i_FrameRectangle
	b	FIB_OBEN+2,FIB_UNTEN-2
	w	FIB_LINKS+2,FIB_RECHTS-2
	b	%11111111
	jsr	i_FrameRectangle
	b	FIB_OBEN+4,FIB_OBEN+16
	w	FIB_LINKS+2,FIB_RECHTS-2
	b	%11111111
	jsr	i_FrameRectangle
	b	FIB_OBEN+85,FIB_OBEN+92
	w	FIB_LINKS+50,FIB_LINKS+57
	b	%11111111
	lda	$8400
	and	#$40
	beq	:l10
	jsr	InvertRectangle
::l10	rts
::Check	lda	mouseData
	bne	:c05
	rts
::c05	LoadB	r2L,FIB_OBEN+85
	LoadB	r2H,FIB_OBEN+92
	LoadW	r3,FIB_LINKS+50
	LoadW	r4,FIB_LINKS+57
	jsr	IsMseInRegion
	beq	:c10
	LoadB	AlternateFlag,$ff
	lda	$8400
	eor	#$40
	sta	$8400
	jmp	InvertRectangle
::c10	rts
:CloseRoutine	jmp	RstrFrmDialog

	t	"EditText"
:AutTab	b	0,1,1,0,1,1,1,0,0,1,1,0,1,0,1,1

:CloseMap	b	$02,$10,$00,$04,$ff,$92,$80,$01
	b	$80,$01,$80,$01,$87,$e1,$87,$e1
	b	$87,$e1,$80,$01,$80,$01,$80,$01
	b	$04,$ff,$86,$00,$00,$08,$00,$10
	b	$00,$04,$0f
:CloseX	= .x
:CloseY	= .y-3

:CloseIcon	w	CloseMap
	b	0,0
	b	CloseX,CloseY
	w	CloseRoutine
