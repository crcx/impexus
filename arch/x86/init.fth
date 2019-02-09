\ Operating system base
\ (c) 2018 Jan-Michael "jmf" Franz
include asm_x86.fth

\ Alternative register names
ESP constant RSP \ Return stack pointer
EBP constant PSP \ Parameter stack pointer

\ Dictionary start pointer
variable dict_head 0 dict_head !

\ Memory layout:
\ 0x00      [ Multiboot header       ]
\ mbh_size  [ Text segment           ]
\ following [ Forth Dictionary start ]
\ 0x78000   [ Forth Dictionary end   ]
\ 0x78004   [ RSP bottom             ]
\ 0x7C000   [ RSP top                ]
\ 0x7C004   [ PSP bottom             ]
\ 0x80000   [ PSP top                ]

\ Dictionary entries:
\ 0x00      [ Word name as string        ]
\ + wordlen [ Word length                ]
\ + 1 cell  [ Pointer to previous / NULL ]
\ + 1 cell  [ Entry point to the code    ]

\ Assembly macros:

\ Push 32-bit of data from register to PSP
: PUSH_PSP ( reg32 -- )
  reg_valid?
  PSP swap MOVR2M32
  PSP     INC32
  PSP     INC32
  PSP     INC32
  PSP     INC32
;

\ Pop 32 bit of data from PSP to a register
: POP_PSP ( reg32 -- )
  reg_valid?
  PSP     DEC32
  PSP     DEC32
  PSP     DEC32
  PSP     DEC32
      PSP MOVM2R32
;

\ Drop the topmost element from PSP
: DROP_PSP ( reg32 -- )
  PSP     DEC32
  PSP     DEC32
  PSP     DEC32
  PSP     DEC32
;

\ Write dictionary entry boilerplate
: DEF_WORD ( c-addr n -- )
  2dup over + swap do
    i c@ c,
  loop
  dup 4c,
  dict_head @ 4c,
  ." Defined word " TYPE ."  at position: "
  CADDR>>> dup hex . decimal cr
  dict_head !
;

\ Assembly labels
variable l:dict_head
variable l:source_addr
variable l:source_len

variable l:dup
variable l:drop
variable l:swap
variable l:>r
variable l:r>
variable l:!
variable l:@
variable l:c!
variable l:c@
variable l:find

cr
here assembly_start ! \ Start of the code block --------------------------------

l:dict_head ---
0 4c,

l:source_addr ---
0 4c,

l:source_len ---
0 4c,

s" dup" DEF_WORD ( n -- n n )
l:dup ---
  EAX POP_PSP 
  EAX PUSH_PSP
  EAX PUSH_PSP
  RET

s" drop" DEF_WORD ( n -- )
l:drop ---
  DROP_PSP
  RET

s" swap" DEF_WORD ( x y -- y x )
l:swap ---
  EAX POP_PSP
  EBX POP_PSP
  EAX PUSH_PSP
  EBX PUSH_PSP
  RET

s" r>" DEF_WORD ( -- n )
l:r> ---
  EAX POP
  EAX PUSH_PSP
  RET

s" >r" DEF_WORD ( n -- )
l:>r ---
  EAX POP_PSP
  EAX PUSH
  RET

s" !" DEF_WORD ( n c-addr -- )
l:! ---
  EAX POP_PSP
  EBX POP_PSP
  EAX EBX MOVR2M32
  RET

s" @" DEF_WORD ( c-addr -- n )
l:@ ---
  EAX POP_PSP
  EBX EAX MOVM2R32
  EBX PUSH_PSP

s" c!" DEF_WORD ( n c-addr -- )
l:c! ---
  EAX POP_PSP
  EBX POP_PSP
  EAX EBX MOVR2M8
  RET

s" c@" DEF_WORD ( c-addr -- n )
l:c@ ---
  EAX POP_PSP
  EBX EAX MOVM2R8
  EBX PUSH_PSP
  RET

ENTRY ---
  AL 'i' MOVI8
  AL PUSH_PSP
  EBX $B8000 MOVI32
  EBX PUSH_PSP
  l:c! >>> CALL
  HLT

\ TBD: This is just a placeholder:
CADDR>>> l:source_addr ! \ Forth source start ----------------------------------
'i' 4c,
CADDR>>> l:source_addr @ - l:source_len ! \ Forth source end -------------------

here assembly_end ! \ End of the code block ------------------------------------


dict_head @ l:dict_head @ ! \ Update dictionary head to point to the last word
cr
." ---- Assembly complete ----" cr
." Dictionary head is at address: " l:dict_head   @ @ hex . decimal cr
." Source starts at             : " l:source_addr @   hex . decimal cr
." Source length in bytes       : " l:source_len  @   hex . decimal cr
compile
bye
