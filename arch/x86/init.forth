# Code to thest the assembler
~~~

'multiboot.forth include
'asm-x86.forth include

'printloop var

:asm (-------------------------------------------------------------------------)

EAX #753664 asm:movi (0xb8000)
BL #32      asm:movi8 (space_character)
BH #15      asm:movi8 (white)

printloop asm:label
  EAX BL    asm:movr2m8
  EAX #1    asm:addi
  EAX BH    asm:movr2m8
  EAX #1    asm:addi
  
  BL  #1    asm:addi8
  BL  #127  asm:cmpi8
  printloop asm:jne

asm:hlt

;
(------------------------------------------------------------------------------)

~~~
Run through the code twice. First time for labels, second time for code
~~~

&asm:Code !asm:Here
asm
&asm:Code !asm:Here
asm

~~~
Writing to a file:
~~~
'outfile var
'kernel file:W file:open !outfile

#32         [ &mb:Start I + fetch @outfile file:write ] times<with-index>
asm:currpos [ &asm:Code I + fetch @outfile file:write ] times<with-index>

@outfile file:close 

'[DONE] s:put nl
