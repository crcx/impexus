\ This assembler creates a multiboot-enabled executable
\ Target architecture: x86
\ (c) 2018 Jan-Michael "jmf" Franz


\ Aux. variables and constants -------------------------------------------------

$1BADB002 constant multiboot_magic
$00010000 constant multiboot_flags
$FFFFFFFF multiboot_magic multiboot_flags + - 1+ constant multiboot_checksum
$20       constant mbh_size

variable multiboot_header mbh_size ALLOT
variable assembly_start
variable ASSEMBLY_END
variable entry
\ Codes for all registers ------------------------------------------------------

\ 8 bit registers
0 constant AL
1 constant CL
2 constant DL
3 constant BL
4 constant AH
5 constant CH
6 constant DH
7 constant BH

\ 16 bit registers
0 constant AX
1 constant CX
2 constant DX
3 constant BX
4 constant SP
5 constant BP
6 constant SI
7 constant DI

\ 32 bit registers
0 constant EAX
1 constant ECX
2 constant EDX
3 constant EBX
4 constant ESP
5 constant EBP
6 constant ESI
7 constant EDI

\ Helper functions -------------------------------------------------------------

: fail
  cr ." ### FATAL - Compilation ended with errors."
  bye
;

\ Store 4 bytes in the given address, return the next free address
: 4-> ( c-addr i -- c-addr+4 )
  over !  4 +
;

\ c, 16 bit of the top stack element
: 2c, ( n -- )
  dup          c,
      8 rshift c,
;

\ c, 32 bit of the top stack element
: 4c, ( n -- )
  dup           c,
  dup 8  rshift c,
  dup 16 rshift c,
      24 rshift c,
;

\ Check if the register code is valid
: reg_valid? ( reg -- reg )
  dup 7 > if ." Error: Invalid register ID: " . cr fail else
  dup 0 < if ." Error: Invalid register ID: " . cr fail then then
;

: reg_sp? ( reg -- reg )
  dup 4 = if ." Error: Can't use SP as a pointer here" cr fail then
;

: assembly_length ( -- i )
  ASSEMBLY_END @ assembly_start @ -
;

\ Write the multiboot header to memory, main function is at c-addr
: write_multiboot_header ( c-addr -- )
  multiboot_header
  multiboot_magic    4->
  multiboot_flags    4->
  multiboot_checksum 4->
  \ Base memory map defined here: [ multiboot_header ][ .text ][ 16 K of .bss ]
  0                           4-> \ Physical address for this header start
  0                           4-> \ TBD: What exactly does this value do?
  assembly_length mbh_size +  4-> \ Physical end address of the .text segment
  $80000                      4-> \ .bss physical end address
  swap mbh_size +             4-> \ entry point for the code
  drop
;

\ Assembly words ---------------------------------------------------------------

\ Set a label
: --- ( c-addr -- )
  here swap !
;

\ Get a reference to a label
: >>> ( c-addr -- n )
  @ here -
;

\ Get the absolute physical address of a label
: A>>> ( c-addr -- n )
  @ assembly_start @ - mbh_size +
;

\ Get the current address in memory
: CADDR>>> ( -- c-addr )
  here assembly_start @ - mbh_size +
;

\ Assign immediate to register (8 bit)
: MOVI8 ( r8 i8 -- )
  swap reg_valid?
  $B0 + c,
  c, 
;

\ Assign immediate to register (16 bit)
: MOVI16 ( r16 i -- )
  swap reg_valid?
  $66 c, $B8 + c,
  2c,
;

\ Assign immediate to register (32 bit)
: MOVI32 ( r32 i -- )
  swap reg_valid?
  $B8 + c,
  4c,
;

\ Move an 8-bit value from one register to an other
: MOVR8 ( target source -- )
  reg_valid? swap reg_valid?
  $88 c,
  $C0 + swap 8 * + c, \ $C0 + target + 8 * source
;

\ Move a 16-bit value from one register to an other
: MOVR16 ( target source -- )
  reg_valid? swap reg_valid?
  $66 c, $89 c,
  $C0 + swap 8 * + c, \ $C0 + target + 8 * source
;

\ Move a 32-bit value from one register to an other
: MOVR32 ( target source -- )
  reg_valid? swap reg_valid?
  $89 c,
  $C0 + swap 8 * + c, \ $C0 + target + 8 * source
;

