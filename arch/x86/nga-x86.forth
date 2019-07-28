# Nga for x86
~~~

'multiboot.forth include
'asm-x86.forth include

~~~
First of all, we take care of the memory layout of the stacks.
PS: Nga's Parameter Stack
RS: Nga's Return Stack
VR: The VM's Return Stack
~~~

#6000 'PS-TOP const
#7000 'PS-BOTTOM const

#7004 'RS-TOP const
#8004 'RS-BOTTOM const

#9008  'VR-TOP const
#10008 'VR-BOTTOM const

#32 'nga:codeoffset     var<n>

~~~
Register definitions.
The instruction pointer counts bytes while Nga uses 32-bit cells for addressing.
To get from IP to Nga addresses, divide IP by 4 (IP #2 asm:shl)
~~~

EAX 'TOS const (Top_Of_Stack)
EBX 'SOS const (Second_Of_Stack)
ECX 'PSP const (Parameter_Stack_Pointer)
EDX 'RSP const (Return_Stack_Pointer)

ESI 'TMP  const (Temporary)

EBP 'IP  const (Instruction_Pointer)
EDI 'NB  const (Next_Block)

ESP 'VMRS const (VM_Return_Stack)

~~~
This function takes a pointer to a label and writes its offset to memory.
~~~

:asm:phyaddr (a-)
  fetch @nga:codeoffset +
;
  
:asm:reladdr (a-)
  fetch asm:currpos - #4 -
;

:asm:jumpentry (a-)
  asm:phyaddr asm:store32
;

~~~
Labels are defined, which match the possible Nga opcodes.
~~~

'nga:nop       var 
'nga:lit       var 
'nga:dup       var 
'nga:drop      var 
'nga:swap      var 
'nga:push      var 
'nga:pop       var 
'nga:jump      var 
'nga:call      var 
'nga:ccall     var 
'nga:ret       var 
'nga:eq        var 
'nga:neq       var 
'nga:lt        var 
'nga:gt        var 
'nga:fetch     var 
'nga:store     var 
'nga:add       var 
'nga:sub       var 
'nga:mul       var 
'nga:divmod    var 
'nga:and       var 
'nga:or        var 
'nga:xor       var 
'nga:shift     var 
'nga:zret      var 
'nga:end       var 
'nga:ienum     var 
'nga:iquery    var 
'nga:iinteract var 

~~~
This is followed by various labels used throughout the source code.
~~~

'nga:entry              var
'nga:jumptable          var
'nga:memoffset          var

'err:undef-error        var

'aux:stack-push         var
'aux:stack-pull         var

'ps-push-lt-2           var
'ps-pull-lt-2           var

'no-increment           var

'screen-offset          var

'aux:no-call            var
'aux:true               var
'aux:false              var
'aux:not-zero           var
'aux:mainloop           var

:asm (-------------------------------------------------------------------------)  

nga:entry asm:jmp

err:undef-error asm:label
  asm:hlt

aux:stack-push asm:label (Drop)
  PSP PS-TOP asm:cmpi
  err:undef-error asm:je  (Stack_overflow)
  PSP #4 asm:subi
  PSP PS-BOTTOM #8 - asm:cmpi
  ps-push-lt-2 asm:jl
    PSP SOS asm:movr2m
  ps-push-lt-2 asm:label
  SOS TOS asm:movr
  asm:ret

aux:stack-pull asm:label (Dup)
  PSP PS-BOTTOM asm:cmpi
  err:undef-error asm:je  (Stack_underflow)
  TOS SOS asm:movr
  PSP PS-BOTTOM #8 - asm:cmpi
  ps-pull-lt-2 asm:jl
    SOS PSP asm:movm2r
  ps-pull-lt-2 asm:label
  PSP #4 asm:addi
  asm:ret

aux:false asm:label
  aux:stack-pull asm:call
  TOS #0 asm:movi
  asm:ret

aux:true asm:label
  aux:stack-push asm:call
  TOS #-1 asm:movi
  asm:ret

~~~
The Nga operations:
~~~

nga:nop asm:label
  asm:ret

nga:lit asm:label
  aux:stack-push asm:call
  TOS NB  asm:movr
  TOS nga:memoffset asm:phyaddr asm:addi
  TOS TOS asm:movm2r
  NB  #4  asm:addi
  asm:ret
  
nga:dup asm:label
  aux:stack-push asm:call
  (TOS_already_SOS)
  asm:ret

nga:drop asm:label
  aux:stack-pull asm:call
  asm:ret

nga:swap      asm:label
  TOS SOS asm:xorr
  SOS TOS asm:xorr
  TOS SOS asm:xorr
  asm:ret

nga:push asm:label
  RSP RS-TOP asm:cmpi
  err:undef-error asm:je (Stack_overflow)
  RSP #4  asm:subi
  RSP TOS asm:movr2m
  aux:stack-pull asm:call
  asm:ret

nga:pop asm:label
  RSP RS-BOTTOM asm:cmpi
  err:undef-error asm:je (Stack_underflow)
  aux:stack-push asm:call
  RSP TOS asm:movr2m
  RSP #4  asm:addi
  asm:ret

nga:jump asm:label
  IP TOS asm:movr
  IP #4  asm:muli
  NB IP  asm:movr
  IP #1  asm:subi
  aux:stack-pull asm:call
  asm:ret
  
nga:call  asm:label
  RSP #4  asm:subi
  RSP IP  asm:movr2m
  nga:jump asm:call
  asm:ret

nga:ccall asm:label (Ta-)
  SOS #0  asm:cmpi
  aux:no-call asm:jne
    nga:call asm:call
  aux:no-call asm:label
  aux:stack-pull asm:call
  aux:stack-pull asm:call
  asm:ret

nga:ret asm:label
  IP RSP asm:movm2r
  IP  #4 asm:muli
  IP  #1 asm:subi
  RSP #4 asm:addi
  asm:ret
  
nga:eq asm:label
  TOS SOS asm:cmpr
  aux:true asm:je
  aux:false asm:jmp

nga:neq asm:label
  TOS SOS asm:cmpr
  aux:true asm:jne
  aux:false asm:jmp

nga:lt asm:label
  TOS SOS   asm:cmpr
  aux:true  asm:jl
  aux:false asm:jmp

nga:gt        asm:label
  TOS SOS   asm:cmpr
  aux:true  asm:jg
  aux:false asm:jmp
  
nga:fetch     asm:label
  (TBD:_Implement_negative_introspection)
  TOS @nga:memoffset @nga:codeoffset + asm:addi
  TOS TOS                              asm:movm2r
  asm:ret
  
nga:store     asm:label
  TOS @nga:memoffset  @nga:codeoffset + asm:addi
  TOS SOS                               asm:movr2m
  aux:stack-pull                        asm:call
  aux:stack-pull                        asm:call
  asm:ret
  
nga:add       asm:label
  SOS TOS        asm:addr
  aux:stack-pull asm:call
  asm:ret

nga:sub       asm:label
  TOS SOS        asm:subr
  SOS TOS        asm:movi
  aux:stack-pull asm:call
  asm:ret

nga:mul       asm:label 
  SOS TOS        asm:mulr
  aux:stack-pull asm:call
  asm:ret

nga:divmod    asm:label
  EDX asm:push
  SOS asm:idivr
  (EAX_is_TOS)
  SOS EDX asm:movr
  EDX asm:pop
  asm:ret

nga:and       asm:label
  SOS TOS        asm:andr
  aux:stack-pull asm:call
  asm:ret

nga:or        asm:label
  SOS TOS        asm:orr
  aux:stack-pull asm:call
  asm:ret
  
nga:xor       asm:label
  SOS TOS        asm:xorr
  aux:stack-pull asm:call
  asm:ret

nga:shift     asm:label
  ECX asm:push
  SOS ECX asm:movr
  SOS TOS asm:movr
  SOS asm:shrr
  aux:stack-pull asm:call
  ECX asm:pop
  asm:ret

nga:zret      asm:label
  TOS #0 asm:cmpi
  aux:not-zero asm:jne
    aux:stack-pull asm:call
    IP RSP asm:movm2r
    IP  #4 asm:muli
    IP  #1 asm:subi
    RSP #4 asm:addi
  aux:not-zero asm:label
  asm:ret

nga:end       asm:label
  asm:hlt

nga:ienum     asm:label
  aux:stack-push asm:call
  TOS #1         asm:movi
  asm:ret

nga:iquery    asm:label
  aux:stack-push asm:call
  asm:ret

screen-offset asm:label
#753664 asm:store32

nga:iinteract asm:label
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

~~~
Jump table:
~~~
nga:jumptable asm:label
nga:nop       asm:jumpentry (0)
nga:lit       asm:jumpentry (1)
nga:dup       asm:jumpentry (2)
nga:drop      asm:jumpentry (3)
nga:swap      asm:jumpentry (4)
nga:push      asm:jumpentry (5)
nga:pop       asm:jumpentry (6)
nga:jump      asm:jumpentry (7)
nga:call      asm:jumpentry (8)
nga:ccall     asm:jumpentry (9)
nga:ret       asm:jumpentry (10)
nga:eq        asm:jumpentry (11)
nga:neq       asm:jumpentry (12)
nga:lt        asm:jumpentry (13)
nga:gt        asm:jumpentry (14)
nga:fetch     asm:jumpentry (15)
nga:store     asm:jumpentry (16)
nga:add       asm:jumpentry (17)
nga:sub       asm:jumpentry (18)
nga:mul       asm:jumpentry (19)
nga:divmod    asm:jumpentry (20)
nga:and       asm:jumpentry (21)
nga:or        asm:jumpentry (22)
nga:xor       asm:jumpentry (23)
nga:shift     asm:jumpentry (24)
nga:zret      asm:jumpentry (25)
nga:end       asm:jumpentry (26)
nga:ienum     asm:jumpentry (27)
nga:iquery    asm:jumpentry (28)
nga:iinteract asm:jumpentry (29)

nga:entry asm:label
  TOS  #0          asm:movi
  SOS  #0          asm:movi
  PSP  PS-BOTTOM   asm:movi
  RSP  RS-BOTTOM   asm:movi
  VMRS VR-BOTTOM   asm:movi
  IP   #0          asm:movi
  TMP  #753664     asm:movi
  NB   #4          asm:movi
  
  aux:mainloop asm:label
    TMP IP asm:movr
    TMP nga:memoffset asm:phyaddr asm:addi (IP=op-address)
    
    TMP TMP asm:movm2r (IP=op_and_garbage)
    TMP #255 asm:andi (Strip_away_garbage)
    TMP #4 asm:muli   (IP=op*4)
    TMP nga:jumptable asm:phyaddr asm:addi
    TMP TMP asm:movm2r (IP=code-addr)
    
    TMP asm:callr
    
    TOS asm:push
    
    IP #1 asm:addi
    
    TOS IP asm:movr
    TOS #3 asm:andi
    
    TOS #0 asm:cmpi
    no-increment asm:jne
      IP NB asm:movr
      NB #4 asm:addi
    no-increment asm:label
       TOS asm:pop
    aux:mainloop asm:jmp
    
  #4 asm:currpos @nga:codeoffset + #4 mod - [ asm:hlt ] times

  nga:memoffset asm:label
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
