scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

"command! -range=% DelConsecutiveDuplicateLines <line1>,<line2>g@\%#=1\%(^\1\n\)\@<=\(.*\)$@norm D
command! -range=% UTDelConsecutiveDuplicateLines call tanikawa#util#DeleteConsecutiveDuplicateLines(<line1>,<line2>)

" 検索文字列を set efm 用の文字列に変更
command! -range UTReplace2EFM :<line1>,<line2> call tanikawa#util#ReplaceToErrorFormat()
