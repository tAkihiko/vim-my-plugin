scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! -complete=customlist,<SID>CompWeeklyReport -nargs=? WRMkWeeklyReport call tanikawa#weekly_report#MkWeeklyReport(<q-args>)

function! s:CompWeeklyReport( arglead, cmdline, curpos )
	if exists("g:weekly_report_dir")
		let l:weekly_report_dir = g:weekly_report_dir
	else
		let l:weekly_report_dir = "."
	endif

	if exists('?readdir')
		let text_list = readdir(l:weekly_report_dir, {n -> n=~ '\.wr\.txt$'})
	else
		if has('win32') || has('win64')
			let cmd = 'dir /b '.l:weekly_report_dir.'\*.txt'
		else
			let cmd = 'ls '.l:weekly_report_dir.'/*.txt'
		endif
		let text_list = systemlist(cmd)
	endif
	call map(text_list, {key, val -> substitute(val, '\r', '', 'g') })
	call map(text_list, {key, val -> substitute(val, '^\%(.*[\/]\)\?\(\d\+\)\.wr\.txt$', '\1', 'g') })

	let ret_list = []
	let year_match_fmt = '^' . a:arglead
	let date_match_fmt = '^\d\{4,}' . a:arglead
	for text_line in text_list
		if 4 < len(a:arglead) && text_line =~? year_match_fmt
			" 逆順に詰めていく
			call insert(ret_list, text_line)
		elseif text_line =~? date_match_fmt
			" 逆順に詰めていく
			call insert(ret_list, text_line)
		endif
	endfor

	return ret_list

endfunction

" vim: fdm=marker
