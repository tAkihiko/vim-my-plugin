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
	setlocal filetype=redmine
	setlocal buftype=acwrite
	exec "file" 'Ticket \#'.a:issue_id
	nnoremap <silent><buffer> <C-C> :call <SID>CopyAllLine()<CR>
	autocmd BufWriteCmd,FileWriteCmd,FileAppendCmd <buffer> call <SID>CopyAllLine()

endfunction

function! s:CopyAllLine()
	let cur_pos = getpos(".")
	call cursor(line("$"), 1)
	let last_line = search('^\s*\S', 'bc')
	let lines = getline(1, last_line)
	let @* = join(lines, "\n")

	let &mod = 0
endfunction

function! tanikawa#redmine#MakeRedmineDiffBranch( branchname )
	let l:base_branch = get(g:, 'redmine_base_branch', 'HEAD')
	let last = s:GitCommandList( 'show-branch --merge-base '.l:base_branch.' '.a:branchname )[-1]
	if last =~? '^\x\{1,40}$'
		let last_h = s:GitCommand('rev-parse '.last)
		call tanikawa#redmine#MakeRedmineDiffCommit( last_h, a:branchname)
	else
		echohl Error
		echo last
		echohl None
	endif
endfunction

function! tanikawa#redmine#MakeRedmineDiffCommit( ... )
	if !executable('git')
		return
	endif
	if !exists("g:redmine_url_base") || len( g:redmine_url_base ) <= 0
		echoerr "Redmineの URL を登録してください。"
		return
	endif
	if !exists("g:redmine_project_id") || len( g:redmine_project_id ) <= 0
		echoerr "Redmineの プロジェクトID を登録してください。"
		return
	endif

	if a:0 >= 2
		let [l:a, l:b; rest] = a:000
	elseif a:0 == 1
		let l:a = a:1
		let l:b = 'HEAD'
	endif

	let l:a_sh = s:GitCommand('rev-parse --short ' . l:a)
	let l:b_sh = s:GitCommand('rev-parse --short ' . l:b)
	let l:a_h = s:GitCommand('rev-parse ' . l:a)
	let l:b_h = s:GitCommand('rev-parse ' . l:b)

	let @* = 'commit:' . l:a_sh . ' .. commit:' . l:b_sh . '  ( "差分":' . g:redmine_url_base . '/projects/' . g:redmine_project_id . '/repository/diff?rev='.l:b_h.'&rev_to='.l:a_h.' )'
endfunction

function! tanikawa#redmine#GetRedmineGitBranch(ArgLead, CmdLine, CursorPos)
	return join(map(systemlist('git branch'), 'v:val[2:]'), "\n")
endfunction

" ==================================================================================================

function! s:GitCommand( args )
	return substitute(system('git ' . a:args), "[\r\n]", "", "g")
endfunction

function! s:GitCommandList( args )
	return map(systemlist('git ' . a:args), 'substitute(v:val, "[\r\n]", "", "g")')
endfunction
