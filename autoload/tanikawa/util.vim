scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

function! tanikawa#util#DeleteConsecutiveDuplicateLines(begin,end) abort
	let lines = getline(a:begin, a:end)

	let outlines = []
	let prev = ""
	for line in lines
		if line ==# prev
			let outlines += [""]
		else
			let outlines += [line]
		endif
		let prev = line
	endfor
	call setline(a:begin, outlines)
endfunction

function! tanikawa#util#ReplaceToErrorFormat() abort
	let line = getline('.')
	let line = substitute(line, '[[.^]', '%\0', 'g')
	let line = substitute(line, '\*', '%#', 'g')
	let line = substitute(line, '\\', '%\\\\', 'g')
	call setline('.', line)
endfunction

function! tanikawa#util#GetPrefix(prefix)
	if exists('g:tanikawa#util#prefix_disable') && type(g:tanikawa#util#prefix_disable) == v:t_dict && has_key(g:tanikawa#util#prefix_disable, a:prefix)
		return ""
	endif
	return a:prefix
endfunction
