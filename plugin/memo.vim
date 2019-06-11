scriptencoding cp932

command! -nargs=? MkMemo call tanikawa#memo#MkMemo(<q-args>)
command! EdMemo call tanikawa#memo#EdMemo()

" vim: fdm=marker
