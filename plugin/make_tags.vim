scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! MTMkCTags   call tanikawa#make_tags#MakeTags('c')
command! MTMkCSTags  call tanikawa#make_tags#MakeTags('cs')
command! MTMkVBATags call tanikawa#make_tags#MakeTags('vba')
command! MTMkTags    call tanikawa#make_tags#MakeTags('all')

