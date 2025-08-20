scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

function! tanikawa#make_tags#MakeTags(file_type, ...)

	if !executable('ctags')
		echoerr "ctags が見つかりません"
		return
	endif

	let top_dirs = a:000

	let top_dir = "."
	if len(top_dirs) > 0
		let top_dir = ""
		for dir in top_dirs
			let top_dir .= ' "' . fnameescape(dir) . '"'
		endfor
	endif

	if a:file_type ==? 'c'
		call <SID>MakeTags_C(top_dir)
	elseif a:file_type ==? 'cs'
		call <SID>MakeTags_CS(top_dir)
	elseif a:file_type ==? 'vba'
		call <SID>MakeTags_VBA(top_dir)
	else
		call <SID>MakeTags_All(top_dir)
	endif

endfunction

function! s:MakeTags_C(top_dir=".")
	echo "C"
	let cmd = 'ctags --input-encoding=sjis --languages=C,C++ --fields=+imaSz -f c.sjis.tags -R ' . a:top_dir
	call system(cmd)
	let cmd = 'ctags --input-encoding=utf8 --languages=C,C++ --fields=+imaSz -f c.utf8.tags -R ' . a:top_dir
	call system(cmd)
endfunction

function! s:MakeTags_CS(top_dir=".")
	echo "CS"
	" --c#-kinds はデフォルトのまま
	let cmd = 'ctags --input-encoding=utf8 --languages=C# --fields=+imaSz -f cs.tags -R ' . a:top_dir
	call system(cmd)
endfunction

function! s:MakeTags_VBA(top_dir=".")
	echo "VBA"
	let cmd = 'ctags --input-encoding=sjis --languages=Basic --langmap=Basic:.vb --fields=+imaSz -f vba.tags -R ' . a:top_dir
	call system(cmd)
endfunction

function! s:MakeTags_All(top_dir=".")
	echo "ALL"
	let cmd = 'ctags --input-encoding=utf8 --fields=+imaSz -f tags -R ' . a:top_dir
	call system(cmd)
endfunction
