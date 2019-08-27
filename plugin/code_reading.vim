scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! SetChkMode call tanikawa#code_reading#SetSourceCodeCheckMode(1)
command! SetChkModeL call tanikawa#code_reading#SetSourceCodeCheckMode(2)
command! SetCpMode call tanikawa#code_reading#SetSourceCodeCopyMode(1)
command! -range CopySrcCode call tanikawa#code_reading#CopySrcCode(<line1>, <line2>)
