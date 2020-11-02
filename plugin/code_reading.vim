scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! CRSetChkMode call tanikawa#code_reading#SetSourceCodeCheckMode(1)
command! CRSetChkModeL call tanikawa#code_reading#SetSourceCodeCheckMode(2)
command! CRSetCpMode call tanikawa#code_reading#SetSourceCodeCopyMode(1)
command! -range CRCopySrcCode call tanikawa#code_reading#CopySrcCode(<line1>, <line2>)
