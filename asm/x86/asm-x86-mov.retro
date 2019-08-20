# x86 assembly - Move commands

Move commands for 32-bit registers:
movi   - Move immediate to register
movr   - Move register value to register
movr2m - Move register value to memory
movm2r - Move memory content to register
~~~

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
  dup EBP eq? [
    rv? swap rv? #139 asm:store
    #8 * + #64 + asm:store #0 asm:store
  ] if;
  
  rv? swap rv? #139 asm:store
  #8 * + asm:store
;

~~~
Move commands for 8-bit registers:
movi8   - Move immediate to register
movr8   - Move register value to register
movr2m8 - Move register value to memory
movm2r8 - Move memory content to register
~~~

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
  dup EBP eq? [
    rv? swap rv? #139 asm:store
    #8 * + #64 + asm:store #0 asm:store
  ] if;
  rv? swap rv? #138 asm:store
  #8 * + asm:store
;
