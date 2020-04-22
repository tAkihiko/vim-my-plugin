scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

function! tanikawa#daily_report#MkDailyReport(title) abort
	if exists("g:daily_report_dir")
		let l:daily_report_dir = g:daily_report_dir
	else
		let l:daily_report_dir = "."
	endif

	if 0 < len(a:title)
		let title = a:title.'_作業報告'
	else
		let title = strftime('%Y%m%d_作業報告')
	endif

	let filename = printf("%s.txt", title)

	if filereadable(filename)
		exec 'edit' l:daily_report_dir.'/'.filename
	else
		exec 'new' l:daily_report_dir.'/'.filename
	endif

	nnoremap <buffer><silent> <C-C> :%y*<CR>

endfunction

function! tanikawa#daily_report#StartWork(...) abort
	let l:month = str2nr(strftime('%m'))
	let l:day = str2nr(strftime('%d'))
	let l:today = printf("%d/%d(%s)", l:month, l:day, strftime('%a'))
	let l:time_step = 5

	let l:hour = -1
	let l:min = -1
	let l:auto_adjust = v:false
	let l:work_time = 9*60 " 8時間労働 + 1時間休憩

	for l:arg_str in a:000

		if l:arg_str =~? '^\d\{1,2}:\d\{2}$'
			" 8:00, 10:30
			let [l:hour, l:min; l:rest] = split(l:arg_str, ':', 1)
			let l:hour = str2nr(l:hour)
			let l:min = str2nr(l:min)

		elseif l:arg_str =~? '^\d\{3,4}$'
			" 800, 1030
			let l:hour = str2nr(l:arg_str[0:-3])
			let l:min = str2nr(l:arg_str[-2:-1])

		elseif l:arg_str =~? '^\d\{1,2}h\?$'
			" 4, 9, 4h, 10h
			let l:work_time = str2nr(l:arg_str) * 60

		else
			" nop
		endif
	endfor

	" 指定無ければ現在の時間を基準にする
	if l:hour < 0 || l:min < 0
		let l:hour = strftime('%H')
		let l:min = strftime('%M')
		let l:auto_adjust = v:true
	endif

	let l:start_time = l:hour*60 + l:min
	if l:auto_adjust
		" 時間をキリの良く調整
		let l:start_time += l:time_step - l:start_time % l:time_step
	endif
	let l:end_time = l:start_time + l:work_time

	" ファイルの開き方を設定
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

	call append(line('$'), '業務を開始します。')
	call append(line('$'), printf("%s %d:%02d-%d:%02d 在宅勤務(谷川)", l:today, l:start_time/60, l:start_time%60, l:end_time/60, l:end_time%60))

	0 delete _

	command! -buffer CopyStartWorkStr call <SID>CopyStartWorkStr()
	nnoremap <buffer><silent> <C-C> :<C-U>CopyStartWorkStr<CR>

endfunction

function! s:CopyStartWorkStr() abort
	% yank *
	let @* = substitute(@*, "\n\s*$", "", "")
endfunction
