" Author: 谷川陽彦 <pureodio1109@gmail.com>
scriptencoding utf-8

command! -nargs=? MkMemo call tanikawa#memo#MkMemo(<q-args>)
command! EdMemo call tanikawa#memo#EdMemo(0)
command! ShowMemo call tanikawa#memo#EdMemo(1)

" vim: fdm=marker
