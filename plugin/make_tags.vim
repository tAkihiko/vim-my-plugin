" Author: 谷川陽彦 <pureodio1109@gmail.com>
scriptencoding utf-8

command! MkCTags call tanikawa#make_tags#MakeTags('c')
command! MkCSTags call tanikawa#make_tags#MakeTags('cs')
command! MkVBATags call tanikawa#make_tags#MakeTags('vba')
command! MkTags call tanikawa#make_tags#MakeTags('all')

