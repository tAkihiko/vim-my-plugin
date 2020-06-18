scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

if exists("b:did_ftplugin")
  finish
endif

let b:did_ftplugin = 1

setlocal noexpandtab
setlocal vartabstop=20,42 softtabstop=4 shiftwidth=4

nnoremap <buffer><silent> <C-C> :<C-U>call tanikawa#weekly_report#Copy()<CR>
nnoremap <buffer><silent> <C-K> :<C-U>call tanikawa#weekly_report#AppendWorkTimeCol()<CR>
inoremap <buffer><silent> <C-K> <C-O>:<C-U>call tanikawa#weekly_report#AppendWorkTimeCol()<CR>

command! -buffer -nargs=1 AddWorkingTime call tanikawa#weekly_report#CalcWorkingTime(<f-args>, 0)
command! -buffer -nargs=1 DelWorkingTime call tanikawa#weekly_report#CalcWorkingTime(<f-args>, 1)
command! -buffer -nargs=1 RepWorkingTime call tanikawa#weekly_report#CalcWorkingTime(<f-args>, 2)

let b:undo_ftplugin = "setl et< ts< sts< sw<"
