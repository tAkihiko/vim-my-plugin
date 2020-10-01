scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! -complete=customlist,<SID>CompDailyReport -nargs=? MkDailyReport call tanikawa#daily_report#MkDailyReport(<q-args>)
command! -nargs=* StartWork call tanikawa#daily_report#StartWork(<f-args>)
command! -nargs=? StartWork2 call tanikawa#daily_report#StartWork2(<f-args>)

function! s:CompDailyReport( arglead, cmdline, curpos )
	if exists("g:daily_report_dir")
		let l:daily_report_dir = g:daily_report_dir
	else
		let l:daily_report_dir = "."
	endif

	if has('win32') || has('win64')
		let cmd = 'dir /b '.l:daily_report_dir.'\*.txt'
	else
		let cmd = 'ls '.l:daily_report_dir.'/*.txt'
	endif
	let text_list = systemlist(cmd)
	call map(text_list, {key, val -> substitute(val, '\r', '', 'g') })
	call map(text_list, {key, val -> substitute(val, '^\%(.*[\/]\)\?\(\d\+\)_[^\/]*\.txt$', '\1', 'g') })

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
