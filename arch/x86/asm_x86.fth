\ This assembler creates a multiboot-enabled executable
\ Target architecture: x86
\ (c) 2018 Jan-Michael "jmf" Franz


\ Aux. variables and constants -------------------------------------------------

$1BADB002 CONSTANT MULTIBOOT_MAGIC
$00010000 CONSTANT MULTIBOOT_FLAGS
$FFFFFFFF MULTIBOOT_MAGIC MULTIBOOT_FLAGS + - 1+ CONSTANT MULTIBOOT_CHECKSUM
$20       CONSTANT MBH_SIZE

VARIABLE MULTIBOOT_HEADER MBH_SIZE ALLOT
VARIABLE ASSEMBLY_START
VARIABLE ASSEMBLY_END
VARIABLE ENTRY
\ Codes for all registers ------------------------------------------------------

\ 8 bit registers
0 CONSTANT AL
1 CONSTANT CL
2 CONSTANT DL
3 CONSTANT BL
4 CONSTANT AH
5 CONSTANT CH
6 CONSTANT DH
7 CONSTANT BH

\ 16 bit registers
0 CONSTANT AX
1 CONSTANT CX
2 CONSTANT DX
3 CONSTANT BX
4 CONSTANT SP
5 CONSTANT BP
6 CONSTANT SI
7 CONSTANT DI

\ 32 bit registers
0 CONSTANT EAX
1 CONSTANT ECX
2 CONSTANT EDX
3 CONSTANT EBX
4 CONSTANT ESP
5 CONSTANT EBP
6 CONSTANT ESI
7 CONSTANT EDI

\ Helper functions -------------------------------------------------------------

: FAIL
  CR ." ### FATAL - Compilation ended with errors."
  BYE
;

\ Store 4 bytes in the given address, return the next free address
: 4-> ( c-addr i -- c-addr+4 )
  OVER !  4 +
;

\ C, 16 bit of the top stack element
: 2C, ( n -- )
  DUP          C,
      8 RSHIFT C,
;

\ C, 32 bit of the top stack element
: 4C, ( n -- )
  DUP           C,
  DUP 8  RSHIFT C,
  DUP 16 RSHIFT C,
      24 RSHIFT C,
;

\ Check if the register code is valid
: REG_VALID? ( reg -- reg )
  DUP 7 > IF ." Error: Invalid register ID: " . CR FAIL ELSE
  DUP 0 < IF ." Error: Invalid register ID: " . CR FAIL THEN THEN
;

: REG_SP? ( reg -- reg )
  DUP 4 = IF ." Error: Can't use SP as a pointer here" CR FAIL THEN
;

: ASSEMBLY_LENGTH ( -- i )
  ASSEMBLY_END @ ASSEMBLY_START @ -
;

\ Write the multiboot header to memory, main function is at c-addr
: WRITE_MULTIBOOT_HEADER ( c-addr -- )
  MULTIBOOT_HEADER
  MULTIBOOT_MAGIC    4->
  MULTIBOOT_FLAGS    4->
  MULTIBOOT_CHECKSUM 4->
  \ Base memory map defined here: [ MULTIBOOT_HEADER ][ .text ][ 16 K of .bss ]
  0                           4-> \ Physical address for this header start
  0                           4-> \ TBD: What exactly does this value do?
  ASSEMBLY_LENGTH MBH_SIZE +  4-> \ Physical end address of the .text segment
  $80000                      4-> \ .bss physical end address
  SWAP MBH_SIZE +             4-> \ Entry point for the code
  DROP
;

\ Assembly words ---------------------------------------------------------------

\ Set a label
: --- ( c-addr -- )
  HERE SWAP !
;

\ Get a reference to a label
: >>> ( c-addr -- n )
  @ HERE -
;

\ Get the absolute physical address of a label
: A>>> ( c-addr -- n )
  @ ASSEMBLY_START @ - MBH_SIZE +
;

\ Assign immediate to register (8 bit)
: MOVI8 ( r8 i8 -- )
  SWAP REG_VALID?
  $B0 + C,
  C, 
;

\ Assign immediate to register (16 bit)
: MOVI16 ( r16 i -- )
  SWAP REG_VALID?
  $66 C, $B8 + C,
  2C,
;

\ Assign immediate to register (32 bit)
: MOVI32 ( r32 i -- )
  SWAP REG_VALID?
  $B8 + C,
  4C,
;

\ Move an 8-bit value from one register to an other
: MOVR8 ( target source -- )
  REG_VALID? SWAP REG_VALID?
  $88 C,
  $C0 + SWAP 8 * + C, \ $C0 + target + 8 * source
;

\ Move a 16-bit value from one register to an other
: MOVR16 ( target source -- )
  REG_VALID? SWAP REG_VALID?
  $66 C, $89 C,
  $C0 + SWAP 8 * + C, \ $C0 + target + 8 * source
;

