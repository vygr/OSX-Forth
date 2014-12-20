\ dynamic memory allocation

list freelist

\ ( s mn lh -- 0 | mn )
: mem-search-cb
	drop swap over
	node-get-obj >
	if
		drop 0
	then
;

\ ( mn -- )
: mem-insert
	dup node-get-obj ['] mem-search-cb [ freelist ] literal list-enumerate-forwards
	?dup
	if
		node-add-before
	else
		[ freelist ] literal list-add-at-tail
	then
;

\ ( s mn -- mn )
: mem-slice
	2dup node-get-obj swap -
	dup [ node-structure ] literal <
	if
		drop nip
	else
		2dup over node-set-obj mem-insert
		+ swap over node-set-obj
	then
;

\ ( mn mn lh -- 0 | mn )
: mem-splice-left-cb
	drop
	over dup node-get-obj +
	over =
	if
		dup node-remove
		node-get-obj over node-get-obj +
		over node-set-obj
	else
		2drop 0
	then
;

\ ( mn mn lh -- 0 | mn )
: mem-splice-right-cb
	drop swap
	over dup node-get-obj +
	over =
	if
		over node-remove
		node-get-obj over node-get-obj +
		over node-set-obj
	else
		2drop 0
	then
;

\ ( mn -- )
: mem-free
	dup ['] mem-splice-left-cb [ freelist ] literal list-enumerate-forwards
	?dup
	if
		nip
	then
	dup ['] mem-splice-right-cb [ freelist ] literal list-enumerate-forwards
	?dup
	if
		nip
	then
	mem-insert
;

\ ( s -- 0 | mn )
: mem-alloc
	[ node-structure ] literal max aligned
	dup ['] mem-search-cb [ freelist ] literal list-enumerate-forwards
	dup
	if
		dup node-remove mem-slice
	else
		nip
	then
;

\ ( bytes -- )
: mem-allot
	align aligned here over allot dup -rot node-set-obj mem-free
;

node-structure begin-structure
	field _nodes
	field _total
	field _max
end-structure mem-info-structure

\ ( mi mn lh -- 0 )
: mem-info-cb
	drop swap >r
	node-get-obj dup
	r@ >field _total +!
	r@ @field _max max r@ !field _max
	1 r> >field _nodes +!
	0
;

\ ( -- )
: mem-info
	[ mem-info-structure ] literal mem-alloc ?dup
	if
		dup [ node-structure ] literal + [ mem-info-structure node-structure - ] literal erase
		dup ['] mem-info-cb [ freelist ] literal list-enumerate-forwards drop
		dup ." Total " @field _total .
		dup ." Max block size " @field _max .
		dup ." Num nodes " @field _nodes .
		mem-free
	else
		." No free memory !"
	then
	cr
;

\ c style malloc, calloc, realloc and free

\ ( s -- 0 | addr )
: malloc
	4+ mem-alloc
	dup
	if
		dup dup node-get-obj swap ! 4+
	then
;

\ ( s -- 0 | addr )
: calloc
	malloc dup
	if
		dup dup 4- @ 4- erase
	then
;

\ ( 0 | addr -- )
: free
	?dup
	if
		4- dup @ over node-set-obj mem-free
	then
;

\ ( 0 | addr, 0 | s -- 0 | addr )
: realloc
	dup
	if
		over
		if
			dup malloc
			dup
			if
				dup >r 2 pick >r
				swap r@ 4- @ 4- min
				cmove
				r> free r>
			else
				nip nip
			then
		else
			nip malloc
		then
	else
		swap free
	then
;

hide _nodes
hide _total
hide _max
hide mem-info-cb
hide mem-info-structure
hide mem-search-cb
hide mem-splice-left-cb
hide mem-splice-right-cb
hide mem-insert
hide mem-slice
hide freelist
