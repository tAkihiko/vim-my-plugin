scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

function! tanikawa#code_reading#SetSourceCodeCheckMode(set)

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
		command! UnSetChkMode call tanikawa#code_reading#SetSourceCodeCheckMode(0)
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
		command! UnSetChkMode call tanikawa#code_reading#SetSourceCodeCheckMode(0)
		delcommand SetChkMode
		delcommand SetChkModeL

	else
		call s:ResetNMap( '<C-N>', g:pre_nmap_n )
		call s:ResetNMap( '<C-P>', g:pre_nmap_p )
		call s:ResetNMap( 'g<C-N>', g:pre_nmap_gn )
		call s:ResetNMap( 'g<C-P>', g:pre_nmap_gp )

		delcommand UnSetChkMode
		command! SetChkMode call tanikawa#code_reading#SetSourceCodeCheckMode(1)
		command! SetChkModeL call tanikawa#code_reading#SetSourceCodeCheckMode(2)
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

function! tanikawa#code_reading#SetSourceCodeCopyMode(set)

	if a:set == 1
		" Quick fix list
		let g:pre_nmap_c = maparg('<C-C>', 'n', v:false, v:true)
		let g:pre_xmap_c = maparg('<C-C>', 'x', v:false, v:true)
		nnoremap <silent> <C-C> :CopySrcCode<CR>
		xnoremap <silent> <C-C> :CopySrcCode<CR>
		command! UnSetCpMode call tanikawa#code_reading#SetSourceCodeCopyMode(0)
		delcommand SetCpMode

	else
		call s:ResetNMap( '<C-C>', g:pre_nmap_c )
		call s:ResetXMap( '<C-C>', g:pre_xmap_c )

		delcommand UnSetCpMode
		command! SetCpMode call tanikawa#code_reading#SetSourceCodeCheckMode(1)
	endif
endfunction

function! s:ResetXMap( maparg, mapparam )
	if empty(a:mapparam) || a:mapparam.rhs == "" || a:mapparam.rhs == "<Nop>"
		exec 'xunmap' a:maparg
	elseif a:mapparam.noremap == v:false
		exec 'xmap' a:maparg a:mapparam.rhs
	else
		exec 'xnoremap' a:maparg a:mapparam.rhs
	endif
endfunction

function! tanikawa#code_reading#CopySrcCode( begin, end )
	let @+ = ""
	let l:digit = len(string(a:end))
	let l:ts = &ts
	for l:line_no in range(a:begin, a:end)
		let l:line = getline(l:line_no)
		let l:line_out = ""
		let l:chr_out_no = 0
		for l:chr_no in range(len(l:line))
			if l:line[l:chr_no] ==# "\t"
				" タブを空白に変換
				let l:tab_len = l:ts - ( l:chr_out_no % l:ts )
				let l:line_out .= repeat(" ", l:tab_len )

				" 次以降のタブ幅計算のため、現在のタブ幅分の文字数を加算
				let l:chr_out_no += l:tab_len
			else
				let l:line_out .= l:line[l:chr_no]
				let l:chr_out_no += 1
			endif
		endfor
		let @+ .= printf("%" . string(l:digit) . "d: ", l:line_no) . l:line_out . "\n"
	endfor
endfunction
