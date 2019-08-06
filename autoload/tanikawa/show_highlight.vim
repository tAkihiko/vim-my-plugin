scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

" VimShowHlGroup: Show highlight group name under a cursor
function! tanikawa#show_highlight#ShowHlGroup()
	return synIDattr(synIDtrans(synID(line('.'), col('.'), 1)), 'name')
endfunction

" VimShowHlItem: Show highlight item name under a cursor
function! tanikawa#show_highlight#ShowHlItem()
	return synIDattr(synID(line("."), col("."), 1), "name")
endfunction

" https://hail2u.net/blog/software/vim-show-highlight-group-name-under-cursor.html
" https://rcmdnk.com/blog/2013/12/01/computer-vim/
