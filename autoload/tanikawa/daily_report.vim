scriptencoding cp932

function! tanikawa#daily_report#MkDailyReport(title) abort
	if exists("g:daily_report_dir")
		let l:daily_report_dir = g:daily_report_dir
	else
		let l:daily_report_dir = "."
	endif

	if 0 < len(a:title)
		let title = a:title.'_��ƕ�'
	else
		let title = strftime('%Y%m%d_��ƕ�')
	endif

	let filename = printf("%s.txt", title)

	if filereadable(filename)
		exec 'edit' l:daily_report_dir.'/'.filename
	else
		exec 'new' l:daily_report_dir.'/'.filename
	endif

	nnoremap <buffer><silent> <C-C> :%y*<CR>

endfunction
