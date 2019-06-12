scriptencoding cp932

command! MkCTags call tanikawa#make_tags#MakeTags('c')
command! MkCSTags call tanikawa#make_tags#MakeTags('cs')
command! MkVBATags call tanikawa#make_tags#MakeTags('vba')
command! MkTags call tanikawa#make_tags#MakeTags('all')

