scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

" GoTo Eat Ishikawa
"command! -nargs=1 -complete=file GTEParseHttpFile call tanikawa#goto_eat_ishikawa#ParseGotoEatIshikawaHttpFile(<q-args>)
"command! -nargs=1 -complete=custom,tanikawa#goto_eat_ishikawa#ComplDateDir GTEParseHttpDir call tanikawa#goto_eat_ishikawa#ParseGotoEatIshikawaHttpDir(<q-args>)
command! -nargs=1 -complete=customlist,tanikawa#goto_eat_ishikawa#ComplIshikawaCity GTEGetShopList call tanikawa#goto_eat_ishikawa#GetGotoEatShopList(<q-args>)
command! GTEGetShopListAll call tanikawa#goto_eat_ishikawa#GetGotoEatShopListAll()
command! GTEOpenDirectory call tanikawa#goto_eat_ishikawa#OpenDirecotry()
command! GTECd call tanikawa#goto_eat_ishikawa#ChangeDirecotry(1)
command! GTELcd call tanikawa#goto_eat_ishikawa#ChangeDirecotry(2)
