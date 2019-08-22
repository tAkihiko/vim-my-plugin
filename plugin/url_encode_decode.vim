scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>
" 引用元: Vimテクニックバイブル

function! s:URLEncode()
	if !exists("*AL_urlencode")
		echoerr "Alice.vimが必要です"
		return
	endif

	let l:line = getline('.')
	let l:encoded = AL_urlencode(l:line)
	call setline('.', l:encoded)
endfunction

function! s:URLDecode()
	if !executable("nkf")
		echoerr "nkf が必要です"
		return
	endif

	let l:line = getline('.')
	"let l:encoded = AL_urldecode(l:line)
	let l:encoded = iconv(system('nkf -w --url-input', l:line), "utf-8", &enc)
	call setline('.', l:encoded)
endfunction

command! -nargs=0 -range URLEncode :<line1>,<line2>call <SID>URLEncode()
command! -nargs=0 -range URLDecode :<line1>,<line2>call <SID>URLDecode()
