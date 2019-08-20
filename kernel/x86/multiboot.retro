#Multiboot header for x86 nga

The memory layout:
| Description         | Start  | End     |
|----------------- ---+--------+---------|
| Nga Parameter stack | 0x7e00 | 0x81e8  |
| Nga Return stack    | 0x81ec | 0x85d4  |
| VM  Return stack    | 0x85d8 | 0x89c0  |
| Nga and code        | 0x9000 | 0x7FFFF |

~~~
'mb:Start var #32 allot
'mb:Here  var

&mb:Start !mb:Here

:mb:store (n-)
  @mb:Here store-next !mb:Here
;
 
:mb:store32 (n-)
  dup           mb:store
  dup #8  shift mb:store
  dup #16 shift mb:store
      #24 shift mb:store
;

#464367618         'MAGIC const
#65536             'FLAGS const
#0 MAGIC FLAGS + - 'CHECK const
#36864             'HDRADDR const
#36864             'LODADDR const
#0                 'LENADDR const
#0                 'BSSADDR const
#32 #36864 +       'ENTADDR const

MAGIC mb:store32
FLAGS mb:store32
CHECK mb:store32
HDRADDR mb:store32
LODADDR mb:store32
LENADDR mb:store32
BSSADDR mb:store32
ENTADDR mb:store32

~~~
