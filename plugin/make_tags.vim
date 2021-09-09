scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:prefix = tanikawa#util#GetPrefix('MT')

exec 'command! -nargs=* -complete=dir' s:prefix . 'MkTagsC'   'call tanikawa#make_tags#MakeTags("c", <f-args>)'
exec 'command! -nargs=* -complete=dir' s:prefix . 'MkTagsCS'  'call tanikawa#make_tags#MakeTags("cs", <f-args>)'
exec 'command! -nargs=* -complete=dir' s:prefix . 'MkTagsVBA' 'call tanikawa#make_tags#MakeTags("vba", <f-args>)'
exec 'command! -nargs=* -complete=dir' s:prefix . 'MkTags'    'call tanikawa#make_tags#MakeTags("all", <f-args>)'
