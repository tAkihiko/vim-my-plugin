scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

au BufRead,BufNewFile *.wr.txt call tanikawa#weekly_report#CheckFileType(expand("<afile>"))
