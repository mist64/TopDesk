 	n	"DeskMod H"
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

	jmp	_BackUp
;	jmp	_SetWindows

;:INV_TRACK	= 2

;CopyDisk
; Date: 5.9.1990
; Par:	r6 - Zeiger auf den SourceDiskNamen (mu~ nicht unbedingt eingelegt sein)
; Ret:	x - Fehlernummer
; Des:	alles

:_RTS	rts
:_BackUp	PushW	RecoverVector
	jsr	ClearMultiFile2
	lda	#0
	sta	MyCurRec
	LoadW	RecoverVector,_RTS
	jsr	GetAktlWinDisk
	LoadW	r6,DiskName+2
	jsr	CopyDisk
	PopW	RecoverVector
	txa
	beq	:10
	cmp	#CANCEL_ERR
	beq	:end
	jmp	FehlerAusgabe
::10	ldx	#3
::loop2	stx	a7L
	jsr	GetWinDisk
	ldy	#2
::loop	lda	DestinationName-2,y
;	cmp	#$a0
	beq	:20
	cmp	(r0),y
	bne	:nicht
	iny
	bne	:loop
::20	lda	(r0),y
	cmp	#PLAINTEXT
	beq	:doch
	cmp	#"/"+$80
	beq	:doch
::nicht	ldx	a7L
	dex
	bpl	:loop2
::end	jmp	RedrawAll
::doch	ldx	a7L
	lda	#0
	sta	windowsOpen,x
	beq	:nicht

	t	"DiskCopy"	; mu~ letzte Zeile sein
