scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal expandtab
setlocal tabstop=4 shiftwidth=0

nnoremap <buffer><silent> <C-C> :<C-U>call tanikawa#weekly_report#Copy()<CR>
nnoremap <buffer><silent> <C-K> :<C-U>call tanikawa#weekly_report#AppendWorkTimeCol()<CR>
inoremap <buffer><silent> <C-K> <C-O>:<C-U>call tanikawa#weekly_report#AppendWorkTimeCol()<CR>

let b:undo_ftplugin = "setl et< ts< sw<"
