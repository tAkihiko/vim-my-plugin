scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

" 北鉄バス
command! BUSGetUnko call tanikawa#hokutetsu_bus#GetUnko()
command! BUSOpenDirectory call tanikawa#hokutetsu_bus#OpenDirecotry()
command! BUSCd call tanikawa#hokutetsu_bus#ChangeDirecotry(1)
command! BUSLcd call tanikawa#hokutetsu_bus#ChangeDirecotry(2)
