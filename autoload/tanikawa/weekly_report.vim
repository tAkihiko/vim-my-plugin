scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:weekly_report_sep_count1 = 6
let s:weekly_report_sep_count2 = 5

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

	if exists('?readdir')
		let weekly_reports = readdir(l:weekly_report_dir, {e -> e =~ '\.wr\.txt$'})
		let zenkai = weekly_reports[-1]

	elseif has('win32') || has('win64')
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
	if expand('%') == "" && &mod == 0 && &bt == ""
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

			" 以下は文字コードの変換が必要になるため避ける
			" call setline(1, readfile(filename_zenkai))
		endif
	endif

	set filetype=weekly_report

endfunction

" 作業時間記入用のタブを追加
function! tanikawa#weekly_report#AppendWorkTimeCol() abort

	" 時間記入位置までのタブを追加
	let line = getline(".") . "\t"

	" 行を置き換え
	call setline(".", line)

	" カーソルを行末に移動
	normal $

endfunction

" 週報コピー用関数
function! tanikawa#weekly_report#Copy() abort

	let @+ = ""
	let hour = 0
	let min = 0

	let lines = getline(1, line("$"))
	for line in lines
		let match_list = matchlist(line, '\t\(\d\{,2}:\d\{,2}\)')
		if 1 < len(match_list)
			let time = match_list[1]
			let line  = substitute(line, "^[^\t]*\t[^\t]*\\zs\t", repeat("\t", s:weekly_report_sep_count1), "")
			let line .= repeat("\t", s:weekly_report_sep_count2) . time

			let [h, m] = split(time, ":")
			let hour += str2nr(h)
			let min += str2nr(m)
			let hour += min / 60
			let min %= 60
		endif

		let @+ .= line . "\n"
	endfor

	echo printf("%d:%02d", hour, min)

endfunction

" 作業時間を加算
function! tanikawa#weekly_report#CalcWorkingTime(time, mode)

	let WEEKLY_REPORT_WORKTIME_PATTERN = '^\(.*\t\)\(\d\+:\d\+\)'

	let line = getline(".")
	if line !~? '\t\d*:\d\{2}$'
		return
	endif
	let cur_time = substitute(line, WEEKLY_REPORT_WORKTIME_PATTERN, '\2', '')

	" 現在書かれている時間を取得
	let [l:hour, l:min] = map(split(cur_time, ":", 1), {key, val -> str2nr(val)})
	let l:total_min = l:hour * 60 + l:min

	" 指定した時間を取得
	let l:hour_diff = 0
	let l:min_diff = 0
	let l:total_min_diff = 0
	if a:time =~? '^\d*:\d*$'
		" 1:30, :45
		let [l:hour_diff, l:min_diff] = map(split(a:time, ":", 1), {key, val -> str2nr(val)})
		let l:total_min_diff = l:hour_diff * 60 + l:min_diff
	elseif a:time =~? '^\d\+$'
		let l:total_min_diff = str2nr(a:time)
	else
		echohl Error
		echo "引数は HH:MM / HH: / MM 形式です"
		echohl None
		return
	endif

	" 計算を切替
	if a:mode == 0
		let l:total_min += l:total_min_diff
	elseif a:mode == 1
		let l:total_min -= l:total_min_diff
	elseif a:mode == 2
		let l:total_min = l:total_min_diff
	else
		" nop
	endif

	let l:hour = l:total_min / 60
	let l:min = l:total_min % 60

	let next_line = substitute(line, WEEKLY_REPORT_WORKTIME_PATTERN, '\1'.printf("%d:%02d", l:hour, l:min), '')

	call setline(".", next_line)

endfunction
