:DecW	m
	dec	@0
	lda	@0
	cmp	#$ff
	bne	:10
	dec	@0+1
::10
	/

:IncW	m
	inc	@0
	bne	:10
	inc	@0+1
::10
	/

; AddSW
; Addiert inhalt einer Adresse (Byte)
; zu einem Wortwert
;
:AddSW	m
	lda	@0
	clc
	adc	@1
	sta	@1
	lda	@1+1
	adc	#$00
	sta	@1+1
	/

:SubSW	m
	lda	@1
	sec
	sbc	@0
	sta	@1
	lda	@1+1
	sbc	#$00
	sta	@1+1
	/
:AddvW	m
	lda	#@0
	clc
	adc	@1
	sta	@1
	bcc	:10
	inc	@1+1
::10
	/
:LoadWr0	m
	lda	#<@0
	ldx	#>@0
	jsr	Loadr0AX
	/
