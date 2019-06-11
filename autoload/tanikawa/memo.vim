scriptencoding cp932

function! tanikawa#memo#MkMemo(title) abort
	if exists("g:memo_dir")
		let l:memo_dir = g:memo_dir
	else
		let l:memo_dir = "."
	endif

	if has('win32') || has('win64')
		let cmd = 'dir /b '.l:memo_dir.'\*.txt'
	else
		let cmd = 'ls '.l:memo_dir.'/*.txt'
	endif
	let text_list = systemlist(cmd)
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

	exec 'new' l:memo_dir.'/'.filename
	setlocal ft=memo et ts=4

	call append(line('$'), [title, "", footer])
	0 delete _

endfunction

function! tanikawa#memo#EdMemo() abort
	if exists("g:memo_dir")
		let l:memo_dir = g:memo_dir
	else
		let l:memo_dir = "."
	endif

	if has('win32') || has('win64')
		let cmd = 'dir /b '.l:memo_dir.'\*.txt'
	else
		let cmd = 'ls '.l:memo_dir.'/*.txt'
	endif
	let text_list = systemlist(cmd)
	call map(text_list, {key, val -> substitute(val, '\r', '', 'g') })
	call map(text_list, {key, val -> substitute(val, '^\%(.*[\/]\)\?\(\d\{2}_[^\/]*\.txt\)$', '\1', 'g') })

	let memo_list = []
	for memo in text_list
		if memo =~? '^\d\{2}_.*\.txt$'
			call add(memo_list, memo)
		endif
	endfor

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
	if sel_nr < 1 || len(memo_list) < sel_nr
		echoerr 'Range Over'
		return
	endif

	exec 'split' l:memo_dir.'/'.memo_list[sel_nr-1]

endfunction
