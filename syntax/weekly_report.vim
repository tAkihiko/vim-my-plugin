" Author: 谷川陽彦 <pureodio1109@gmail.com>
scriptencoding utf-8

if exists("b:current_syntax")
  finish
endif

syntax match wrTitle /^\S.*$/

highlight link wrTitle Title

let b:current_syntax = "weekly_report"
