scriptencoding utf-8

command! -nargs=? -complete=file Exp call <SID>Explorer(<q-args>)
function! s:Explorer( target )

	if len(a:target) <= 0
		let l:target = expand('%')
	else
		let l:target = expand( a:target )
	endif

	if has('win32') || has('win64')
		if isdirectory( l:target )
			call system( 'explorer ' . l:target )
		else
			call system( 'explorer /select,' . l:target )
		endif
	else
		echoerr "未対応"
	endif

endfunction

