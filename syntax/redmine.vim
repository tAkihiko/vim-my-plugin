scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:current_syntax")
  finish
endif

runtime! syntax/textile.vim

syntax region rmCodeBlock start='<pre>' end='</pre>'

highlight link rmCodeBlock txtCode

let b:current_syntax = "weekly_report"
