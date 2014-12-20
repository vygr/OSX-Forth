\ mini oof words

\ root object class
create object-class 1 cells , 2 cells ,

\ ( class -- class m-offset s-offset)
: begin-class
	dup 2@
;

\ ( m-offset s-offset "name" -- m-offset' s-offset ) ; ( -- m-offset )
: method
	create
		over , swap cell+ swap
	does>
		@
;

\ ( ... o "name" -- ... )
: ->
	' execute
	state @
	if
		->,
	else
		over @ + @ execute
	then
; immediate

\ ( class m-offset s-offset "name" -- )
: end-class
	create
		here >r , dup , 2 cells
		?do
			['] noop ,
			1 cells
		+loop
		cell+ dup cell+ r> rot @ 2 cells /string move
;

\ ( xt class "name" -- )
: defines
	' >body @ + !
;

\ ( class "name" -- )
: ::
	' >body @ + @ compile,
;

\ ( class -- o | 0 )
: new
	dup @ calloc
	dup
	if
		\ vtable
		swap over !
	else
		nip
	then
;

\ ( o | 0 -- )
: delete
	free
;

\ base class for reference counting objects

object-class begin-class
	field _cnt
	method base-ref
	method base-deref
	method base-init
	method base-deinit
	method base-construct
	method base-destroy
end-class base-class

\ ( o -- )
:noname
	1 swap >field _cnt +!
; base-class defines base-ref

\ ( o -- )
:noname
	>r
	1 r@ >field _cnt -!
	r@ @field _cnt 0=
	if
		r@ -> base-destroy
	then
	rdrop
; base-class defines base-deref

\ ( ... o -- 0 | -err_code )
:noname
	-> base-ref 0
; base-class defines base-init

\ ( o -- )
:noname
	drop
; base-class defines base-deinit

\ ( ... class -- ... 0 | -err_code | o )
: construct
	new dup
	if
		>r r@ -> base-init ?dup
		if
			r> delete
		else
			r>
		then
	then
;

\ ( ... o -- ... 0 | -err_code | o' )
:noname
	@ construct
; base-class defines base-construct

\ ( o -- )
: destroy
	dup -> base-deinit delete
; ' destroy base-class defines base-destroy

hide _cnt
