# VGA textmode prototype for x86

~~~
'textmode:ii   var
'textmode:iq   var
'screen-offset var

:textmode:asm
  screen-offset asm:label
    #753664 asm:store32
    
  textmode:ii asm:label
    TMP asm:push
  
    TMP screen-offset asm:phyaddr asm:movi
    TMP TMP asm:movm2r
  
    TMP AL  asm:movr2m8
    TMP #1 asm:addi
    EAX #12 asm:movi
    TMP AL  asm:movr2m8
    TMP #1 asm:addi
    
    EAX screen-offset asm:phyaddr asm:movi
    EAX TMP asm:movr2m
  
    aux:stack-pull asm:call
    TMP asm:pop
    
    asm:ret
  
  textmode:iq asm:label (-vn)
    aux:stack-push asm:call
    aux:stack-push asm:call
    TOS #0 asm:movi
    SOS #0 asm:movi
    asm:ret
;

~~~
