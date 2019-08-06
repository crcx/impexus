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

#32256 'PS-TOP const
#33256 'PS-BOTTOM const

#33260 'RS-TOP const
#34260 'RS-BOTTOM const

#34264 'VR-TOP const
#35264 'VR-BOTTOM const

ENTADDR 'nga:codeoffset     var<n>

~~~
Register definitions.
The instruction pointer counts bytes while Nga uses 32-bit cells for addressing.
To get from IP to Nga addresses, divide IP by 4 (IP #2 asm:shri)
The NB register points to the next block and counts in 32-bit cells.
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

'shift-right            var

'screen-offset          var

'aux:no-call            var
'aux:true               var
'aux:false              var
'aux:not-zero           var
'aux:mainloop           var

'intr:psp-depth         var
'intr:rsp-depth         var
'intr:img-size          var

~~~
The interfaces are included, then the assembly for Nga is written.
~~~

'interfaces-x86.forth include

:asm (-------------------------------------------------------------------------)

nga:entry asm:jmp

interfaces:asm

err:undef-error asm:label
  asm:hlt

aux:stack-push asm:label (Dup)
  PSP PS-TOP #2 + asm:cmpi
  err:undef-error asm:jl  (Stack_overflow)
  PSP #4 asm:subi
  PSP PS-BOTTOM #8 - asm:cmpi
  ps-push-lt-2 asm:jg
    PSP SOS asm:movr2m
  ps-push-lt-2 asm:label
  SOS TOS asm:movr
  asm:ret

aux:stack-pull asm:label (Drop)
  PSP PS-BOTTOM #2 - asm:cmpi
  err:undef-error asm:jg  (Stack_underflow)
  TOS SOS asm:movr
  PSP PS-BOTTOM #8 - asm:cmpi
  ps-pull-lt-2 asm:jg
    SOS PSP asm:movm2r
  ps-pull-lt-2 asm:label
  PSP #4 asm:addi
  asm:ret

aux:false asm:label
  aux:stack-pull asm:call
  TOS #0 asm:movi
  asm:ret

aux:true asm:label
  aux:stack-pull asm:call
  TOS #-1 asm:movi
  asm:ret

intr:psp-depth asm:label
  TOS PS-BOTTOM asm:movi
  TOS PSP       asm:subr
  TOS #2        asm:shri
  TOS #1        asm:subi (This_function_uses_one_stack_element)
  asm:ret

intr:rsp-depth asm:label
  TOS RS-BOTTOM asm:movi
  TOS RSP       asm:subr
  TOS #2        asm:shri
  asm:ret

intr:img-size  asm:label
  TOS #30000    asm:movi
  asm:ret

~~~
The Nga operations:
~~~

nga:nop asm:label
  asm:ret

nga:lit asm:label
  aux:stack-push asm:call
  TOS NB  asm:movr
  TOS #4  asm:muli
  TOS nga:memoffset asm:phyaddr asm:addi
  TOS TOS asm:movm2r
  NB  #1  asm:addi
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
  TOS RSP asm:movm2r
  RSP #4  asm:addi
  asm:ret

nga:jump asm:label
  IP TOS asm:movr
  NB IP  asm:movr
  IP #4  asm:muli
  IP #1  asm:subi
  aux:stack-pull asm:call
  asm:ret

nga:call  asm:label
  RSP #4  asm:subi
  RSP NB  asm:movr2m
  nga:jump asm:call
  asm:ret

nga:ccall asm:label (Ta-)
  SOS #0  asm:cmpi
  aux:no-call asm:je
    nga:call asm:call
    aux:stack-pull asm:call
    asm:ret
  aux:no-call asm:label
  aux:stack-pull asm:call
  aux:stack-pull asm:call
  asm:ret

nga:ret asm:label
  NB RSP asm:movm2r
  IP NB  asm:movr
  IP #4  asm:muli
  IP #1  asm:subi
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
  SOS TOS   asm:cmpr
  aux:true  asm:jl
  aux:false asm:jmp

nga:gt        asm:label
  SOS TOS   asm:cmpr
  aux:true  asm:jg
  aux:false asm:jmp

nga:fetch     asm:label
  TOS #-1 asm:cmpi
  intr:psp-depth asm:je
  TOS #-2 asm:cmpi
  intr:rsp-depth asm:je
  TOS #-3 asm:cmpi
  intr:img-size  asm:je

  TOS #4 asm:muli
  TOS @nga:memoffset @nga:codeoffset + asm:addi
  TOS TOS                              asm:movm2r
  asm:ret

nga:store     asm:label
  TOS #4 asm:muli
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
  SOS TOS        asm:subr
  TOS SOS        asm:movi
  aux:stack-pull asm:call
  asm:ret

nga:mul       asm:label 
  SOS TOS        asm:mulr
  aux:stack-pull asm:call
  asm:ret

nga:divmod    asm:label
  TOS SOS asm:xorr
  SOS TOS asm:xorr
  TOS SOS asm:xorr
  EDX asm:push
      asm:cdq
  SOS asm:idivr
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
  ECX TOS asm:movr
  ECX #0  asm:cmpi
  shift-right asm:jg
    ECX #-1 asm:muli
    SOS asm:shlr
    ECX asm:pop
    aux:stack-pull asm:call
    asm:ret
  shift-right asm:label
  SOS asm:shrr
  ECX asm:pop
  aux:stack-pull asm:call
  asm:ret

nga:zret      asm:label
  TOS #0 asm:cmpi
  aux:not-zero asm:jne
    aux:stack-pull asm:call
    nga:ret asm:call
    asm:ret
  aux:not-zero asm:label
  asm:ret

nga:end       asm:label
  asm:hlt

nga:ienum     asm:label
  aux:stack-push asm:call
  TOS @interfaces:Count asm:movi
  asm:ret

nga:iquery    asm:label
    TMP TOS asm:movr
    aux:stack-pull asm:call
    TMP #5 asm:muli    (TMP=ID*5)
    TMP #5 asm:addi    (TMP=ID*5+5)
    TMP nga:jumptable asm:phyaddr asm:addi (TMP=juptable_address)
    TMP asm:callr
    asm:ret

nga:iinteract asm:label
  TMP TOS asm:movr
  aux:stack-pull asm:call
  TMP #5  asm:muli    (TMP=ID*5)
  TMP interfaces:table asm:phyaddr asm:addi (TMP=juptable_address)
  TMP asm:callr
  asm:ret

~~~
Jump table:
~~~
nga:jumptable asm:label
nga:nop       asm:jmp (0)
nga:lit       asm:jmp (1)
nga:dup       asm:jmp (2)
nga:drop      asm:jmp (3)
nga:swap      asm:jmp (4)
nga:push      asm:jmp (5)
nga:pop       asm:jmp (6)
nga:jump      asm:jmp (7)
nga:call      asm:jmp (8)
nga:ccall     asm:jmp (9)
nga:ret       asm:jmp (10)
nga:eq        asm:jmp (11)
nga:neq       asm:jmp (12)
nga:lt        asm:jmp (13)
nga:gt        asm:jmp (14)
nga:fetch     asm:jmp (15)
nga:store     asm:jmp (16)
nga:add       asm:jmp (17)
nga:sub       asm:jmp (18)
nga:mul       asm:jmp (19)
nga:divmod    asm:jmp (20)
nga:and       asm:jmp (21)
nga:or        asm:jmp (22)
nga:xor       asm:jmp (23)
nga:shift     asm:jmp (24)
nga:zret      asm:jmp (25)
nga:end       asm:jmp (26)
nga:ienum     asm:jmp (27)
nga:iquery    asm:jmp (28)
nga:iinteract asm:jmp (29)

nga:entry asm:label
  TOS  #0          asm:movi
  SOS  #0          asm:movi
  PSP  PS-BOTTOM   asm:movi
  RSP  RS-BOTTOM   asm:movi
  VMRS VR-BOTTOM   asm:movi
  IP   #0          asm:movi
  TMP  #753664     asm:movi
  NB   #1          asm:movi
  
  aux:mainloop asm:label
    TMP IP asm:movr
    TMP nga:memoffset asm:phyaddr asm:addi (TMP=op-address)
    
    TMP TMP asm:movm2r (TMP=op_and_garbage)
    TMP #255 asm:andi  (Strip_away_garbage)
    TMP #5 asm:muli    (TMP=op*5)
    TMP nga:jumptable asm:phyaddr asm:addi (TMP=juptable_address)
    
    TMP asm:callr
    
    TOS asm:push
    
    IP #1 asm:addi
    
    TOS IP asm:movr
    TOS #3 asm:andi
    
    TOS #0 asm:cmpi
    no-increment asm:jne
      IP NB asm:movr
      IP #4 asm:muli
      NB #1 asm:addi
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
