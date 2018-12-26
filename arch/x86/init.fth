\ Operating system base
\ (c) 2018 Jan-Michael "jmf" Franz
INCLUDE asm_x86.fth

\ Declaration of labels:
VARIABLE LOOP1

\ Assembly code

HERE ASSEMBLY_START !

EBX $B8000 MOVI32
AH  0      MOVI8
AL  '#'    MOVI8

CX  0      MOVI16
DX  2000   MOVI16 \ 25*80, terminal size

\ Write squiggles in terminal:
LOOP1 ---
  CX     INC16
  EBX AX MOVR2M16
  EBX    INC32
  EBX    INC32
  AH     INC8
  CX  DX CMPI16
LOOP1 >>> JMPZ

\ Write "impexus"
EBX $B8000 MOVI32
AH  $F     MOVI8

AL  'i'    MOVI8
EBX AX     MOVR2M16

EBX        INC32
EBX        INC32
AL  'm'    MOVI8
EBX AX     MOVR2M16

EBX        INC32
EBX        INC32
AL  'p'    MOVI8
EBX AX     MOVR2M16

EBX        INC32
EBX        INC32
AL  'e'    MOVI8
EBX AX     MOVR2M16

EBX        INC32
EBX        INC32
AL  'x'    MOVI8
EBX AX     MOVR2M16

EBX        INC32
EBX        INC32
AL  'u'    MOVI8
EBX AX     MOVR2M16

EBX        INC32
EBX        INC32
AL  's'    MOVI8
EBX AX     MOVR2M16

HLT

HERE ASSEMBLY_END !

COMPILE
BYE
