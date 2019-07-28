# x86 assembly - Bitwise operation commands

The commands using 32 bit registers are:
andi   - AND a register and an immediate
andr   - AND two registers
ori    - OR a register and an immediate
orr    - OR two registers
xori   - XOR a register and an immediate
xorr   - XOR two registers
shri   - Shift register right by immediate
shrr   - Shift register right by value in CL
shli   - Shift register left  by immediate
shlr   - Shift register left  by value in CL
~~~

:asm:andi (rn-)
  #129 asm:store 
  swap rv? #224 + asm:store asm:store32
;

:asm:andr (rr-)
  rv? swap rv? #33 asm:store
  #192 + swap #8 * + asm:store
;

:asm:ori (rn-)
  #129 asm:store 
  swap rv? #200 + asm:store asm:store32
;

:asm:orr (rr-)
  rv? swap rv? #9 asm:store
  #192 + swap #8 * + asm:store
;

:asm:xori (rn-)
  #129 asm:store 
  swap rv? #192 + asm:store asm:store32
;

:asm:xorr (rr-)
  rv? swap rv? #49 asm:store
  #192 + swap #8 * + asm:store
;

:asm:shri (rn-)
  #193 asm:store
  swap rv? #232 + asm:store asm:store
;

:asm:shrr (r-)
  rv? #211 asm:store
  #232 + asm:store
;

:asm:shli (rn-)
  #193 asm:store
  swap rv? #224 + asm:store asm:store
;

:asm:shlr (r-)
  rv? #211 asm:store
  #224 + asm:store
;

~~~
