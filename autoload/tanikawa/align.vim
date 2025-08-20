scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

func! tanikawa#align#align_tab(b,e)
	for l:lno in range(a:b, a:e)
		let l:line = getline(l:lno)
		let l:matchlist = l:line->matchlist('^\(.\{-}\S\)\([ ]\+\t\+\)')
		if len(l:matchlist) < 3
			continue
		endif
		let col = strdisplaywidth(l:matchlist[1])
		let tabs = repeat("\t", (strdisplaywidth(l:matchlist[2], col) + (&ts - 1)) / (&ts) )
		let l:outline = l:line->substitute(l:matchlist[2], tabs, '')
		call setline(l:lno, l:outline)
	endfor
endfunc
