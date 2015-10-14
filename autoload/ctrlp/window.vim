" Window extension for CtrlP
"
" Maintainer:   DeaR <nayuri@kuonn.mydns.jp>
" Last Change:  14-Oct-2015.
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

function! s:tabpagewinnr(tabnr, ...)
  if a:tabnr == tabpagenr()
    if a:0 == 0 && exists('s:crwinnr')
      return s:crwinnr
    elseif get(a:000, 0) == '#' && exists('s:prvwinnr')
      return s:prvwinnr
    elseif get(a:000, 0) == '$'
      return tabpagewinnr(a:tabnr, '$') - 1
    endif
  endif
  return call('tabpagewinnr', [a:tabnr] + a:000)
endfunction

function! s:process(tabnr, winnr, bufnr)
  let name = bufname(a:bufnr)
  let fname = fnamemodify(
  \ empty(name) ? ('[' . a:bufnr . '*No Name]') : name, ':.')
  let idc =
  \ s:tabpagewinnr(a:tabnr)      == a:winnr ? '%' :
  \ s:tabpagewinnr(a:tabnr, '#') == a:winnr ? '#' : ' '
  return a:tabnr . ':' . a:winnr . ' ' . idc . " \t|" . fname . '|'
endfunction

function! s:syntax()
  if !ctrlp#nosy()
    call ctrlp#hicheck('CtrlPBufName', 'Directory')
    call ctrlp#hicheck('CtrlPTabExtra', 'Comment')
    syntax match CtrlPBufName '\t|\zs[^|]\+\ze|$'
    syntax match CtrlPTabExtra '\zs\t.*\ze$' contains=CtrlPBufName
  endif
endfunction

function! ctrlp#window#init(bufnr)
  let tabnr = exists('s:tabnr') ? s:tabnr : tabpagenr()
  let tabs = exists('s:clmode') && s:clmode ?
  \ range(1, tabpagenr('$')) : [tabnr]
  call filter(tabs, 'v:val > 0')
  let wins = []
  for each in tabs
    call extend(wins, map(filter(tabpagebuflist(each),
    \ 'v:val != a:bufnr'), 's:process(each, v:key + 1, v:val)'))
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
  let s:crwinnr  = winnr()
  let s:prvwinnr = winnr('#')
  return s:id
endfunction

function! ctrlp#window#exit()
  unlet! s:clmode s:tabnr s:crwinnr s:prvwinnr
endfunction
