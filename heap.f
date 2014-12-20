\ heap class for fixed size object allocation

base-class begin-class
	field _osize
	field _bsize
	field _free
	list-structure +field _blist
	method heap-alloc
	method heap-free
	method heap-free-all
end-class heap-class

\ ( object_size num_per_block o -- 0 | -err_code )
:noname
	>r
	r@ [ base-class :: base-init ]
	?dup
	if
		\ error with parent init, so return -err_code
		nip nip
	else
		over * [ list-structure ] literal + r@ !field _bsize
		r@ !field _osize
		r@ >field _blist list-init
		0
	then
	rdrop
; heap-class defines base-init

\ ( 0 mn lh -- 0 )
: heap-deinit-cb
	drop
	dup node-remove
	mem-free
;

\ ( o -- )
:noname
	>r
	0 ['] heap-deinit-cb r@ >field _blist list-enumerate-forwards
	r@ !field _free
	r> [ base-class :: base-deinit ]
; heap-class defines base-deinit

\ ( addr o -- )
:noname
	>r
	r@ @field _free
	over !
	r> !field _free
; heap-class defines heap-free

\ ( o mn -- )
: heap-free-block
	over @field _bsize over +
	swap [ list-structure ] literal +
	do
		i over -> heap-free
		dup @field _osize
	+loop
	drop
;

\ ( o mn lh -- 0 )
: heap-free-all-cb
	drop heap-free-block 0
;

\ ( o -- )
:noname
	0 over !field _free
	['] heap-free-all-cb over >field _blist list-enumerate-forwards drop
; heap-class defines heap-free-all

\ ( o -- 0 | addr )
:noname
	>r
	r@ @field _free ?dup
	if
		dup @
		r@ !field _free
	else
		\ allocate new block
		r@ @field _bsize mem-alloc
		dup
		if
			dup r@ >field _blist list-add-at-tail
			r@ swap heap-free-block
			r@ recurse
		then
	then
	rdrop
; heap-class defines heap-alloc

hide _osize
hide _bsize
hide _free
hide _blist
hide heap-deinit-cb
hide heap-free-all-cb
hide heap-free-block
