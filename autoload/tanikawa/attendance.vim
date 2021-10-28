scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:V = vital#_tanikawa#new()
let s:DateTime = s:V.import('DateTime')

function! tanikawa#attendance#AttendanceReport(...) abort

	let l:year = str2nr(strftime('%Y'))
	let l:month = str2nr(strftime('%m'))
	let l:day = str2nr(strftime('%d'))
	let l:rest_type = 0 " 0:all, 1:am, 2:pm
	let l:today = s:DateTime.from_date(l:year, l:month, l:day)

	for l:arg_str in a:000

		if l:arg_str =~? '^\d\{4}/\d\{1,2}/\d\{1,2}$'
			" 2020/8/1, 2022/10/30
			let [l:year, l:month, l:day; l:rest] = split(l:arg_str, '/', 1)
			let l:year = str2nr(l:year)
			let l:month = str2nr(l:month)
			let l:day = str2nr(l:day)
		elseif l:arg_str =~? '^\d\{1,2}/\d\{1,2}\%(\s*[(（].[)）]\s*\)\?$'
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

	" 今日と比較
	if l:datetime.is(l:today)
		let l:report_type = "当日不在連絡"
	else
		let l:report_type = "不在連絡"
	endif

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

	" 文字列作成
	"call append(line('$'), '私用の為')
	call append(line('$'), printf("【%s】谷川：%s %s", l:report_type, l:date_str, l:vacation))

	0 delete _

	command! -buffer CopyAttendanceReport call <SID>CopyAttendanceReport()
	nnoremap <buffer><silent> <C-C> :<C-U>CopyAttendanceReport<CR>

endfunction

function! tanikawa#attendance#AttendanceReportComp(arg, cmd, pos)
	if len(split(a:cmd, '\s\+', 1)) < 3
		let l:year = str2nr(strftime('%Y'))
		let l:month = str2nr(strftime('%m'))
		let l:day = str2nr(strftime('%d'))
		let l:today = s:DateTime.from_date(l:year, l:month, l:day)

		let list = []
		for l:cnt in range(15) " 当日 + 2週間
			let l:date = l:today.to(s:DateTime.delta(l:cnt,0))
			let l:week = l:date.day_of_week()
			if l:week == 0 || l:week == 6
				" 土日はスキップ
				continue
			endif
			let list += [printf("%d/%d（%s）", l:date.month(), l:date.day(), l:date.format('%a'))]
		endfor
		let list += ["am", "pm"]
		return join(list, "\n")
	else
		return "am\npm"
	endif

	return ""
endfunction

function! s:CopyAttendanceReport() abort
	% yank *
	let @* = substitute(@*, "\n\s*$", "", "")
endfunction
