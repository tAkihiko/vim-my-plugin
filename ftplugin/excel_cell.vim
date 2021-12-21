scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal expandtab noendofline nofixendofline
set fenc=cp932

let b:undo_ftplugin = "setlocal et< eol< fixeol<"
