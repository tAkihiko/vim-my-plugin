" Author: 谷川陽彦 <pureodio1109@gmail.com>
scriptencoding utf-8

command! -nargs=? MkMemo call tanikawa#memo#MkMemo(<q-args>)
command! -nargs=? EdMemo call tanikawa#memo#EdMemo(0, <q-args>)
command! -nargs=? ShowMemo call tanikawa#memo#EdMemo(1, <q-args>)

" vim: fdm=marker
