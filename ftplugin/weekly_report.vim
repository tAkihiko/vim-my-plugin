scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal expandtab
setlocal tabstop=4 shiftwidth=0

nnoremap <buffer><silent> <C-C> :%y*<CR>

let b:undo_ftplugin = "setl et< ts< sw<"
