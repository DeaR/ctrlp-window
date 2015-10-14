" Window extension for CtrlP
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  14-Oct-2015.
" License:      Vim License  (see :help license)

command! -nargs=?
\ CtrlPWindow
\ call ctrlp#init(ctrlp#window#cmd(0, <q-args>))
command! -nargs=?
\ CtrlPWindowAll
\ call ctrlp#init(ctrlp#window#cmd(1))
