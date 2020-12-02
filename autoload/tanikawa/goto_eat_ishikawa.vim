scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:V = vital#_tanikawa#new()
let s:Http = s:V.import('Web.HTTP')
let s:Xml = s:V.import('Web.XML')
let s:Json = s:V.import('Web.JSON')

let s:delimiter = {'filetype': 'tsv', 'delim' : "\t"}

func! tanikawa#goto_eat_ishikawa#ParseGotoEatIshikawaHttpFile(filename) abort
	" 1ファイル分をパース
	let parsed = s:Xml.parseFile(a:filename).findAll({'class':'member_item'})
	let output_lines = []

	" 1行ずつ変換
	for node in parsed
		let name = node.find({'class':'name'}).value()->substitute('\r.*', '', 'g') 
		let address = node.find({'class':'address'}).find({'class':'content'}).value()->substitute('[\r\n\t]\|\%x00','','g')
		let output_lines += [ join([name, address], s:delimiter.delim) ]
	endfor

	return output_lines
endfunc

func! tanikawa#goto_eat_ishikawa#ParseGotoEatIshikawaHttpDir(dirname, open = v:true) abort

	let output_lines = []

	" 中間ファイル保存フォルダからテキストファイルを取得し処理する
	let dirname = fnamemodify(a:dirname, ':p:h')
	let file_list = readdir(dirname, {n->n =~ '\.txt$'})
	for file_name in file_list
		let file_name = fnamemodify(dirname . '/' . file_name, ':p')
		redraw | echo file_name
		let output_lines += tanikawa#goto_eat_ishikawa#ParseGotoEatIshikawaHttpFile(file_name)
	endfor

	" 出力
	" TODO: 2000行を超えるようなら分割する
	let output_file = dirname . '.' . s:delimiter.filetype
	call writefile([join(['店名','住所'],s:delimiter.delim)]+output_lines, output_file)

	if a:open
		exe "edit" output_file
	endif

endfunc

func! s:GetTargetList(name = v:null)
	if a:name == v:null
		" デフォルトのリストを返す
		return s:category_list
	endif

	if has_key(s:city_list, a:name)
		return s:city_list
	elseif has_key(s:category_list, a:name)
		return s:category_list
	else
		return {}
	endif
endfunc

func! tanikawa#goto_eat_ishikawa#GetGotoEatShopListAll() abort
	let cwd = tanikawa#goto_eat_ishikawa#ChangeDirecotry(2)

	let target_list = s:GetTargetList()
	for target in target_list->keys()->sort({a,b->target_list[a].pri-target_list[b].pri})
		call tanikawa#goto_eat_ishikawa#GetGotoEatShopList(target, v:false)
		sleep 500m
	endfor

	let output_dirroot = s:GetOutputRootDir()
	let ret = s:GitUpdate(output_dirroot, printf("%s %s", "All", strftime("%Y%m%d")))
	call tanikawa#goto_eat_ishikawa#ChangeDirecotry(-2, cwd)

	if ret == s:GitUpdateResult.Success
		let ret_str = "更新あり"
	elseif ret == s:GitUpdateResult.GitCmdLess
		let ret_str = ""
	elseif ret == s:GitUpdateResult.MissGitDir
		let ret_str = "(Git Info: OK (".output_dirroot." is not git repo))"
	elseif ret == s:GitUpdateResult.FailedGitAdd
		let ret_str = "(Git Info: NG (git failed))"
	elseif ret == s:GitUpdateResult.FailedGitCommit
		let ret_str = "更新無し"
	else
		let ret_str = "(Git Info: NG)"
	end
	redraw | echomsg printf("All 取得完了: %s", ret_str)
endfunc

