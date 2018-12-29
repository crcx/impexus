\ Operating system base
\ (c) 2018 Jan-Michael "jmf" Franz
INCLUDE asm_x86.fth

\ Alternative register names
\ TBD: Store TOS in a register for better performance
ESP CONSTANT RSP \ Return stack pointer
EBP CONSTANT PSP \ Parameter stack pointer

\ Memory layout:
\ 0x00      [ Multiboot header       ]
\ MBH_SIZE  [ Text segment           ]
\ following [ Forth Dictionary start ]
\ 0x78000   [ Forth Dictionary end   ]
\ 0x78004   [ RSP bottom             ]
\ 0x7C000   [ RSP top                ]
\ 0x7C004   [ PSP bottom             ]
\ 0x80000   [ PSP top                ]

\ Assembly macros:

\ Push 32-bit of data from register to PSP
: PUSH_PSP ( reg32 -- )
  REG_VALID?
  PSP SWAP MOVR2M32
  PSP     INC32
  PSP     INC32
  PSP     INC32
  PSP     INC32
;

\ Pop 32 bit of data from PSP to a register
: POP_PSP ( reg32 -- )
  REG_VALID?
  PSP     DEC32
  PSP     DEC32
  PSP     DEC32
  PSP     DEC32
      PSP MOVM2R32
;

\ Declaration of labels:
VARIABLE FAIL
VARIABLE F_!
VARIABLE F_C!
VARIABLE F_EMIT
VARIABLE F_RUN
VARIABLE RUN

\ Content of text and data segment
HERE ASSEMBLY_START !

ENTRY ---
  \ Set up the stack pointer
  PSP $80000 MOVI32
  \ Set up the return stack pointer
  RSP $7C000 MOVI32
  \ Pointer to the screen, only temporary - TBD: Implement better solution
  EDX $B8000 MOVI32

  \ Jump into the starting word
  RUN ---
  $70 CALL \ <-- Change this value as instructed at compilation
  HLT

FAIL ---
  HLT

\ Dictionary starts here

F_! --- ( n c-addr -- )
  EAX POP_PSP
  EBX POP_PSP
  EAX EBX MOVR2M32
  RET

F_C! --- ( n c-addr -- )
  EAX POP_PSP
  EBX POP_PSP
  EAX BL MOVR2M8
  RET

F_EMIT --- ( c -- )
  \ Print letter
  EDX PUSH_PSP
  F_C! >>> CALL
  EDX INC32
  \ Blue text color
  EAX 1 MOVI32
  EAX PUSH_PSP
  EDX PUSH_PSP
  F_C! >>> CALL
  EDX INC32
  RET

HLT
F_RUN --- ( -- )
  EAX 'x' MOVI32
  EAX     PUSH_PSP
  EAX 's' MOVI32
  EAX     PUSH_PSP
  EAX 'u' MOVI32
  EAX     PUSH_PSP
  EAX 'x' MOVI32
  EAX     PUSH_PSP
  EAX 'e' MOVI32
  EAX     PUSH_PSP
  EAX 'p' MOVI32
  EAX     PUSH_PSP
  EAX 'm' MOVI32
  EAX     PUSH_PSP
  EAX 'i' MOVI32
  EAX     PUSH_PSP

  F_EMIT >>> CALL
  F_EMIT >>> CALL
  F_EMIT >>> CALL
  F_EMIT >>> CALL
  F_EMIT >>> CALL
  F_EMIT >>> CALL
  F_EMIT >>> CALL
RET

\ TBD: Automate this!
CR CR F_RUN @ RUN @ - 1- HEX .
CR ." (Please enter that value at the CALL after RUN --- and recompile)"

HERE ASSEMBLY_END !

COMPILE
BYE
