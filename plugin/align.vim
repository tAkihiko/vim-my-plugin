scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:prefix = tanikawa#util#GetPrefix('AL')

exec 'command! -range' s:prefix .. 'AlignTab call tanikawa#align#align_tab(<line1>, <line2>)'
