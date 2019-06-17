scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! SetChkMode call <SID>SetSourceCodeCheckMode(1)
command! SetChkModeL call <SID>SetSourceCodeCheckMode(2)

function! s:SetSourceCodeCheckMode(set)

	if a:set == 1
		" Quick fix list
		let g:pre_nmap_n = maparg('<C-N>', 'n', v:false, v:true)
		let g:pre_nmap_p = maparg('<C-P>', 'n', v:false, v:true)
		nnoremap <silent> <C-N> :cn<CR>
		nnoremap <silent> <C-P> :cp<CR>
		command! UnSetChkMode call <SID>SetSourceCodeCheckMode(0)
		delcommand SetChkMode
		delcommand SetChkModeL

	elseif a:set == 2
		" Location list
		let g:pre_nmap_n = maparg('<C-N>', 'n', v:false, v:true)
		let g:pre_nmap_p = maparg('<C-P>', 'n', v:false, v:true)
		nnoremap <silent> <C-N> :lnext<CR>
		nnoremap <silent> <C-P> :lprev<CR>
		command! UnSetChkMode call <SID>SetSourceCodeCheckMode(0)
		delcommand SetChkMode
		delcommand SetChkModeL

	else
		if empty(g:pre_nmap_n) || g:pre_nmap_n.rhs == "" || g:pre_nmap_n.rhs == "<Nop>"
			nunmap <C-N>
		elseif g:pre_nmap_n.noremap == v:false
			exec 'nmap <C-P>' g:pre_nmap_n.rhs
		else
			exec 'nnoremap <C-N>' g:pre_nmap_n.rhs
		endif

		if empty(g:pre_nmap_p) || g:pre_nmap_p.rhs == "" || g:pre_nmap_p.rhs == "<Nop>"
			nunmap <C-P>
		elseif g:pre_nmap_p.noremap == v:false
			exec 'nmap <C-P>' g:pre_nmap_p.rhs
		else
			exec 'nnoremap <C-P>' g:pre_nmap_p.rhs
		endif

		delcommand UnSetChkMode
		command! SetChkMode call <SID>SetSourceCodeCheckMode(1)
		command! SetChkModeL call <SID>SetSourceCodeCheckMode(2)
	endif
endfunction
