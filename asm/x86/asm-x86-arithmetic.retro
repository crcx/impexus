# x86 assembly - Arithmetic commands

The commands using 32 bit registers are:
addi   - Add immediate to register
addr   - Add register value to register
subi   - Subtract immediate from register
subr   - Subtract register value from register
muli   - Multiply immediate with register
mulr   - Multiply register with register
divr   - Unsigned divide EDX:EAX by register, quotient in EAX, remainder in EDX
idivr  - Signed   divide EDX:EAX by register, quotient in EAX, remainder in EDX
~~~

:asm:addi (rn-)
  #129 asm:store 
  swap rv? #192 + asm:store asm:store32
;

:asm:addr (rr-)
  rv? swap rv? #1 asm:store
  #192 + swap #8 * + asm:store
;

:asm:subi (rn-)
  #129 asm:store 
  swap rv? #232 + asm:store asm:store32
;

:asm:subr (rr-)
  rv? swap rv? #41 asm:store
  #192 + swap #8 * + asm:store
;

:asm:muli (rn-)
  swap rv? #105 asm:store 
  dup #192 + swap #8 * + asm:store
  asm:store32
;

:asm:mulr (rr-)
  rv? swap rv? #15 asm:store #175 asm:store
  swap #192 + swap #8 * + asm:store
;

:asm:divr (r-)
  rv? #247 asm:store
  #240 + asm:store
;
  
:asm:idivr (r-)
  rv? #247 asm:store
  #248 + asm:store
;

~~~
The commands using 8 bit registers are:
addi8   - Add immediate to register
addr8   - Add register value to register
~~~

:asm:addi8 (rn-)
  #128 asm:store
  swap rv? #192 + asm:store asm:store
;

:asm:addr8 (rr-)
  rv? swap rv? #0 asm:store
  #192 + swap #8 * + asm:store
;

~~~
