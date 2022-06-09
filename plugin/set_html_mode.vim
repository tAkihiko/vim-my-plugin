scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! ToHtmlForPaste call <SID>ToHtmlForPaste()

function! s:ToHtmlForPaste()
	setlocal nonumber
	colorscheme zellner
	highlight Error gui=reverse,underline
endfunction