\ Move an 8-bit value from a register to memory
: MOVR2M8 ( [r32] r8 -- )
  reg_valid? swap reg_valid? reg_sp?
  $88 c,
  $40 + swap 8 * + c,
  $00 c,
;

\ Move a 16-bit value from a register to memory
: MOVR2M16 ( [r32] r16 -- )
  reg_valid? swap reg_valid? reg_sp?
  $66 c, $89 c,
  $40 + swap 8 * + c,
  $00 c,
;

\ Move a 32-bit value from a register to memory
: MOVR2M32 ( [r32] r32 -- )
  reg_valid? swap reg_valid? reg_sp?
  $89 c,
  $40 + swap 8 * + c,
  $00 c,
;

\ Move an 8-bit value from memory to a register
: MOVM2R8 ( r8 [r32] -- )
  reg_valid? swap reg_valid?
  $8A c,
  8 * $40 + + c,
  $00 c,
;

\ Move a 16-bit value from memory to a register
: MOVM2R16 ( r16 [r32] -- )
  reg_valid? swap reg_valid?
  $66 c, $8B c,
  8 * $40 + + c,
  $00 c,
;

\ Move a 32-bit value from memory to a register
: MOVM2R32 ( r32 [r32] -- )
  reg_valid? reg_sp? swap reg_valid?
  $8B c,
  8 * $40 + + c,
  $00 c,
;

\ Increment an 8-bit register
: INC8 ( r8 -- )
  reg_valid?
  $FE c, $C0 + c,
;

\ Increment a 16-bit register
: INC16 ( r16 -- )
  reg_valid?
  $66 c, $FF c, $C0 + c,
;

\ Increment a 32-bit register
: INC32 ( r32 -- )
  reg_valid?
  $FF c, $C0 + c,
;

\ Decrement an 8-bit register
: DEC8 ( r8 -- )
  reg_valid?
  $FE c, $C8 + c,
;

\ Decrement a 16-bit register
: DEC16 ( r16 -- )
  reg_valid?
  $66 c, $FF c, $C8 + c,
;

\ Decrement a 32-bit register
: DEC32 ( r32 -- )
  reg_valid?
  $FF c, $C8 + c,
;

\ Compare two 8-bit registers
: CMPI8 ( r8 r8 )
  reg_valid?
  $38 c,
  $C0 + swap 8 * + c,
;

\ Compare two 16-bit registers
: CMPI16 ( r16 r16 )
  reg_valid?
  $66 c, $39 c,
  $C0 + swap 8 * + c,
;

\ Compare two 32-bit registers
: CMPI32 ( r32 r32 )
  reg_valid? swap reg_valid?
  $39 c,
  $C0 + swap 8 * + c, 
;

\ Unconditional, relative jump
: JMP ( rel -- )
  $E9 c,
  4 - \ Calculate proper relative address
  dup 0 < IF
    $FFFFFFFF +
  then
  4c,
;

\ Unconditional, absolute jump to register value
: JMPA ( abs-reg32 -- )
  reg_valid?
  $FF c,
  $e0 + c,
;

\ Jump relatively if zero/not equal
: JMPZ ( rel -- )
 	$0F c, $85 c,
  5 - \ Calculate proper relative address
  dup 0 < IF
    $FFFFFFFF +
  then
  4c,
;

\ Push 32-bit register content to the stack
: PUSH ( r32 -- )
  reg_valid?
  $50 + c,
;  

\ Pop content from the stack to a 32-bit register
: POP ( r32 -- )
  reg_valid?
  $58 + c,
;

\ Call
: CALL ( c-addr -- )
  $E8 c,
  4 - \ Calculate proper relative address
  dup 0 < IF
    $FFFFFFFF +
  then
  4c,
;

\ Return
: RET ( -- )
  $C3 c,
;

\ STOP. Hammer time!
: HLT
  $F4 c,
;

\ Routine for writing everything to a file -------------------------------------

: compile
  entry @ assembly_start @ - write_multiboot_header
  \ create a file named "kernel":
  s" kernel" r/w
  create-file 0= if else ." E: Can't create/open file 'kernel'." fail then
  \ Write the multiboot header to the file: 
  dup multiboot_header 32 rot 
  write-file 0= if else ." E: Can't write to file." cr fail then
  \ Write the code to the file:
  cr ." Writing code to file: " assembly_length . ." bytes..." cr
  dup assembly_start @ assembly_length rot 
  write-file 0= if else ." E: Can't write to file." cr fail then
  close-file
  ." [DONE]" cr
;
