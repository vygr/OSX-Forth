\ x86 specific words

\ ( n -- f )
: ?byte
	-128 128 within
;

\ ( offset -- ) ; ( addr -- addr + offset )
: +immed,
	[ base @ hex ]
	?dup
	if
		dup ?byte
		if
			\ add ebx, byte offset
			83 c, c3 c, c,
		else
			\ add ebx, long offset
			81 c, c3 c, ,
		then
	then
	[ base ! ]
;

\ ( offset -- ) ; ( addr -- [addr + offset] )
: @immed,
	[ base @ hex ]
	?dup
	if
		dup ?byte
		if
			\ mov ebx, [byte ebx + offset]
			8b c, 5b c, c,
		else
			\ mov ebx, [long ebx + offset]
			8b c, 9b c, ,
		then
	else
		\ mov ebx, [ebx]
		8b c, 1b c,
	then
	[ base ! ]
;

\ ( offset -- ) ; ( u addr -- )
: !immed,
	[ base @ hex ]
	\ mov eax, [ebp]
	8b c, 45 c, 0 c,
	?dup
	if
		dup ?byte
		if
			\ mov [byte ebx + offset], eax
			89 c, 43 c, c,
		else
			\ mov [long ebx + offset], eax
			89 c, 83 c, ,
		then
	else
		\ mov [ebx], eax
		89 c, 3 c,
	then
	\ mov ebx, [ebp + 4]
	8b c, 5d c, 4 c,
	\ add ebp, byte 8
	83 c, c5 c, 8 c,
	[ base ! ]
;

\ ( offset -- ) ; ( o -- o )
: ->,
	[ base @ hex ]
	dup ?byte
	if
		\ mov eax, [ebx]
		8b c, 3 c,
		\ call [byte eax + offset]
		ff c, 50 c, c,
	else
		\ mov eax, [ebx]
		8b c, 3 c,
		\ call [long eax + offset]
		ff c, 90 c, ,
	then
	[ base ! ]
;
