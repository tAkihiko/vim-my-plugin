scriptencoding cp932

function! tanikawa#daily_report#MkDailyReport(title) abort
	if 0 < len(a:title)
		let title = a:title
	else
		let title = strftime('%Y%m%d_ì‹Æ•ñ')
	endif

	let filename = printf("%s.txt", title)

	if filereadable(filename)
		exec 'edit' filename
	else
		exec 'new' filename
	endif

	nnoremap <buffer><silent> <C-C> :%y*<CR>

endfunction
