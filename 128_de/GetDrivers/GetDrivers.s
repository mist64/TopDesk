	n	"GetDrivers"
	c	"GetDrivers  V1.0"
	a	"Walter Knupe"
	i	$03,$18,$00,$0d,$00,$ab,$ff,$fe
	i	$01,$00,$06,$02,$7f,$ca,$04,$00
	i	$12,$09,$ff,$22,$10,$00,$42,$20
	i	$00,$82,$40,$01,$04,$ff,$fe,$08
	i	$80,$02,$10,$83,$82,$20,$9f,$f2
	i	$40,$83,$82,$80,$80,$03,$00,$7f
	i	$fc,$10,$00,$09,$b1
if .p
	t	"TopSym"
	t	"TopMac"
	t	"Sym128.erg"
	t	"CiMac"
endif
:DRIVER_LEN	= $d80
:Start	lda	#2
	jsr	SetPattern
	jsr	i_Rectangle
	b	0,199
	w	0,319
	jsr	LoadDrivers
	LoadW	r0,Driver1541Space
	lda	#1
	jsr	SaveDriver
	LoadW	r0,Driver1571Space
	lda	#2
	jsr	SaveDriver
	LoadW	r0,Driver1581Space
	lda	#3
	jsr	SaveDriver
	jmp	EnterDeskTop
	t	"SaveDriver.s"

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
::err2	LoadW	r0,:db
	jsr	DoDlgBox
	jmp	EnterDeskTop
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
::err	LoadW	r0,:db2
	jsr	DoDlgBox
	jmp	EnterDeskTop
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

:Driver1541Space
:Driver1571Space	= Driver1541Space+DRIVER_LEN
:Driver1581Space	= Driver1571Space+DRIVER_LEN

