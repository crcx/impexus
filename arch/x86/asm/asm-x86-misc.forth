# x86 assembly - Miscellanous commands

push - Push register value to return stack
pop  - Pop  return stack value to register
hlt  - Halt the processor
~~~

:asm:push (r-)
  rv? #80 + asm:store
;

:asm:pop (r-)
  rv? #88 + asm:store
;

:asm:hlt (-)
  #244 asm:store
;

~~~
