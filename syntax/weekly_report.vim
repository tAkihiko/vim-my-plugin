scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:current_syntax")
  finish
endif

syntax sync fromstart

syntax match wrTitle /^\S[^\t]*/ contains=wrTitleLenErr

syntax match wrLine /^[^\t]*\t[^\t]*/ transparent contains=wrItem,wrTitle,wrSubTitle
syntax match wrItem /\t[^\t]*/hs=s+1 contained contains=wrItemLenErr
syntax match wrSubTitle /\t\S[^\t]*/hs=s+1 contained contains=wrItemLenErr
syntax match wrItemLenErr /\%>62v.*/ contained
syntax match wrTitleLenErr /\%>20v.*/ contained

syntax match wrOverLine /\%>12l.*/

highlight link wrItem Text
highlight link wrTitle Title
highlight link wrSubTitle Title
highlight link wrOverLine Error
highlight link wrItemLenErr Error
highlight link wrTitleLenErr Error

let b:current_syntax = "weekly_report"
