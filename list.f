\ amiga style lists

0 begin-structure
	field _succ
	field _pred
	field _obj
end-structure node-structure

\ ( ln ln -- )
: node-set-succ
	!field _succ
;

\ ( ln ln -- )
: node-set-pred
	!field _pred
;

\ ( obj ln -- )
: node-set-obj
	!field _obj
;

\ ( ln -- ln )
: node-get-succ
	@field _succ
; inline

\ ( ln -- ln )
: node-get-pred
	@field _pred
; inline

\ ( ln -- obj )
: node-get-obj
	@field _obj
; inline

\ ( obj ln -- )
: node-init
	node-set-obj
;

\ ( ln ln -- )
: node-add-after
	2dup node-get-succ node-set-pred
	2dup node-get-succ swap node-set-succ
	2dup swap node-set-pred
	node-set-succ
;

\ ( ln ln -- )
: node-add-before
	2dup node-get-pred node-set-succ
	2dup node-get-pred swap node-set-pred
	2dup swap node-set-succ
	node-set-pred
;

\ ( ln -- )
: node-remove
	dup node-get-pred swap node-get-succ
	2dup node-set-pred
	swap node-set-succ
;

\ ( ln -- flag )
: node-is-first
	node-get-pred node-get-pred 0=
;

\ ( ln -- flag )
: node-is-last
	node-get-succ node-get-succ 0=
;

0 begin-structure
	field _head
	field _end
	field _tail
end-structure list-structure

\ ( ln lh -- )
: list-set-head
	!field _head
;

\ ( ln lh -- )
: list-set-tail
	!field _tail
;

\ ( ln lh -- )
: list-set-end
	!field _end
;

\ ( lh -- ln )
: list-get-head
	@field _head
; inline

\ ( lh -- ln )
: list-get-tail
	@field _tail
; inline

\ ( lh -- )
: list-init
	dup >field _end over list-set-head
	0 over list-set-end
	dup >field _head swap list-set-tail
;

\ ( lh -- flag )
: list-is-empty
	dup list-get-head swap >field _end =
;

\ ( ln lh -- )
: list-add-at-head
	>field _head node-add-after
;

\ ( ln lh -- )
: list-add-at-tail
	>field _end node-add-before
;

\ ( lh -- ln | 0 )
: list-remove-head
	dup list-is-empty
	if
		drop 0
	else
		list-get-head
		dup node-remove
	then
;

\ ( lh -- ln | 0 )
: list-remove-tail
	dup list-is-empty
	if
		drop 0
	else
		list-get-tail
		dup node-remove
	then
;

\ ( i lh -- ln | 0 )
: list-get-node-at-index
	list-get-head
	begin
		dup node-get-succ dup
	while
		rot dup
	while
		1- -rot nip
	repeat rot then
	nip nip
;

\ ( ln lh -- i | -1 )
: list-get-index-of-node
	-1 >r
	list-get-head
	begin
		dup node-get-succ ?dup
	while
		r@ 1+ r!
		swap 2 pick =
	until else -1 r! then
	2drop r>
;

\ ( u xt lh -- r | 0 )
\ xt api is ( u ln lh -- r | 0 )
: list-enumerate-forwards
	swap over 2>r list-get-head
	begin
		2dup node-get-succ dup
 	while
 		2swap 2r@ execute ?dup
 	until else nip then
 	2rdrop nip nip
;

\ ( u xt lh -- r | 0 )
\ xt api is ( u ln lh -- r | 0 )
: list-enumerate-backwards
	swap over 2>r list-get-tail
	begin
		2dup node-get-pred dup
 	while
 		2swap 2r@ execute ?dup
 	until else nip then
 	2rdrop nip nip
;

\ ( "name" -- )
: list
	create here list-structure allot list-init
;

\ ( obj "name" -- )
: node
	create here node-structure allot node-init
;

hide _succ
hide _pred
hide _obj
hide _head
hide _end
hide _tail