\ Move a 32-bit value from one register to an other
: MOVR32 ( target source -- )
  REG_VALID? SWAP REG_VALID?
  $89 C,
  $C0 + SWAP 8 * + C, \ $C0 + target + 8 * source
;

\ Move an 8-bit value from a register to memory
: MOVR2M8 ( [r32] r8 -- )
  REG_VALID? SWAP REG_VALID? REG_SP?
  $88 C,
  $40 + SWAP 8 * + C,
  $00 C,
;

\ Move a 16-bit value from a register to memory
: MOVR2M16 ( [r32] r16 -- )
  REG_VALID? SWAP REG_VALID? REG_SP?
  $66 C, $89 C,
  $40 + SWAP 8 * + C,
  $00 C,
;

\ Move a 32-bit value from a register to memory
: MOVR2M32 ( [r32] r32 -- )
  REG_VALID? SWAP REG_VALID? REG_SP?
  $89 C,
  $40 + SWAP 8 * + C,
  $00 C,
;

\ Move an 8-bit value from memory to a register
: MOVM2R8 ( r8 [r32] -- )
  REG_VALID? SWAP REG_VALID?
  $8A C,
  8 * $40 + + C,
  $00 C,
;

\ Move a 16-bit value from memory to a register
: MOVM2R16 ( r16 [r32] -- )
  REG_VALID? SWAP REG_VALID?
  $66 C, $8B C,
  8 * $40 + + C,
  $00 C,
;

\ Move a 32-bit value from memory to a register
: MOVM2R32 ( r32 [r32] -- )
  REG_VALID? REG_SP? SWAP REG_VALID?
  $8B C,
  8 * $40 + + C,
  $00 C,
;

\ Increment an 8-bit register
: INC8 ( r8 -- )
  REG_VALID?
  $FE C, $C0 + C,
;

\ Increment a 16-bit register
: INC16 ( r16 -- )
  REG_VALID?
  $66 C, $FF C, $C0 + C,
;

\ Increment a 32-bit register
: INC32 ( r32 -- )
  REG_VALID?
  $FF C, $C0 + C,
;

\ Decrement an 8-bit register
: DEC8 ( r8 -- )
  REG_VALID?
  $FE C, $C8 + C,
;

\ Decrement a 16-bit register
: DEC16 ( r16 -- )
  REG_VALID?
  $66 C, $FF C, $C8 + C,
;

\ Decrement a 32-bit register
: DEC32 ( r32 -- )
  REG_VALID?
  $FF C, $C8 + C,
;

\ Compare two 8-bit registers
: CMPI8 ( r8 r8 )
  REG_VALID?
  $38 C,
  $C0 + SWAP 8 * + C,
;

\ Compare two 16-bit registers
: CMPI16 ( r16 r16 )
  REG_VALID?
  $66 C, $39 C,
  $C0 + SWAP 8 * + C,
;

\ Compare two 32-bit registers
: CMPI32 ( r32 r32 )
  REG_VALID? SWAP REG_VALID?
  $39 C,
  $C0 + SWAP 8 * + C, 
;

\ Unconditional, relative jump
: JMP ( rel -- )
  $E9 C,
  4 - \ Calculate proper relative address
  DUP 0 < IF
    $FFFFFFFF +
  THEN
  4C,
;

\ Unconditional, absolute jump to register value
: JMPA ( abs-reg32 -- )
  REG_VALID?
  $FF C,
  $e0 + C,
;

\ Jump relatively if zero/not equal
: JMPZ ( rel -- )
 	$0F C, $85 C,
  5 - \ Calculate proper relative address
  DUP 0 < IF
    $FFFFFFFF +
  THEN
  4C,
;

\ Push 32-bit register content to the stack
: PUSH ( r32 -- )
  REG_VALID?
  $50 + C,
;  

\ Pop content from the stack to a 32-bit register
: POP ( r32 -- )
  REG_VALID?
  $58 + C,
;

\ Call
: CALL ( c-addr -- )
  $E8 C,
  4 - \ Calculate proper relative address
  DUP 0 < IF
    $FFFFFFFF +
  THEN
  4C,
;

\ Return
: RET ( -- )
  $C3 C,
;

\ STOP. Hammer time!
: HLT
  $F4 C,
;

\ Routine for writing everything to a file -------------------------------------

: COMPILE
  ENTRY @ ASSEMBLY_START @ - WRITE_MULTIBOOT_HEADER
  \ Create a file named "kernel":
  S" kernel" R/W
  CREATE-FILE 0= IF ELSE ." E: Can't create/open file 'kernel'." FAIL THEN
  \ Write the multiboot header to the file: 
  DUP MULTIBOOT_HEADER 32 ROT 
  WRITE-FILE 0= IF ELSE ." E: Can't write to file." CR FAIL THEN
  \ Write the code to the file:
  DUP ASSEMBLY_START @ ASSEMBLY_LENGTH ROT 
  WRITE-FILE 0= IF ELSE ." E: Can't write to file." CR FAIL THEN
  CLOSE-FILE
  CR
;