func! tanikawa#goto_eat_ishikawa#GetGotoEatShopList(target_name, update = v:true) abort

	let target_list = s:GetTargetList(a:target_name)
	if target_list == {}
		return
	endif

	let target = target_list[a:target_name]
	let url = target.url

	" カレントディレクトリを設定
	let cwd = tanikawa#goto_eat_ishikawa#ChangeDirecotry(2)

	" 出力ディレクトリを作成
	let output_dirname = printf('%02d_%s', target.pri, target.yomi[0])
	let output_dirroot = s:GetOutputRootDir()
	let output_dirpath = printf('%s/%s', output_dirroot, output_dirname)
	if isdirectory(output_dirpath)
		" ディレクトリの中身をクリア
		for txt in readdir(output_dirpath, {n -> n =~ '\.txt$'})
			let finepath = output_dirpath . '/' . txt
			let ret = delete(finepath)
		endfor
	else
		" ディレクトリを作成
		call mkdir(output_dirpath)
	endif

	" 先頭のページを取得
	redraw | echo printf("%s 取得中:  1 / ?? pages", a:target_name)
	let page = s:Http.get(url).content
	" タグ内の半角<>を全角＜＞に置き換え
	" TODO: FIXME: 1つの組み合わせしか置き換えられない
	let page = page->substitute('\(<h4\s*class="name"\s*>[^<]*\)<\([^<]*<\/h4>\)', '\1＜\2', 'g')
	let page = page->substitute('\(<h4\s*class="name"\s*>[^>]*\)>\([^>]*<\/h4>\)', '\1＞\2', 'g')
	call writefile([page], output_dirpath . '/01.txt')

	" 最大のページ番号を取得
	let dom = s:Xml.parse(page).findAll({'class':'page-numbers'})
	let page_numbers = []
	for d in dom
		let page_numbers += [ str2nr(d.value()) ]
	endfor
	let max_page_no = max(page_numbers)

	" 2ページめ以降を取得
	if max_page_no > 1
		for n in range(2,max_page_no)
			redraw | echo printf("%s 取得中: %2d / %2d pages", a:target_name, n, max_page_no)
			let page = s:Http.get(url.'&paged='.string(n)).content
			call writefile([page], output_dirpath . printf('/%02d.txt', n))
			sleep 100m
		endfor
	endif

	" 変更があったか確認
	let ret = s:GitCheck(output_dirroot, output_dirpath)
	if ret == s:GitCheckResult.NoChangedFiles
		redraw | echomsg printf("%s 取得完了: 変更ファイルなし", a:target_name)
		call tanikawa#goto_eat_ishikawa#ChangeDirecotry(-2, cwd)
		return
	endif

	" 一覧ファイルを取得
	call tanikawa#goto_eat_ishikawa#ParseGotoEatIshikawaHttpDir(output_dirpath, a:update)

	" Updateフラグが無ければ終了
	if !a:update
		return
	endif

	" git を実行
	let ret = s:GitUpdate(output_dirroot, printf("%s %s", target.yomi[0], strftime("%Y%m%d")))
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

	redraw | echomsg printf("%s 取得完了: %s", a:target_name, ret_str)

endfunc

func! tanikawa#goto_eat_ishikawa#OpenDirecotry()
	let output_dirroot = s:GetOutputRootDir()
	if exists(':Exp')
		exec 'Exp' output_dirroot
	elseif exists(':Explore')
		exec 'Explore' output_dirroot
	endif
endfunc

func! tanikawa#goto_eat_ishikawa#ChangeDirecotry(mode, path = '.')

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

