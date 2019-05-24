	n	"DeskMod F"
if .p
	t	"TopSym"
	t	"TopMac
	t	"Sym128.erg"
	t	"CiSym"
	t	"CiMac"
	t	"DeskWindows..ext"
	t	"DeskTop.main.ext"
endif
	o	DispJumpTable
:Start6	jmp	__MyDispFiles
	jmp	__DispFiles
	jmp	__MyCheckFiles
	jmp	__CheckFiles
	jmp	__GetFileRect
	jmp	__SortFileBuffer
	jmp	__GetRealPos

:__MyDispFiles	jsr	MyDCFilesSub
:__DispFiles	; Darstellung von FILE__ANZ Fileintr{gen im Textwindow
	; Par: r0: Zeiger auf File/Icontabelle (Aufbau s. Tabelle)
	;      r3: x-Koordinate
	;      r2L y-Koordinate der linken oberen Ecke der Darstellung
	;      Icon wird ggf. nachgeladen
	;      messageBuffer+1 : WindowNummer
	; Des: a1, a2, a3, a4, a5, a6
	ldx	messageBuffer+1
	lda	winMode,x
	cmp	DispMode
	beq	:0009
	rts
::0009	lda	r0L
	clc
	adc	#<(18*16)
	sta	a6L
	lda	r0H
	adc	#>(18*16)
	sta	a6H
	lda	r2L
	clc
	adc	#2
	sta	r1H
	lda	a5L
	clc
	adc	#10
	sta	a3L
	lda	a5H
	adc	#0
	sta	a3H
	lda	#0
	jsr	SetPattern
	jsr	NewRectangle
	jsr	SetTextWin
	ldx	#16
::05	stx	a2L
	lda	r1H
	pha
	clc
	adc	#10
	sta	r1H
	pla
	cmp	windowBottom
	bcs	:22
	lda	r1H
	cmp	windowTop
	bcc	:22
	MoveW	a3,r11
	ldy	#00
	lda	(r0),y
	beq	:25
::10	lda	(r0),y	; Name ausgeben
	cmp	#$a0
	beq	:20
	sty	a2H
	jsr	SmallPutChar
	ldy	a2H
	iny
	cpy	#16
	bne	:10
::20	jsr	:sub	; weitere Infos ausgeben
::22	AddVW	18,r0
	AddVW	64,a6
	ldx	a2L
	dex
	bne	:05

::25	lda	messageBuffer+1
	cmp	activeWindow
	beq	:e10
	ldx	#0
	rts
::e10	SubVW	6,leftMargin
	jsr	DispMarking
	ldx	#0
	rts
	; Ab der eigentlichen Iconposition ist eingetragen: CBM-Typ, AltNr, Sektor,
	; FileStruktur, GEOS-Filetyp, Jahr, Monat, Tag, Stunde, Minute
::ssub	sta	r11L
	LoadB	r11H,>DOUBLE_W
	ldx	#r11
	jsr	NormalizeX
	lda	a3L
	clc
	adc	r11L
	sta	r11L
	lda	a3H
	adc	r11H
	sta	r11H
	rts
::sub	PushW	r0
	lda	#90
	jsr	:ssub
	ldy	#4
	lda	(a6),y
	asl
	tax
	lda	TypTab,x
	sta	r0L
	lda	TypTab+1,x
	sta	r0H
	jsr	NewPutString
	lda	#170
	jsr	:ssub
	ldy	#7	; Tag
	lda	(a6),y
	jsr	:num
	lda	#"."
	jsr	SmallPutChar
	ldy	#6	; Monat
	lda	(a6),y
	jsr	:num
	lda	#"."
	jsr	SmallPutChar
	ldy	#5	; Jahr
	lda	(a6),y
	jsr	:num2
	lda	#203
	jsr	:ssub
	ldy	#8	; Stunde
	lda	(a6),y
	and	#$7f
	sta	r0L
	LoadB	r0H,0
	lda	#%01000000 + 10
	jsr	NewPutDecimal
	lda	#":"
	jsr	SmallPutChar
	ldy	#9	; Minute
	lda	(a6),y
	jsr	:num2
	lda	#225
	jsr	:ssub
	ldy	#10
	lda	(a6),y
	sta	r0L
	iny
	lda	(a6),y
	sta	r0H
	lda	KBytesFlag
	cmp	#"*"
	beq	:ps10
	PushB	r0L
	lsr	r0H
	ror	r0L
	lsr	r0H
	ror	r0L
	pla
	and	#%0000 0011
	beq	:ps10
	inc	r0L
	lda	r0L
	bne	:ps10
	inc	r0H
::ps10	lda	#%01000000 + 20
	jsr	NewPutDecimal
	PopW	r0
	rts
::num	sta	r0L
	LoadB	r0H,0
	lda	#%11000000
	jmp	NewPutDecimal
::num2	cmp	#10
	bcs	:num
	pha
	lda	#"0"
	jsr	PutChar
	pla
	jmp	:num

:__MyCheckFiles	jsr	MyDCFilesSub
:__CheckFiles	; Auswertung eines Mausklicks innerhalb des Textfenstern im Bezug
	; auf die von DispFiles dargestellten Files
	; Par:	Textfenster (windowTop-RightMargin)
	; 	Mauskoordinaten ($3a-$3c)
	;	r3/r2L linke obere Ecke der Darstellung
	; Ret:	x : Nummer des Eintrags (0-FILE_ANZ, $ff f}r None)
	; 	r2-r4: Rechteck des Icons
	; Des:	a2,a3
	MoveB	r2L,a2L
	MoveW	r3,a3
	lda	#00
