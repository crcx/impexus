# x86 assembly - Common definitions and helpers

Register constants for 32 bit and 8 bit registers:
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
