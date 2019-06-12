scriptencoding cp932

function! tanikawa#make_tags#MakeTags(file_type)

	if !executable('ctags')
		echoerr "ctags ‚ªŒ©‚Â‚©‚è‚Ü‚¹‚ñ"
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
endfunction

function! s:MakeTags_CS()
	echo "CS"
	let cmd = 'ctags --languages=C# --c#-kinds=cdegmstn --fields=imaS -f cs.tags -R .'
	call system(cmd)
endfunction

function! s:MakeTags_VBA()
	echo "VBA"
endfunction

function! s:MakeTags_All()
	echo "ALL"
	let cmd = 'ctags --fields=imaS -f tags -R .'
	call system(cmd)
endfunction
