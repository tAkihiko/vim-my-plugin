" Author: 谷川陽彦 <pureodio1109@gmail.com>
scriptencoding utf-8

if exists("b:current_syntax")
  finish
endif

syntax sync fromstart

syntax match wrTitle /^\S.*$/
syntax match wrOverLine /\%>12l.*/

highlight link wrTitle Title
highlight link wrOverLine Error

let b:current_syntax = "weekly_report"
