scriptencoding cp932

command! -nargs=1 -complete=file Exp call <SID>Explorer(<q-args>)
function! s:Explorer( target )
	let l:target = expand( a:target )
	if has('win32') || has('win64')
		if isdirectory( l:target )
			call system( 'explorer ' . l:target )
		else
			call system( 'explorer /select,' . l:target )
		endif
	else
		echoerr "–¢‘Î‰ž"
	endif
endfunction

