\ structure word set

\ ( s-offset -- s-offset )
: begin-structure
;

\ ( s-offset size "name" -- s-offset' ) ; ( -- s-offset )
: +field
	create
		over , +
	does>
		@
;

\ ( s-offset "name" -- s-offset' ) ; ( -- s-offset )
: cfield
	1 chars +field
;

\ ( s-offset "name" -- s-offset' ) ; ( -- s-offset )
: field
	aligned 1 cells +field
;

\ ( s-offset "name" -- ) ; ( -- s-size )
: end-structure
	create
		,
	does>
		@
;

\ ( s-addr "name" -- f-addr )
: >field
	' execute
	state @
	if
		+immed,
	else
		+
	then
; immediate

\ ( s-addr "name" -- u )
: @field
	' execute
	state @
	if
		@immed,
	else
		+ @
	then
; immediate

\ ( u s-addr "name" -- )
: !field
	' execute
	state @
	if
		!immed,
	else
		+ !
	then
; immediate
