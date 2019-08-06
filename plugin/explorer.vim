scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! -nargs=? -complete=file Exp call <SID>Explorer(<q-args>)
command! GetFName let @+ = expand("%:t")
command! GetFPath let @+ = expand("%:p")

function! s:Explorer( target )

	if len(a:target) <= 0
		let l:target = expand('%')
	else
		let l:target = expand( a:target )
	endif
	let l:target = fnamemodify(l:target, ":p")
	let l:target_path = shellescape(l:target)

	if has('win32') || has('win64')
		if exists("g:explorer_cmd")
			let l:explorer_cmd = shellescape(g:explorer_cmd)
		else
			let l:explorer_cmd = 'explorer'
		endif
		if isdirectory( l:target )
			call system( l:explorer_cmd . ' ' . l:target_path )
		else
			call system( l:explorer_cmd . ' /select,' . l:target_path )
		endif
	else
		echoerr "未対応"
	endif

endfunction