::05	jsr	__GetFileRect	; Iconrechteck holen
	bcs	:06	; g}ltig? >nein
	pha
	jsr	IsMseInRegion
	bne	:10
	pla
::06	clc
	adc	#1
	cmp	#FILE_ANZ
	bne	:05
	ldx	#$ff
	rts
::10	pla
	tax
	rts

:__GetFileRect	; Ermittlung des Iconrechtecks eines Files einer DispFile-Darstellung
	; in Bezug auf das Textfenster
	; Par:	Textfenster (windowTop-rightMargin)
	;	a: Nummer des Files (0-(FILE__ANZ-1))
	;	(a2L,a3: linkere oberere Ecke der Darstellung)
	; Ret:	r2-r4: Rechteck-Koordinaten
	; Des:	x,y,r1,...
	pha
	sta	r2L	; Nummer mal 10
	asl
	asl
	asl
	clc
	adc	r2L
	adc	r2L
	adc	windowTop	; plus obere Grenze
	sta	r2L	; gleich obere Grenze
	adc	#9	; plus 9
	sta	r2H	; gleich untere Grenze
	lda	a3L	; linke Grenze = leftMargin+8
	clc
	adc	#8
	sta	r3L
	lda	a3H
	adc	#0
	sta	r3H
	lda	rightMargin	; rechte Grenze = rightMargin-3
	sec
	sbc	#3
	sta	r4L
	lda	rightMargin+1
	sbc	#0
	sta	r4H
	ldy	#5
::20	lda	windowTop,y
	sta	r5L,y
	dey
	bpl	:20
	AddVW	8,r6
	jsr	CutRec
	pla
	rts

:__SortFileBuffer	; Umsortierung der FilenamenListe ab ModStart
	; Kriterium: s. DispMode
	; Par:	a: aktl OffSet
	; 	x: WindowNumer (0-3)
	; Alt:	fileNum,x
	; Ab der eigentlichen Iconposition ist eingetragen: CBM-Typ, AltNr, Sektor,
	; FileStruktur, GEOS-Filetyp, Jahr, Monat, Tag, Stunde, Minute
	; AltNr ist die Position (0-143), die das File auf Disk hat.
	sta	a5L
	stx	a6L
	jsr	GetWinTabAdr	; File/Icontabellenadresse nach r1
	ldx	#143
	LoadW	a4,ModStart+1+143*30+2
	ldy	#0
::110	lda	a4H	; nur innerhalb CopyMem durch-
	cmp	CopyMemHigh	; nummerieren
	bcs	:115
	txa
	sta	(a4),y
::115	SubVW	30,a4
	dex
	bne	:110
	LoadB	ModStart+3,0
::05	LoadB	a1H,>ModStart+2
	LoadB	a3H,>ModStart+32
	LoadB	a1L,<ModStart+2
	LoadB	a3L,<ModStart+32
::10	ldy	#03
	lda	(a3),y
	beq	:durch
	ldx	DispMode
	dex
	beq	:15
	jsr	:sortsub
	bcc	:kleiner
	bcs	:gr|~er
