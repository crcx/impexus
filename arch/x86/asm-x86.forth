# A x86 assembler in RETRO

This is an x86 assembler wrapper written in RETRO forth. The assembly code 
itself is also valid RETRO forth, which simplifies parsing a lot.

The operands are in the same order as the Intel syntax, the command 
itself is prefixed though. Example:
ADD 12, EBX      (Intel)
#12 EBX asm:addi (RETRO)

Naming conventions:
Commands that work on two registers have an "r" prefix, e.g. subr.
Commands that work on a register and an immediate have an "i" prefix, e.g. subi.
Flow control commands that work on addresses and haven't got any special prefix.

All the commands and helpers are defined in the following included files:
~~~

'asm/asm-x86-common.forth      include
'asm/asm-x86-arithmetic.forth  include
'asm/asm-x86-bitwise.forth     include
'asm/asm-x86-flowcontrol.forth include
'asm/asm-x86-misc.forth        include
'asm/asm-x86-mov.forth         include

~~~

Acknowledgements:
Thanks to 
* http://ref.x86asm.net/ for their great reference tables.
* https://defuse.ca/online-x86-assembler.htm for their online assembler, without
  which figuring out some peculiar opcodes would have been very complicated.
