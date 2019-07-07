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
#0                 'HDRADDR const
#0                 'LODADDR const
#0                 'LENADDR const
#0                 'BSSADDR const
#32                'ENTADDR const

MAGIC mb:store32
FLAGS mb:store32
CHECK mb:store32
HDRADDR mb:store32
LODADDR mb:store32
LENADDR mb:store32
BSSADDR mb:store32
ENTADDR mb:store32

~~~