::15	lda	(a3),y
	jsr	:grglkl
	sta	a8L
	lda	(a1),y
	jsr	:grglkl
	cmp	#$a0
	bne	:16
	lda	#$20
::16	cmp	a8L
	bcc	:kleiner
	beq	:gleich
::gr|~er	jsr	SwapEntry
	inc	:chfl
::kleiner	AddVW	30,a1
	AddVW	30,a3
	jmp	:10
::grglkl	cmp	#"A"
	bcc	:grglkl10
	cmp	#"Z"+1
	bcs	:grglkl10
	adc	#$20
::grglkl10	rts
::gleich	iny
	cpy	#19
	bne	:15
	beq	:kleiner
::durch	lda	:chfl
	beq	:d1
	LoadB	:chfl,0
	jmp	:05
::d1	lda	r1L
	clc
	adc	#<FILE_ANZ*18
	sta	r0L
	lda	r1H
	adc	#>FILE_ANZ*18
	sta	r0H
	LoadW	a1,ModStart+2
	LoadB	a5H,0
	LoadW	r2,30
	ldx	#r2
	ldy	#a5
	jsr	DMult	; OffSet mit 30 multiplizieren
	AddW	r2,a1	; und somit <OffSet> Files }berspringen
	LoadB	a5L,0	; Z{hler initialisieren
::005	ldy	#0
	lda	(a1),y
	beq	:040
	ldy	#2	; CBM-Type , Tr & Sc }bertragen
::010	lda	(a1),y
	sta	(r0),y
	dey
	bpl	:010
	AddvW	3,a1
	AddvW	3,r0
	ldy	#17	; Name & InfoPos }bertragen
::020	lda	(a1),y
	sta	(r1),y
	dey
	bpl	:020
	AddvW	18,a1
	AddvW	18,r1
	ldy	#9	; G-Type,Struc,Date,Time,Len }bertragen
::030	lda	(a1),y
	sta	(r0),y
	dey
	bpl	:030
	AddvW	9,a1
	AddvW	61,r0
	inc	a5L
	ldx	#16
	cpx	a5L
	beq	:040
	jmp	:005
::040	lda	a5L
	ldx	a6L
	sta	fileNum,x
	clc
	rts
;	ldx	a6L
;	jmp	GetWorkArea
::chfl	b	0
::sortsub	dex
	beq	:datum
	dex
	beq	:gr|~e
;art
	ldy	#22
	lda	(a1),y
	cmp	(a3),y
	beq	:a10
	rts
::a10	clc
	rts

::gr|~e
	ldy	#28
	sec
	lda	(a1),y
	sbc	(a3),y
	php
	iny
	lda	(a1),y
	sbc	(a3),y
	bmi	:gr1
::gr0	pla
::gr01	clc
	rts
::gr1	pla
::gr11	sec
	rts
::datum
	ldy	#26
	lda	(a3),y
	and	#$7f
	sta	(a3),y
	lda	(a1),y
	and	#$7f
	sta	(a1),y
	ldy	#23
::d10	lda	(a3),y
	cmp	(a1),y
	beq	:dweiter
	rts
::dweiter	iny
	cpy	#28
	bne	:d10
	clc
	rts

:__GetRealPos	; Par: a: FileNummer (0-15)
	; 	x: WindowNumer (0-3)
	; Ret: a: FileNummer (0-143)
	; Des: r0,r1,r2,x,y
	pha
	jsr	GetWinTabAdr	; File/Icontabellenadresse nach r1
	AddVW	16*18,r1
	pla
	sta	r0L
	LoadW	r2,64
	ldx	#r2
	ldy	#r0
	jsr	BMult
	AddW	r2,r1
	ldy	#1
	lda	(r1),y
	rts

:SwapEntry	; a1: Zeiger auf zwei aufeinanderfolgende 30-Byte-Fileeintr{ge,
	; die ausgetauscht werden sollen
	; Ret: a1 unver{ndert
	; Des: a2
	lda	a1L
	clc
	adc	#30
	sta	a2L
	lda	a1H
	adc	#0
	sta	a2H
	ldy	#29
::10	lda	(a1),y
	pha
	lda	(a2),y
	sta	(a1),y
	pla
	sta	(a2),y
	dey
	bpl	:10
	rts
:DispModEnd
if (DISPSIZE-(DispModEnd-DispJumpTable))&$ff00
  DISPSIZE ist zu klein !!!
endif
