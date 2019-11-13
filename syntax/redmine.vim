scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:current_syntax")
  finish
endif

runtime! syntax/textile.vim

" 上書き
syn match txtEmphasis    /_\.\@![^_]\+_\.\@!/

syntax sync minlines=100

syntax region rmCodeBlock start='<pre>' end='</pre>'

syntax match rmTicketNo /#\d\+/
syntax match rmCommitHash /commit:\x\{1,40}/

highlight link rmCodeBlock txtCode
highlight link rmTicketNo Special
highlight link rmCommitHash Special

let b:current_syntax = "weekly_report"
