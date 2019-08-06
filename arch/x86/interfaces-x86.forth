# Nga interfaces for x86

Necessary labels:
~~~

'interfaces:table     var
'interfaces:table-end var
'interfaces:Count     var

~~~
Included interfaces:
~~~

'interfaces/textmode.forth include

~~~
To add a new interface:
1. Include the source file above
2. Add the :asm section of the interface to the interfaces:asm word
3. Add the :ii and :iq words to the interfaces:table
~~~

:interfaces:asm
  textmode:asm

  interfaces:table asm:label
    textmode:ii asm:jmp (|) textmode:iq asm:jmp
  interfaces:table-end asm:label
  
  @interfaces:table-end @interfaces:table - #10 / !interfaces:Count
  
;

~~~
