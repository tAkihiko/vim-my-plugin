scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>
" 引用元: Vimテクニックバイブル

let s:V = vital#_tanikawa#new()
let s:Http = s:V.import('Web.HTTP')

function! s:URLEncode()
	let l:line = getline('.')
	let l:encoded = s:Http.encodeURIComponent(l:line)
	call setline('.', l:encoded)
endfunction

function! s:URLDecode()
	let l:line = getline('.')
	let l:encoded = s:Http.decodeURI(l:line)
	call setline('.', l:encoded)
endfunction

command! -nargs=0 -range URLEncode :<line1>,<line2>call <SID>URLEncode()
command! -nargs=0 -range URLDecode :<line1>,<line2>call <SID>URLDecode()
