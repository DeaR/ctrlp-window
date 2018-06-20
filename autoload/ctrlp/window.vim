" Window extension for CtrlP
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  20-Jun-2018.
" License:      Vim License  (see :help license)

if exists('g:loaded_ctrlp_window') && g:loaded_ctrlp_window
  finish
endif
let g:loaded_ctrlp_window = 1

call add(g:ctrlp_ext_vars, {
\ 'init'   : 'ctrlp#window#init(s:bufnr)',
\ 'accept' : 'ctrlp#window#accept',
\ 'lname'  : 'window',
\ 'sname'  : 'win',
\ 'exit'   : 'ctrlp#window#exit()',
\ 'type'   : 'line'})

let s:id = g:ctrlp_builtins + len(g:ctrlp_ext_vars)

let s:tabnr_width = 2
let s:winnr_width = 2

function! s:compmreb(...)
  return ctrlp#call('s:compmreb', a:1[1], a:2[1])
endfunction

function! s:winparts(tabnr, winnr, bufnr, parts)
  let idc  = (a:tabnr == tabpagenr() &&
  \           a:winnr == s:alwinnr       ? '#' : '')  " alternative
  let idc .= (getbufvar(a:bufnr, '&mod') ? '+' : '')  " modified
  let idc .= (getbufvar(a:bufnr, '&ma')  ? '' : '-')  " nomodifiable
  let idc .= (getbufvar(a:bufnr, '&ro')  ? '=' : '')  " readonly

  let hiflags  = (bufwinnr(a:bufnr) != -1    ? '*' : '')  " visible
  let hiflags .= (getbufvar(a:bufnr, '&mod') ? '+' : '')  " modified
  let hiflags .= (a:tabnr == tabpagenr() &&
  \               a:winnr == s:crwinnr       ? '!' : '')  " current

  return [idc, hiflags, a:parts[2], a:parts[3]]
endfunction

function! s:process(tabnr, winnr, bufnr)
  let parts = ctrlp#call('s:bufparts', a:bufnr)
  let parts = s:winparts(a:tabnr, a:winnr, a:bufnr, parts)
  let str = ''
  if !ctrlp#nosy() && ctrlp#getvar('s:has_conceal')
    let str .= printf(
    \ '<nr>%' . s:tabnr_width . 's</nr>:' .
    \ '<nr>%' . s:winnr_width . 's</nr>', a:tabnr, a:winnr)
    let str .= printf(' %-13s %s%-36s',
    \ '<bi>' . parts[0] . '</bi>',
    \ '<bn>' . parts[1], '{' . parts[2] . '}</bn>')
    if !empty(ctrlp#getvar('s:bufpath_mod'))
      let str .= printf('  %s', '<bp>' . parts[3] . '</bp>')
    endif
  else
    let str .= printf(
    \ '%' . s:tabnr_width . 's:' .
    \ '%' . s:winnr_width . 's', a:tabnr, a:winnr)
    let str .= printf(' %-5s %-30s',
    \ parts[0],
    \ parts[2])
    if !empty(ctrlp#getvar('s:bufpath_mod'))
      let str .= printf('  %s', parts[3])
    endif
  endif
  return str
endfunction

function! s:syntax()
  call ctrlp#syntax()
  if !ctrlp#nosy() && ctrlp#getvar('s:has_conceal')
    syntax region CtrlPBufferNr     concealends matchgroup=Ignore start='<nr>' end='</nr>'
    syntax region CtrlPBufferInd    concealends matchgroup=Ignore start='<bi>' end='</bi>'
    syntax region CtrlPBufferRegion concealends matchgroup=Ignore start='<bn>' end='</bn>'
    \ contains=CtrlPBufferHid,CtrlPBufferHidMod,CtrlPBufferVis,CtrlPBufferVisMod,CtrlPBufferCur,CtrlPBufferCurMod
    syntax region CtrlPBufferHid    concealends matchgroup=Ignore     start='\s*{' end='}' contained
    syntax region CtrlPBufferHidMod concealends matchgroup=Ignore    start='+\s*{' end='}' contained
    syntax region CtrlPBufferVis    concealends matchgroup=Ignore   start='\*\s*{' end='}' contained
    syntax region CtrlPBufferVisMod concealends matchgroup=Ignore  start='\*+\s*{' end='}' contained
    syntax region CtrlPBufferCur    concealends matchgroup=Ignore  start='\*!\s*{' end='}' contained
    syntax region CtrlPBufferCurMod concealends matchgroup=Ignore start='\*+!\s*{' end='}' contained
    syntax region CtrlPBufferPath   concealends matchgroup=Ignore start='<bp>' end='</bp>'
  endif
endfunction

function! ctrlp#window#init(bufnr)
  let tabnr = exists('s:tabnr') ? s:tabnr : tabpagenr()
  let tabs = exists('s:clmode') && s:clmode ?
  \ range(1, tabpagenr('$')) : [tabnr]
  call filter(tabs, 'v:val > 0')
  let wins = []
  for each in tabs
    call extend(wins, map(sort(filter(map(tabpagebuflist(each), '[v:key + 1, v:val]'),
    \ 'v:val[1] != a:bufnr && (each != tabpagenr() || v:val[0] != s:crwinnr)'), 's:compmreb'),
    \ 's:process(each, v:val[0], v:val[1])'))
  endfor
  call s:syntax()
  return wins
endfunction

function! ctrlp#window#accept(mode, str)
  let parts = matchlist(a:str, '^\(\d\+\):\(\d\+\)')
  if empty(parts)
    return
  endif
  call ctrlp#exit()
  execute 'tabnext' parts[1]
  execute parts[2] . 'wincmd w'
endfunction

function! ctrlp#window#cmd(mode, ...)
  let s:clmode = a:mode
  if a:0 && !empty(a:1)
    let s:clmode = 0
    let s:tabnr = a:1
  endif
  let s:crwinnr = winnr()
  let s:alwinnr = winnr('#')
  return s:id
endfunction

function! ctrlp#window#exit()
  unlet! s:clmode s:tabnr s:crwinnr s:alwinnr
endfunction
