scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:V = vital#_tanikawa#new()
let s:WebHttp = s:V.import('Web.HTTP')
let s:WebJson = s:V.import('Web.JSON')

function! tanikawa#redmine#GetRedmineIssueDescription(issue_id)
	if !exists("g:redmine_url_base") || len( g:redmine_url_base ) <= 0
		echoerr "Redmineの URL を登録してください。"
		return
	endif
	if !exists("g:redmine_api_key") || len( g:redmine_api_key ) <= 0
		echoerr "Redmineの API KEY を登録してください。"
		return
	endif

	let params = {
				\ "url": g:redmine_url_base . '/issues/' . a:issue_id . '.json', 
				\ "headers" : {"X-Redmine-API-Key": g:redmine_api_key},
				\ }
	let l:json = s:WebHttp.request(params)["content"]
	let l:text = s:WebJson.decode(l:json)

	" ファイルを開く
	if expand('%') == "" && &mod == 0 && &bt == ""
		" 現在の画面で実施
	else
		silent new
	endif

	call setline('.', split(l:text["issue"]["description"], '\r\%x0'))
	setlocal filetype=textile
	nnoremap <silent><buffer> <C-C> :%y*<CR>

endfunction