let s:city_list = {
			\ '金沢市':     {'pri': 1,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e9%87%91%e6%b2%a2%e5%b8%82',                   'yomi': ['kanazawa',        'かなざわ']},
			\ '七尾市':     {'pri': 2,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e4%b8%83%e5%b0%be%e5%b8%82',                   'yomi': ['nanao',           'ななお']},
			\ '小松市':     {'pri': 3,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e5%b0%8f%e6%9d%be%e5%b8%82',                   'yomi': ['komatsu',         'こまつ']},
			\ '輪島市':     {'pri': 4,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e8%bc%aa%e5%b3%b6%e5%b8%82',                   'yomi': ['wajima',          'わじま']},
			\ '珠洲市':     {'pri': 5,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e7%8f%a0%e6%b4%b2%e5%b8%82',                   'yomi': ['suzu',            'すず']},
			\ '加賀市':     {'pri': 6,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e5%8a%a0%e8%b3%80%e5%b8%82',                   'yomi': ['kaga',            'かが']},
			\ '羽咋市':     {'pri': 7,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e7%be%bd%e5%92%8b%e5%b8%82',                   'yomi': ['hakui',           'はくい']},
			\ 'かほく市':   {'pri': 8,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e3%81%8b%e3%81%bb%e3%81%8f%e5%b8%82',          'yomi': ['kahoku',          'かほく']},
			\ '白山市':     {'pri': 9,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e7%99%bd%e5%b1%b1%e5%b8%82',                   'yomi': ['hakusan',         'はくさん']},
			\ '能美市':     {'pri': 10, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e8%83%bd%e7%be%8e%e5%b8%82',                   'yomi': ['nomi',            'のみ']},
			\ '野々市市':   {'pri': 11, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e9%87%8e%e3%80%85%e5%b8%82%e5%b8%82',          'yomi': ['nonoichi',        'ののいち']},
			\ '川北町':     {'pri': 12, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e5%b7%9d%e5%8c%97%e7%94%ba',                   'yomi': ['kawakita',        'かわきた']},
			\ '津幡町':     {'pri': 13, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e6%b4%a5%e5%b9%a1%e7%94%ba',                   'yomi': ['tsubata',         'つばた']},
			\ '内灘町':     {'pri': 14, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e5%86%85%e7%81%98%e7%94%ba',                   'yomi': ['utinada',         'うちなだ']},
			\ '志賀町':     {'pri': 15, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e5%bf%97%e8%b3%80%e7%94%ba',                   'yomi': ['sika',            'しか']},
			\ '宝達志水町': {'pri': 16, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e5%ae%9d%e9%81%94%e5%bf%97%e6%b0%b4%e7%94%ba', 'yomi': ['houdatsushimizu', 'ほうだつしみず']},
			\ '中能登町':   {'pri': 17, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e4%b8%ad%e8%83%bd%e7%99%bb%e7%94%ba',          'yomi': ['nakanoto',        'なかのと']},
			\ '穴水町':     {'pri': 18, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e7%a9%b4%e6%b0%b4%e7%94%ba',                   'yomi': ['anamizu',         'あなみず']},
			\ '能登町':     {'pri': 19, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=%e8%83%bd%e7%99%bb%e7%94%ba',                   'yomi': ['noto',            'のと']}
			\ }

let s:category_list = {
			\ '居酒屋・和食':         {'pri': 1,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E5%B1%85%E9%85%92%E5%B1%8B%E3%83%BB%E5%92%8C%E9%A3%9F&s&post_type=member_store',                                     'yomi': ['izakaya',          'いざかや']},
			\ '寿司・回転寿司':       {'pri': 2,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E5%AF%BF%E5%8F%B8%E3%83%BB%E5%9B%9E%E8%BB%A2%E5%AF%BF%E5%8F%B8&s&post_type=member_store',                            'yomi': ['sushi',            'すし',                 'かいてんすし']},
			\ '洋食':                 {'pri': 3,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E6%B4%8B%E9%A3%9F&s&post_type=member_store',                                                                         'yomi': ['youshoku',         'ようしょく']},
			\ '中華':                 {'pri': 4,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E4%B8%AD%E8%8F%AF&s&post_type=member_store',                                                                         'yomi': ['chuka',            'tyuka',                'ちゅうか']},
			\ 'ラーメン':             {'pri': 5,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E3%83%A9%E3%83%BC%E3%83%A1%E3%83%B3&s&post_type=member_store',                                                       'yomi': ['ramen',            'らーめん']},
			\ 'エスニック・韓国料理': {'pri': 6,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E3%82%A8%E3%82%B9%E3%83%8B%E3%83%83%E3%82%AF%E3%83%BB%E9%9F%93%E5%9B%BD%E6%96%99%E7%90%86&s&post_type=member_store', 'yomi': ['ethnic',           'えすにっく',           'かんこく']},
			\ '焼肉':                 {'pri': 7,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E7%84%BC%E8%82%89&s&post_type=member_store',                                                                         'yomi': ['yakiniku',         'やきにく']},
			\ 'ファミリーレストラン': {'pri': 8,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E3%83%95%E3%82%A1%E3%83%9F%E3%83%AA%E3%83%BC%E3%83%AC%E3%82%B9%E3%83%88%E3%83%A9%E3%83%B3&s&post_type=member_store', 'yomi': ['familyrestaurant', 'ふぁみりーれすとらん', 'ファミレス']},
			\ 'ファストフード':       {'pri': 9,  'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E3%83%95%E3%82%A1%E3%82%B9%E3%83%88%E3%83%95%E3%83%BC%E3%83%89&s&post_type=member_store',                            'yomi': ['fastfood',         'ふぁすとふーど']},
			\ 'カフェ・スウィーツ':   {'pri': 10, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E3%82%AB%E3%83%95%E3%82%A7%E3%83%BB%E3%82%B9%E3%82%A6%E3%82%A3%E3%83%BC%E3%83%84&s&post_type=member_store',          'yomi': ['cafe',             'かふぇ']},
			\ 'その他':               {'pri': 11, 'url': 'https://ishikawa-gotoeat-cpn.com/?cities=&type=%E3%81%9D%E3%81%AE%E4%BB%96&s&post_type=member_store',                                                                'yomi': ['etc',              'そのた']},
			\ }

func! s:ComplIshikawa(list, ArgLead, CmdLine, CursorPos)
	let list = []
	for [key, vals] in items(a:list)
		for val in vals.yomi + [key]
			if val =~ '.*' . a:ArgLead . '.*'
				let list += [ key ]
				break
			endif
		endfor
	endfor
	call sort(list, {a,b->a:list[a].pri-a:list[b].pri})
	return list
endfunc

func! tanikawa#goto_eat_ishikawa#ComplIshikawaCity(ArgLead, CmdLine, CursorPos)
	return s:ComplIshikawa(s:city_list, a:ArgLead, a:CmdLine, a:CursorPos)
endfunc

func! tanikawa#goto_eat_ishikawa#ComplIshikawaCategory(ArgLead, CmdLine, CursorPos)
	return s:ComplIshikawa(s:category_list, a:ArgLead, a:CmdLine, a:CursorPos)
endfunc

func! tanikawa#goto_eat_ishikawa#ComplDateDir(ArgLead, CmdLine, CursorPos)
	return join(readdir('.', {n->isdirectory(n)&&n!~'\.git'}), "\n")
endfunc

func! s:GetOutputRootDir()
	if exists('g:tanikawa_gte_output_dirroot')
		let output_dirroot = g:tanikawa_gte_output_dirroot
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

" リスト作成用
"command! GetCityList call <SID>GetCityList()
func! s:GetCityList()
	if !exists('s:member_list')
		let member_list_content = s:Http.get("https://ishikawa-gotoeat-cpn.com/member_store/").content
		let dom = s:Xml.parse(member_list_content).find({'class' : 'member_btn_wrap'})
		let output = []
		for child in dom.findAll('a')
			let output += [ child.value() ]
			let output += [ child.attr.href ]
		endfor
		let @* = join(output, "\n")
	endif
endfunc
