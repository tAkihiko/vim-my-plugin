scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:prefix = tanikawa#util#GetPrefix('MT')

exec 'command!' s:prefix . 'MkTagsC'   'call tanikawa#make_tags#MakeTags("c")'
exec 'command!' s:prefix . 'MkTagsCS'  'call tanikawa#make_tags#MakeTags("cs")'
exec 'command!' s:prefix . 'MkTagsVBA' 'call tanikawa#make_tags#MakeTags("vba")'
exec 'command!' s:prefix . 'MkTags'    'call tanikawa#make_tags#MakeTags("all")'

