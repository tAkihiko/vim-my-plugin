scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:V = vital#_tanikawa#new()
let s:DateTime = s:V.import('DateTime')

function! tanikawa#attendance#AttendanceReport(...) abort

	let l:year = str2nr(strftime('%Y'))
	let l:month = str2nr(strftime('%m'))
	let l:day = str2nr(strftime('%d'))
	let l:rest_type = 0 " 0:all, 1:am, 2:pm

	for l:arg_str in a:000

		if l:arg_str =~? '^\d\{4}/\d\{1,2}/\d\{1,2}$'
			" 2020/8/1, 2022/10/30
			let [l:year, l:month, l:day; l:rest] = split(l:arg_str, '/', 1)
			let l:year = str2nr(l:year)
			let l:month = str2nr(l:month)
			let l:day = str2nr(l:day)
		elseif l:arg_str =~? '^\d\{1,2}/\d\{1,2}$'
			" 8/1, 10/30
			let [l:month, l:day; l:rest] = split(l:arg_str, '/', 1)
			let l:month = str2nr(l:month)
			let l:day = str2nr(l:day)

		elseif l:arg_str =~? '^\d\{3,4}$'
			" 801, 1030
			let l:month = str2nr(l:arg_str[0:-3])
			let l:day = str2nr(l:arg_str[-2:-1])

		elseif l:arg_str =~? '^\%(am\)$'
			" am
			let l:rest_type = 1

		elseif l:arg_str =~? '^\%(pm\)$'
			" pm
			let l:rest_type = 2

		else
			" nop
		endif
	endfor

	" 日付文字列を作成
	let l:datetime = s:DateTime.from_date(l:year, l:month, l:day)
	let l:date_str = printf( "%d/%d (%s)", l:month, l:day, l:datetime.strftime("%a"))

	" 休みの種別文字列を作成
	if l:rest_type == 1
		let l:vacation = "午前休"
	elseif l:rest_type == 2
		let l:vacation = "午後休"
	else
		let l:vacation = "全日休"
	endif

	" ファイルの開き方を設定
	" g:tanikawa_daily_report_start_work_opener を流用
	if exists('g:tanikawa_daily_report_start_work_opener') && len(g:tanikawa_daily_report_start_work_opener) > 0
		let edit_cmd = g:tanikawa_daily_report_start_work_opener
	else
		let edit_cmd = 'new'
	endif
	if expand('%') == "" && &mod == 0 && &bt == ""
		" そのまま実行
	else
		exec 'silent' edit_cmd
	endif

	setlocal bt=nofile

	"call append(line('$'), '私用の為')
	call append(line('$'), printf("【不在連絡】谷川：%s %s", l:date_str, l:vacation))

	0 delete _

	command! -buffer CopyAttendanceReport call <SID>CopyAttendanceReport()
	nnoremap <buffer><silent> <C-C> :<C-U>CopyAttendanceReport<CR>

endfunction

function! s:CopyAttendanceReport() abort
	% yank *
	let @* = substitute(@*, "\n\s*$", "", "")
endfunction
