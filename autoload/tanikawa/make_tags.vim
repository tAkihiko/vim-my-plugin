scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

function! tanikawa#make_tags#MakeTags(file_type)

	if !executable('ctags')
		echoerr "ctags が見つかりません"
	endif

	if a:file_type ==? 'c'
		call <SID>MakeTags_C()
	elseif a:file_type ==? 'cs'
		call <SID>MakeTags_CS()
	elseif a:file_type ==? 'vba'
		call <SID>MakeTags_VBA()
	else
		call <SID>MakeTags_All()
	endif

endfunction

function! s:MakeTags_C()
	echo "C"
	let cmd = 'ctags --jcode=sjis --languages=C,C++ --fields=+imaSz -f c.sjis.tags -R .'
	call system(cmd)
	let cmd = 'ctags --jcode=utf8 --languages=C,C++ --fields=+imaSz -f c.utf8.tags -R .'
	call system(cmd)
endfunction

function! s:MakeTags_CS()
	echo "CS"
	" --c#-kinds はデフォルトのまま
	let cmd = 'ctags --jcode=utf8 --languages=C# --fields=+imaSz -f cs.tags -R .'
	call system(cmd)
endfunction

function! s:MakeTags_VBA()
	echo "VBA"
	let cmd = 'ctags --jcode=sjis --languages=Basic --langmap=Basic:.vb --fields=+imaSz -f vba.tags -R .'
	call system(cmd)
endfunction

function! s:MakeTags_All()
	echo "ALL"
	let cmd = 'ctags --jcode=utf8 --fields=+imaSz -f tags -R .'
	call system(cmd)
endfunction
