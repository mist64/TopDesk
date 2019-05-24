	n	"DeskMod I"
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
	jmp	NeuerOrdner
	jmp	_CopyDir
;	jmp	_DeleteDir

:NeuerOrdner	jsr	GotoFirstMenu
	jsr	ClearMultiFile2
	jsr	GetAktlDisk
	tax
	bne	:17
	LoadB	DialBoxFlag,2
	LoadW	r0,:db
	LoadW	a1,Name
	LoadB	Name,0
	jsr	NewDoDlgBox
	lda	r0L
	cmp	#02
	beq	:20
	lda	Name
	beq	:20
	ldx	activeWindow
	jsr	MyNewSubDir
	txa
	beq	:19
::17	cpx	#12
	beq	:18
	jmp	FehlerAusgabe
::18	rts
::19	LoadB	DialBoxFlag,0
	jsr	MaxTextWin
	jmp	RecoverActiveWindow
::20	LoadB	DialBoxFlag,0
	jsr	MaxTextWin
	jmp	RecoverLast
::db	b	$81
	b	$02,17,72	; Abbruch-Box
	b	$0b,$10,$10	; Textausgabe
	w	:t
	b	$0d,$10,$20	; Texteingabe
	b	a1,16
	b	NULL
::t	b	BOLDON,"Enter new name for folder:",PLAINTEXT,0
:MyNewSubDir	; Par: Filename in Name
	;      Windownummer in x
	txa
	pha
	LoadW	r0,subTab
	LoadW	r3,ModEnd
	jsr	MakeDirList
::10	LoadW	r1,Name
	jsr	MakeDir
	txa
	bne	:err
	pla
	tax
	lda	aktl_Sub,x
	sta	r10L
	LoadW	r6,Name
	jmp	MoveFileInDir
::err	pla
	rts

; MakeDirList
; erstellt eine Liste mit den vorhandenen Verzeichnissen
; Maximal sind 64 Verzeichnisse (= 8 Byte) m|glich
; Parameter
; r0   - Zeiger auf 8 Bytes, wo die Verzeichnisse
;        abgelegt werden k|nnen.
; r3   - Zeiger auf einen 128 Byte-Buffer f}r 
;        Track-Sektor-Liste
; Returns
; x = 0   No Error
; Destroys
; a,y, r1,r5,r15
:MakeDirList
	ldy	#7
	lda	#00
::5	sta	(r0),y
	dey
	bne	:5
	lda	#1
	sta	(r0),y
	PushW	r0
;	LoadW	r3,$6000
	ldy	#127
	lda	#0
::10	sta	(r3),y
	dey
	bpl	:10
	sta	r11H
	lda	#%1100 0000
	sta	r10L
	sta	r12L
	LoadB	r12H,DIRECTORY
	LoadB	r11L,64
	LoadB	r13L,2
	LoadB	r13H,20
	PushW	r3
	jsr	FindDirFiles
	PopW	r3
	PopW	r0
	txa
	bne	:error
	LoadW	r4,diskBlkBuf
	ldy	#0
::100	lda	(r3),y	;$6000,y
	sta	r1L
	beq	:end
	iny
	lda	(r3),y	;$6000,y
	sta	r1H
	iny
	tya
	pha
	jsr	GetBlock
	pla
	tay
	txa
	bne	:error
	tya
	pha
	ldy	#OFF_DIR_NUM
	lda	diskBlkBuf,y
	jsr	PutInList
	pla
	tay
	jmp	:100
::end	ldx	#0
::error	rts

; MakeDir
; erstellt ein Verzeichnis 
;
; Parameter
; r0   - Zeiger auf DirList
; r1   - Zeiger auf Filenamen
; r10L - Nummer des aufrufenden Verzeichnisses
;
; Returns
; x = 0 No Error
;       FILE_EXISTS
;       NO_DIR_FREE
;
; Destroys
; r0 - r10L,r14,r15
; a,y
;

:MakeDir
	jsr	NextFreeDirNum
	sta	IntBlock+OFF_DIR_NUM
	txa
	bne	:1000
	MoveW	r1,IntBlock
	MoveW	r1,r6
	jsr	FindFile
	txa
	bne	:1
	ldx	#FILE_EXISTS
	rts
::1	MoveW	r0,r14
	LoadW	r9,IntBlock
	LoadB	r10L,1
	jsr	SaveFile
::1000	rts

