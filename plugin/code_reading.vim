scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! SetChkMode call <SID>SetSourceCodeCheckMode(1)
command! SetChkModeL call <SID>SetSourceCodeCheckMode(2)

function! s:SetSourceCodeCheckMode(set)

	if a:set == 1
		" Quick fix list
		let g:pre_nmap_n = maparg('<C-N>', 'n', v:false, v:true)
		let g:pre_nmap_p = maparg('<C-P>', 'n', v:false, v:true)
		let g:pre_nmap_gn = maparg('g<C-N>', 'n', v:false, v:true)
		let g:pre_nmap_gp = maparg('g<C-P>', 'n', v:false, v:true)
		nnoremap <silent> <C-N> :cn<CR>
		nnoremap <silent> <C-P> :cp<CR>
		nnoremap <silent> g<C-N> :cnewer<CR>:cc<CR>
		nnoremap <silent> g<C-P> :colder<CR>:cc<CR>
		command! UnSetChkMode call <SID>SetSourceCodeCheckMode(0)
		delcommand SetChkMode
		delcommand SetChkModeL

	elseif a:set == 2
		" Location list
		let g:pre_nmap_n = maparg('<C-N>', 'n', v:false, v:true)
		let g:pre_nmap_p = maparg('<C-P>', 'n', v:false, v:true)
		let g:pre_nmap_gn = maparg('g<C-N>', 'n', v:false, v:true)
		let g:pre_nmap_gp = maparg('g<C-P>', 'n', v:false, v:true)
		nnoremap <silent> <C-N> :lnext<CR>
		nnoremap <silent> <C-P> :lprev<CR>
		nnoremap <silent> g<C-N> :lnewer<CR>:ll<CR>
		nnoremap <silent> g<C-P> :lolder<CR>:ll<CR>
		command! UnSetChkMode call <SID>SetSourceCodeCheckMode(0)
		delcommand SetChkMode
		delcommand SetChkModeL

	else
		call s:ResetNMap( '<C-N>', g:pre_nmap_n )
		call s:ResetNMap( '<C-P>', g:pre_nmap_p )
		call s:ResetNMap( 'g<C-N>', g:pre_nmap_gn )
		call s:ResetNMap( 'g<C-P>', g:pre_nmap_gp )

		delcommand UnSetChkMode
		command! SetChkMode call <SID>SetSourceCodeCheckMode(1)
		command! SetChkModeL call <SID>SetSourceCodeCheckMode(2)
	endif
endfunction

function! s:ResetNMap( maparg, mapparam )
	if empty(a:mapparam) || a:mapparam.rhs == "" || a:mapparam.rhs == "<Nop>"
		exec 'nunmap' a:maparg
	elseif a:mapparam.noremap == v:false
		exec 'nmap' a:maparg a:mapparam.rhs
	else
		exec 'nnoremap' a:maparg a:mapparam.rhs
	endif
endfunction
