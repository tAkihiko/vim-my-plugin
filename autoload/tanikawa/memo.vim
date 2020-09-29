scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

function! tanikawa#memo#MkMemo(title) abort
	if exists("g:memo_dir")
		let l:memo_dir = g:memo_dir
	else
		let l:memo_dir = "."
	endif

	if exists('?readdir')
		let text_list = readdir(l:weekly_report_dir, {n -> n=~ '\.txt$'})
	else
		if has('win32') || has('win64')
			let cmd = 'dir /b '.shellescape(l:memo_dir.'\*.txt')
		else
			let cmd = 'ls '.shellescape(l:memo_dir.'/*.txt')
		endif
		let text_list = systemlist(cmd)
	endif
	if has('win32') || has('win64')
		let enc = 'sjis'
	else
		let enc = 'utf-8'
	endif
	call map(text_list, {key, val -> iconv(val, enc, &enc) })
	call map(text_list, {key, val -> substitute(val, '\r', '', 'g') })
	call map(text_list, {key, val -> substitute(val, '^\%(.*[\/]\)\?\(\d\{2}_[^\/]*\.txt\)$', '\1', 'g') })

	let cnt = 0
	for memo in text_list
		if memo =~? '^\d\{2}_.*\.txt'
			let cnt += 1
		endif
	endfor

	if 0 < len(a:title)
		let title = a:title
	else
		call inputsave()
		let title = input('メモのタイトルは？ > ')
		call inputrestore()
	endif
	let footer  = '# vim: '
	let footer .= 'ft=memo et ts=4'

	let filename = printf("%02d_%s.txt", cnt + 1, title)
	let filename = fnameescape(filename)

	let l:memo_dir = substitute(l:memo_dir, ' ', '\\ ', 'g')
	exec 'new' l:memo_dir.'/'.filename
	setlocal ft=memo et ts=4

	call append(line('$'), [title, "", footer])
	0 delete _
	call cursor(2, 1)

endfunction

function! tanikawa#memo#EdMemo(preview_mode, title_no) abort
	if exists("g:memo_dir")
		let l:memo_dir = g:memo_dir
	else
		let l:memo_dir = "."
	endif

	if has('win32') || has('win64')
		let cmd = 'dir /b '.shellescape(l:memo_dir.'\*.txt')
		let enc = 'sjis'
	else
		let cmd = 'ls '.shellescape(l:memo_dir.'/*.txt')
		let enc = 'utf-8'
	endif
	let text_list = systemlist(cmd)
	call map(text_list, {key, val -> iconv(val, enc, &enc) })
	call map(text_list, {key, val -> substitute(val, '\r', '', 'g') })
	call map(text_list, {key, val -> substitute(val, '^\%(.*[\/]\)\?\(\d\{2}_[^\/]*\.txt\)$', '\1', 'g') })

	let memo_list = []
	for memo in text_list
		if memo =~? '^\d\{2}_.*\.txt$'
			call add(memo_list, memo)
		endif
	endfor

	if 0 < len(a:title_no)
		"
		" 指定あり: 番号を利用
		"

		let sel_nr = str2nr(a:title_no)

	else
		"
		" 指定なし: リストを表示し、番号を入力する
		"

		let menu_list = copy(memo_list)
		redraw
		echo join(map(menu_list, {key, val -> printf('%2d: %s', key+1, substitute(val, '^\d\{2}_\(.*\)\.txt$', '\1', ''))}), "\n")

		call inputsave()
		let sel_str = input('> ')
		call inputrestore()
		if sel_str =~? '^\s*$'
			return
		endif
		let sel_nr = str2nr(sel_str)
	endif

	if sel_nr < 1 || len(memo_list) < sel_nr
		echoerr 'Range Over'
		return
	endif

	let filename = memo_list[sel_nr-1]
	let filename = substitute(filename, '%', '\\%', 'g')
	let filename = substitute(filename, '#', '\\#', 'g')
	let l:memo_dir = substitute(l:memo_dir, ' ', '\\ ', 'g')
	if a:preview_mode == 1
		exec 'pedit' l:memo_dir.'/'.filename
	else
		exec 'split' l:memo_dir.'/'.filename
	endif

endfunction
