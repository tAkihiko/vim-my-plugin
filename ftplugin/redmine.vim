scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

runtime! ftplugin/textile.vim

setlocal foldmethod=marker foldmarker={{collapse,}} commentstring=

let b:undo_ftplugin = "setl fdm< fmr< cms<"
