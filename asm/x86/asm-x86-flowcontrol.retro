# x86 assembly - Flow control commands

Compare operations for 32-bit registers:
cmpi   - Compare register to value
cmpr   - Compare register contents
~~~

:asm:cmpi (rn-)
  swap rv? #129 asm:store
  #248 + asm:store
  asm:store32
;

:asm:cmpr (rr-)
  rv? swap rv? #57 asm:store
  #192 + swap #8 * + asm:store
;

~~~
Compare operations for 8-bit registers:
cmpi8   - Compare register to value
cmpr8   - Compare register contents
~~~

:asm:cmpi8 (rn-)
  swap rv? #128 asm:store
  #248 + asm:store
  asm:store
;

:asm:cmpr8 (rr-)
  rv? swap rv? #56 asm:store
  #192 + swap #8 * + asm:store
;

~~~
Jumps to be used after compares:
  je     - Jump if equal
  jne    - Jump if not equal
  jl     - Jump if less than
  jgt    - Jump if greater than
  
Other control flow:
  jmp    - Unconditional jump
  call   - Perform a function call
  ret    - Return from call
~~~

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

:asm:call (a-)
  fetch
  #232 asm:store
  asm:currpos - #4 -
  asm:store32
;

:asm:callr (r-)
  #255 asm:store
  #208 + asm:store
;

:asm:ret (-)
  #195 asm:store
;

~~~
