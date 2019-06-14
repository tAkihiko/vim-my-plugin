" Author: 谷川陽彦 <pureodio1109@gmail.com>
scriptencoding utf-8

command! -complete=custom,<SID>CompDailyReport -nargs=? MkDailyReport call tanikawa#daily_report#MkDailyReport(<q-args>)

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

	return join(text_list, "\n")

endfunction

" vim: fdm=marker
