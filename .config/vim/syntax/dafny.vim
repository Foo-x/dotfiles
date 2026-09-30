if exists('b:current_syntax')
  finish
endif

syn keyword dafnyDecl module import export include opened abstract refines class trait datatype codatatype newtype type iterator extends const var ghost static
syn keyword dafnyDecl method function predicate lemma twostate least greatest constructor
syn keyword dafnySpec requires ensures reads modifies decreases invariant yields provides reveals witness
syn keyword dafnyStatement if else then while for match case return yield break continue assert assume expect calc by print reveal fresh old unchanged allocated
syn keyword dafnyStatement forall exists in as is with to downto label modify new this
syn keyword dafnyBoolean true false
syn keyword dafnyConstant null
syn keyword dafnyType bool char int nat real string object array set iset multiset seq map imap ORDINAL bv0
syn match dafnyType '\<bv[1-9][0-9]*\>'
syn match dafnyType '\<array[1-9][0-9]*\>'
syn keyword dafnyTodo TODO FIXME XXX contained

syn match dafnyNumber '\<[0-9][0-9_]*\>'
syn match dafnyNumber '\<[0-9][0-9_]*\.[0-9][0-9_]*\>'
syn match dafnyNumber '\<0x[0-9a-fA-F_]\+\>'

syn match dafnyEscape '\\\%([nrt0\\"'"'"']\|u\x\{4}\|U{\x\+}\)' contained
syn region dafnyString start='"' skip='\\.' end='"' contains=dafnyEscape
syn region dafnyString start='@"' skip='""' end='"'
syn match dafnyChar "'\%([^\\']\|\\.\|\\u\x\{4}\)'" contains=dafnyEscape

syn match dafnyOperator '==>\|<==>\|<==\|&&\|||\|!=\|<=\|>=\|:=\|:|\|::\|=>\|==\|!!\|<<\|>>'

syn region dafnyAttribute start='{:' end='}' contains=dafnyString,dafnyNumber,dafnyBoolean

syn region dafnyComment start='/\*' end='\*/' contains=dafnyTodo,@Spell fold
syn match dafnyComment '//.*$' contains=dafnyTodo,@Spell

hi def link dafnyDecl Keyword
hi def link dafnySpec PreProc
hi def link dafnyStatement Statement
hi def link dafnyBoolean Boolean
hi def link dafnyConstant Constant
hi def link dafnyType Type
hi def link dafnyTodo Todo
hi def link dafnyNumber Number
hi def link dafnyEscape SpecialChar
hi def link dafnyString String
hi def link dafnyChar Character
hi def link dafnyOperator Operator
hi def link dafnyAttribute Special
hi def link dafnyComment Comment

let b:current_syntax = 'dafny'
