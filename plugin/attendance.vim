scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

command! -nargs=* -complete=custom,tanikawa#attendance#AttendanceReportComp ATAttendanceReport call tanikawa#attendance#AttendanceReport(<f-args>)

" vim: fdm=marker
