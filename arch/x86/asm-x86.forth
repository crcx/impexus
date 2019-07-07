# A x86 assembler

This is an x86 assembler wrapper written in RETRO forth.
The assembly code itself is also valid RETRO forth, which simplifies
parsing a lot.

The operands are in the same order as the Intel syntax, the command 
itself is prefixed though. Example:
ADD 12, EBX (Intel)
#12 EBX ADD (RETRO)

We begin by defining the register constants for 32 bit and 8 bit registers.
~~~

#0 'EAX const
#1 'ECX const
#2 'EDX const
#3 'EBX const
#4 'ESP const
#5 'EBP const
#6 'ESI const
#7 'EDI const

#0 'AL const
#1 'CL const
#2 'DL const
#3 'BL const
#4 'AH const
#5 'CH const
#6 'DH const
#7 'BH const

~~~
Helper variables:
  asm:Code    : Pointer to the start of the machine code in memory
  asm:Here    : Stores the memory location of the current write position
Helper words:
  asm:store   : Stores 8 bit in a memory location and advance to next cell
  asm:store32 : Stores 32 bit (little endian) and advance 4 cells
  rv?         : Is the given register ID valid?
  asm:currpos : The current offset from asm:Code
  asm:label   : Set value at given address to the current offset
~~~

'asm:Code var #4000 allot
'asm:Here var &asm:Code !asm:Here

:asm:store (n-)
  @asm:Here store-next !asm:Here
;

:asm:store32 (n-)
  dup           asm:store
  dup #8  shift asm:store
  dup #16 shift asm:store
      #24 shift asm:store
;

:rv? (n-n)
  dup dup #0 lt? swap #7 gt? or
  [ 'Invalid_register:_ s:put n:put nl bye ] if
;

:asm:currpos (-n)
  @asm:Here &asm:Code -
;

:asm:label (a-)
  asm:currpos swap store
;

~~~
The commands using 32 bit registers are:
addi   - Add immediate to register
addr   - Add register value to register
movi   - Move immediate to register
movr   - Move register value to register
movr2m - Move register value to memory
movm2r - Move memory content to register
cmpr   - Compare register contents (jumps as follow)
cmpi   - Compare register to value (jumps as follow)
  je     - Jump if equal
  jne    - Jump if not equal
  jl     - Jump if less than
  jgt    - Jump if greater than
jmp    - Unconditional jump
ret    - Return from call
hlt    - Halt the processor
~~~

:asm:addi (rn-)
  #129 asm:store 
  swap rv? #192 + asm:store asm:store32
;

:asm:addr (rr-)
  rv? swap rv? #1 asm:store
  #192 + swap #8 * + asm:store
;

:asm:movi (rn-)
  swap rv? #184 +  asm:store
  asm:store32
;

:asm:movr (rr-)
  rv? swap rv? #137 asm:store
  #192 + swap #8 * + asm:store
;

:asm:movr2m (rr-)
  rv? swap rv? #137 asm:store
  swap #8 * + asm:store
;

:asm:movm2r (rr-)
  rv? swap rv? #139 asm:store
  #8 * + asm:store
;

:asm:cmpr (rr-)
  rv? swap rv? #57 asm:store
  #192 + swap #8 * + asm:store
;

:asm:cmpi (rn-)
  swap rv? #129 asm:store
  #248 + asm:store
  asm:store32
;

:asm:je  (a-)
  fetch
  #15 asm:store
  #132 asm:store
  asm:currpos - #4 -
  asm:store32
;

:asm:jne (a-)
  fetch
  #15 asm:store
  #133 asm:store
  asm:currpos - #4 -
  asm:store32
;

:asm:jl (a-)
  fetch
  #15 asm:store
  #140 asm:store
  asm:currpos - #4 -
  asm:store32
;

:asm:jg (a-)
  fetch
  #15 asm:store
  #143 asm:store
  asm:currpos - #4 -
  asm:store32
;

:asm:jmp (a-)
  fetch
  #233 asm:store
  asm:currpos - #4 -
  asm:store32
;

:asm:ret (-)
  #195 asm:store
;

:asm:hlt (-)
  #244 asm:store
;

~~~
The commands using 8 bit registers are:
addi8   - Add immediate to register
addr8   - Add register value to register
movi8   - Move immediate to register
movr8   - Move register value to register
movr2m8 - Move register value to memory
movm2r8 - Move memory content to register
cmpr8   - Compare register contents (jumps as with 32 bit)
cmpi8   - Compare register to value (jumps as with 32 bit)
~~~

:asm:addi8 (rn-)
  #128 asm:store 
  swap rv? #192 + asm:store asm:store
;

:asm:addr8 (rr-)
  rv? swap rv? #0 asm:store
  #192 + swap #8 * + asm:store
;

:asm:movi8 (rn-)
  swap rv? #176 + asm:store
  asm:store
;

:asm:movr8 (rr-)
  rv? swap rv? #136 asm:store
  #192 + swap #8 * + asm:store
;

:asm:movr2m8 (rr-)
  rv? swap rv? #136 asm:store
  swap #8 * + asm:store
;

:asm:movm2r8 (rr-)
  rv? swap rv? #138 asm:store
  #8 * + asm:store
;

:asm:cmpr8 (rr-)
  rv? swap rv? #56 asm:store
  #192 + swap #8 * + asm:store
;

:asm:cmpi8 (rn-)
  swap rv? #128 asm:store
  #248 + asm:store
  asm:store
;

~~~
