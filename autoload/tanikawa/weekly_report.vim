scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

function! tanikawa#weekly_report#CheckFileType(fname) abort
	if exists("g:weekly_report_dir")
		let fullpath = escape(fnameescape(fnamemodify(a:fname, ':p')), '\')
		let target = escape(fnameescape(fnamemodify(g:weekly_report_dir, ':p')), '\')

		" \ がうまく動かないので % に置換
		let fullpath = substitute(fullpath, '\', '%', 'g')
		let target = substitute(target, '\', '%', 'g')

		if 0 <= match(fullpath, target)
			set filetype=weekly_report
		endif
	endif
endfunction

function! tanikawa#weekly_report#MkWeeklyReport(title) abort
	if exists("g:weekly_report_dir")
		let l:weekly_report_dir = g:weekly_report_dir
	else
		let l:weekly_report_dir = "."
	endif

	if 0 < len(a:title)
		let title = a:title
	else
		let title = strftime('%Y%m%d')
	endif

	if has('win32') || has('win64')
		" executable('dir')が機能しない……

		let weekly_reports = systemlist('dir /b /a:-d ' . shellescape(l:weekly_report_dir))
		call filter(weekly_reports, 'v:val =~? "^\\d\\+"')
		if 0 < len(weekly_reports)
			let zenkai = fnamemodify(weekly_reports[-1], ":t")
			let zenkai = substitute(zenkai, '\r', '', '')
			let zenkai = substitute(zenkai, '\n', '', '')
		else
			let zenkai = ""
		endif
	else
		echoerr 'Not Support'
		return
	endif

	let filename_today = l:weekly_report_dir . '/' . printf("%s.wr.txt", title)
	let filename_zenkai = l:weekly_report_dir . '/' . zenkai

	" ファイルの開き方を設定
	let edit_cmd = 'new'
	if expand('%') == "" && &mod == 0
		let edit_cmd = 'edit'
	endif

	if filereadable(filename_today)
		echo 'edit' filename_today
		exec 'silent' edit_cmd filename_today
	else
		echo 'new' filename_today
		exec 'silent' edit_cmd filename_today
		if filereadable(filename_zenkai)
			exec 'silent read' filename_zenkai
			0 delete _
		endif
	endif

	setlocal expandtab tabstop=4
	nnoremap <buffer><silent> <C-C> :%y*<CR>

endfunction