; NextFreeDirNum
; holt n{chste freie Directory-Nummer aus 
; interner Verzeichnislist, die mit MakeDirList
; erstellt wurde
; NextFreeDirNum kennzeichnet nicht (!) den n{chsten
; Eintrag als belegt.
;
; Parameter
; r0   - Zeiger auf Liste
;
; Returns
; x = 0 No Error oder x = NO_DIR_FREE
; a = freie Dir-Nummer
;
; Destroys
; y,a

:NextFreeDirNum
	ldx	#$07
	ldy	#$00
	sty	merky
::10	lda	(r0),y
::20	lsr
	bcc	:100
	inc	merky
	dex
	bpl	:20
	ldx	#7
	iny
	cpy	#8
	bne	:10
	ldx	#NO_DIR_FREE
	rts
::100	ldx	#$00
	lda	merky
	rts

; PutInList
; Belegteintrag setzen
; 
; Parameter
; a      - Directorynummer
; r0     - Zeiger auf Directoryliste
;
; Destroys
; a,y
;
; uses
; - merky
;

:PutInList
;	ldy	#$00
	pha
;	lda	(r15),y
	and	#%00000111
	tay
	lda	#$01
	cpy	#0
	beq	:100
::10	asl
	dey
	bne	:10
::100	sta	merky
	pla
;	lda	(r15),y	; y = 0 !!
	and	#%00111000
	lsr
	lsr
	lsr
	tay
	lda	(r0),y
	ora	merky
	sta	(r0),y
	rts
:merky	b	0

;CopyDir
;Par: diskName+2  - Diskname Source
;     Name2+2  - Diskname Dest.
;     Name - Name des Ordners als String
;Des: $6000-$7fff,r14,fileWritten
:_CopyDir	inc	ModDepth
	LoadB	CopyMemLow,>ModEnd+$100
	LoadW	r6,DiskName+2
	jsr	SearchDisk
	LoadW	r6,Name
	jsr	FindFile
	txa
	bne	:err2
	MoveW	$8400+19,r1	; Source-Ordnernummer holen
	LoadW	r4,$8000
	jsr	GetBlock
	txa
::err2	bne	:err3
	lda	$8000+OFF_DIR_NUM
	sta	:src
	LoadW	r6,Name2+2
	jsr	SearchDisk
	txa
::err3	bne	:err4
	ldx	messageBuffer+1
	jsr	MyNewSubDir
	txa
::err4	bne	:err5
	LoadW	r6,Name	; Zielordnernummer holen
	jsr	FindFile
	txa
::err5	bne	:err6
	MoveW	$8400+19,r1
	LoadW	r4,$8000
	jsr	GetBlock
	txa
::err6	bne	:err7
	lda	$8000+OFF_DIR_NUM
	sta	:dest
	LoadW	r6,DiskName+2
	jsr	SearchDisk
	txa
::err7	bne	:err
	LoadB	:num,0	; aktl. Filenummer setzen
::loop	ldx	activeWindow
	lda	aktl_Sub,x
	pha
	lda	:src
	sta	aktl_Sub,x
	ldx	messageBuffer+1
	lda	aktl_Sub,x
	pha
	lda	:dest
	sta	aktl_Sub,x
	PushB	:num
	jsr	CopyService
	tay
	php
	pla
	sta	:s
	PopB	:num
	ldx	messageBuffer+1
	lda	aktl_Sub,x
	sta	:dest
	pla
	sta	aktl_Sub,x
	ldx	activeWindow
	lda	aktl_Sub,x
	sta	:src
	pla
	sta	aktl_Sub,x
	lda	:s
	pha
	plp
	bcs	:ende1
	inc	:num
	bne	:loop
::ende1	tya
	bpl	:ende
	clc
	bcc	:ende
::err	jsr	FehlerAusgabe
	sec
::ende	dec	ModDepth
	rts
::src	b	0
::dest	b	0
::num	b	0
::s	b	0


:IntBlock
	w	0
	b	3,21
	b	$03,$15,$00,$bf,$00,$01,$fe,$00
	b	$02,$01,$3f,$fe,$01,$40,$00,$01
	b	$40,$00,$01,$7f,$ff,$fd,$80,$00
	b	$03,$80,$00,$03,$80,$00,$03,$80
	b	$00,$03,$80,$00,$03,$80,$00,$03
	b	$80,$00,$03,$80,$00,$03,$80,$00
	b	$03,$80,$00,$03,$80,$00,$03,$80
	b	$00,$03,$80,$00,$03,$80,$00,$02
	b	$7f,$ff,$fc,$09,$bf
	b	$83	; PRG
	b	DIRECTORY
	b	SEQUENTIAL
	w	0
	w	0
	w	0
	b	"Directory   V1.0",0
	b	0,0,0
	b	"DPT-Team",0,0,0,0,0,0,0,0,0,0,0,0
	b	0
:ModEnd

