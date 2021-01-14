scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:V = vital#_tanikawa#new()
let s:Http = s:V.import('Web.HTTP')
let s:Xml = s:V.import('Web.XML')
let s:Json = s:V.import('Web.JSON')
let s:DateTime = s:V.import('DateTime')

func! tanikawa#hokutetsu_bus#GetUnko(update = v:true) abort

	let url = 'http://www.hokutetsu.co.jp/news/unko/101.txt'

	" カレントディレクトリを設定
	let cwd = tanikawa#hokutetsu_bus#ChangeDirecotry(2)

	" 出力ディレクトリを設定
	let output_dirroot = s:GetOutputRootDir()

	" ページを取得
	let res = s:Http.get(url)
	let page = res.content
	let pages = page->substitute('<br\s*\%(\/\)\?>', '\r', 'g')->split('[\r\n]')
	call writefile(pages, output_dirroot . '/101.txt')

	" 変更があったか確認
	let ret = s:GitCheck(output_dirroot)
	if ret == s:GitCheckResult.NoChangedFiles
		redraw | echomsg printf("変更なし")
		call tanikawa#hokutetsu_bus#ChangeDirecotry(-2, cwd)
		return
	endif

	" Updateフラグが無ければ終了
	if !a:update
		return
	endif

	" 更新日時を取得
	let all_headers = s:Http.parseHeader(res.allHeaders)
	if has_key(all_headers, 'Last-Modified')
		let update_time = s:DateTime.from_format(all_headers['Last-Modified']->substitute('GMT\|UTC', '+0000', ''), '%*, %d %b %Y %T %z', 'uk')
		let update_time = update_time.to(s:DateTime.timezone("+0900"))
	else
		let update_time = s:DateTime.now()
	endif

	" git を実行
	let ret = s:GitUpdate(output_dirroot, printf("%s", update_time.format("%F %T")))
	if ret == s:GitUpdateResult.Success
		let ret_str = "(Git Info: OK)"
	elseif ret == s:GitUpdateResult.GitCmdLess
		let ret_str = ""
	elseif ret == s:GitUpdateResult.MissGitDir
		let ret_str = "(Git Info: OK (".output_dirroot." is not git repo))"
	elseif ret == s:GitUpdateResult.FailedGitAdd
		let ret_str = "(Git Info: NG (git failed))"
	elseif ret == s:GitUpdateResult.FailedGitCommit
		let ret_str = "(Git Info: OK (not commited))"
	else
		let ret_str = "(Git Info: NG)"
	end

	redraw | echomsg printf("取得完了")

endfunc

func! tanikawa#hokutetsu_bus#OpenDirecotry()
	let output_dirroot = s:GetOutputRootDir()
	if exists(':Exp')
		exec 'Exp' output_dirroot
	elseif exists(':Explore')
		exec 'Explore' output_dirroot
	endif
endfunc

func! tanikawa#hokutetsu_bus#ChangeDirecotry(mode, path = '.')

	let old_path = getcwd()

	" cd/lcd 選択
	if a:mode == 1 || a:mode == -1
		let cmd = 'cd'
	elseif a:mode == 2 || a:mode == -2
		let cmd = 'lcd'
	else
		echoerr 'Invalid Args: ' . string(a:mode)
	endif

	if a:mode > 0
		let target_path = s:GetOutputRootDir()
	elseif a:mode < 0
		let target_path = a:path
	else
		echoerr 'Invalid Args: ' . string(a:mode)
	endif

	exec cmd target_path

	return old_path
endfunc

func! s:GetOutputRootDir()
	if exists('g:tanikawa_bus_output_dirroot')
		let output_dirroot = g:tanikawa_bus_output_dirroot
	else
		let output_dirroot = '.'
	endif
	return output_dirroot
endfunc

let s:GitCheckResult = {
			\ 'Success':         0,
			\ 'NoChangedFiles': 1,
			\ 'GitCmdLess':      -1,
			\ 'MissGitDir':      -2,
			\ 'FailedGitStatus': -3
			\ }
func! s:GitCheck(gitdir, subdir = ".")
	" 注意: この関数を使うときはカレントディレクトリが
	"       Gitのワーキングディレクトリ内であること！！
	if executable('git')
		if !isdirectory(a:gitdir . '/.git')
			return s:GitCheckResult.MissGitDir
		endif

		" カレントディレクトリが git の管理下でないと git status が正しく機能しない。
		let subdir = "."
		if isdirectory(a:subdir)
			let subdir = a:subdir
		endif
		let ret = system('git --git-dir=' . a:gitdir . '/.git status --short -- ' . a:subdir)
		if 0 != v:shell_error
			return s:GitCheckResult.FailedGitStatus
		endif

		if len(ret) < 1
			return s:GitCheckResult.NoChangedFiles
		endif

		return s:GitCheckResult.Success
	else
		return s:GitCheckResult.GitCmdLess
	endif
	return s:GitCheckResult.Success
endfunc

let s:GitUpdateResult = {
			\ 'Success':         0,
			\ 'GitCmdLess':      -1,
			\ 'MissGitDir':      -2,
			\ 'FailedGitAdd':    -3,
			\ 'FailedGitCommit': -4
			\ }
func! s:GitUpdate(gitdir, message)
	if executable('git')
		if !isdirectory(a:gitdir . '/.git')
			return s:GitUpdateResult.MissGitDir
		endif

		let ret = system('git --git-dir=' . a:gitdir . '/.git add .')
		if 0 != v:shell_error
			return s:GitUpdateResult.FailedGitAdd
		endif

		let ret = system('git --git-dir=' . a:gitdir . '/.git commit -m "Update: ' . a:message . '"')
		if 0 != v:shell_error
			return s:GitUpdateResult.FailedGitCommit
		endif

		return s:GitUpdateResult.Success
	else
		return s:GitUpdateResult.GitCmdLess
	endif
	return s:GitUpdateResult.Success
endfunc
