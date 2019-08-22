scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:current_syntax")
  finish
endif

syntax sync fromstart

syntax match wrItem /^[^\t]*/ contains=wrTitle,wrItemLenErr
syntax match wrTitle /^\S.*$/ contained contains=wrItemLenErr
syntax match wrOverLine /\%>12l.*/
syntax match wrItemLenErr /\%>42v.*/ contained

highlight link wrTitle Title
highlight link wrOverLine Error
highlight link wrItemLenErr Error

let b:current_syntax = "weekly_report"
