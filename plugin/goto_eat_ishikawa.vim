scriptencoding utf-8
" Author: 谷川陽彦 <pureodio1109@gmail.com>

let s:V = vital#_tanikawa#new()
let s:Http = s:V.import('Web.HTTP')
let s:Xml = s:V.import('Web.XML')
let s:Json = s:V.import('Web.JSON')

" GoTo Eat Ishikawa
command! -nargs=1 -complete=file GTEParseHttpFile call <SID>ParseGotoEatIshikawaHttpFile(<q-args>)
command! -nargs=1 -complete=custom,<SID>ComplDateDir GTEParseHttpDir call <SID>ParseGotoEatIshikawaHttpDir(<q-args>)
command! -nargs=1 -complete=customlist,<SID>ComplIshikawaCity GTEGetHtmlFiles call <SID>GetGotoEatHtmlFiles(<q-args>)
command! GTEOpenDirectory call <SID>OpenDirecotry()
command! GTECd call <SID>ChangeDirecotry()

func! s:ParseGotoEatIshikawaHttpFile(filename)
	let parsed = s:Xml.parseFile(a:filename).findAll({'class':'member_item'})
	let output_lines = []

	for node in parsed
		let output_lines += [ node.find({'class':'name'}).value() ]
	endfor

	return output_lines
endfunc

func! s:ParseGotoEatIshikawaHttpDir(dirname)
	let dirname = fnamemodify(a:dirname, ':p:h')
	let file_list = readdir(dirname, {n->n =~ '\.txt$'})
	let output_lines = []
	for file_name in file_list
		let file_name = fnamemodify(dirname . '/' . file_name, ':p')
		redraw | echo file_name
		let output_lines += s:ParseGotoEatIshikawaHttpFile(file_name)
	endfor

	exec 'new' dirname . '.txt'
	% delete _
	call append(0, output_lines)
endfunc

func! s:GetGotoEatHtmlFiles(city_name)

	if !has_key(s:city_list, a:city_name)
		return
	endif

	let city = s:city_list[a:city_name]
	let url = city.url

	" 出力ディレクトリを作成
	let output_dirname = printf('%02d_%s_%s', output_dirroot, city.pri, city.yomi[0], strftime("%Y%m%d_%H%M"))
	let output_dirroot = s:GetOutputRootDir()
	let output_dirpath = printf('%s/%s', output_dirroot, output_dirname)
	call mkdir(output_dirpath)

	" 先頭のページを取得
	let page = s:Http.get(url).content
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
			redraw | echo printf("Completed: %2d / %2d pages", n, max_page_no)
			let page = s:Http.get(url.'/page/'.string(n).'/').content
			call writefile([page], output_dirpath . printf('/%02d.txt', n))
			sleep 100m
		endfor
	endif
	redraw | echo "Finish!"

endfunc

func! s:OpenDirecotry()
	let output_dirroot = s:GetOutputRootDir()
	if exists(':Exp')
		exec 'Exp' output_dirroot
	elseif exists(':Explore')
		exec 'Explore' output_dirroot
	endif
endfunc

func! s:ChangeDirecotry()
	let output_dirroot = s:GetOutputRootDir()
	exec 'cd' output_dirroot
endfunc

let s:city_list = {
			\ '金沢市':     {'pri': 1,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e9%87%91%e6%b2%a2%e5%b8%82/',                   'yomi': ['kanazawa',        'かなざわ']},
			\ '七尾市':     {'pri': 2,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e4%b8%83%e5%b0%be%e5%b8%82/',                   'yomi': ['nanao',           'ななお']},
			\ '小松市':     {'pri': 3,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e5%b0%8f%e6%9d%be%e5%b8%82/',                   'yomi': ['komatsu',         'こまつ']},
			\ '輪島市':     {'pri': 4,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e8%bc%aa%e5%b3%b6%e5%b8%82/',                   'yomi': ['wajima',          'わじま']},
			\ '珠洲市':     {'pri': 5,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e7%8f%a0%e6%b4%b2%e5%b8%82/',                   'yomi': ['suzu',            'すず']},
			\ '加賀市':     {'pri': 6,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e5%8a%a0%e8%b3%80%e5%b8%82/',                   'yomi': ['kaga',            'かが']},
			\ '羽咋市':     {'pri': 7,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e7%be%bd%e5%92%8b%e5%b8%82/',                   'yomi': ['hakui',           'はくい']},
			\ 'かほく市':   {'pri': 8,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e3%81%8b%e3%81%bb%e3%81%8f%e5%b8%82/',          'yomi': ['kahoku',          'かほく']},
			\ '白山市':     {'pri': 9,  'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e7%99%bd%e5%b1%b1%e5%b8%82/',                   'yomi': ['hakusan',         'はくさん']},
			\ '能美市':     {'pri': 10, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e8%83%bd%e7%be%8e%e5%b8%82/',                   'yomi': ['nomi',            'のみ']},
			\ '野々市市':   {'pri': 11, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e9%87%8e%e3%80%85%e5%b8%82%e5%b8%82/',          'yomi': ['nonoichi',        'ののいち']},
			\ '川北町':     {'pri': 12, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e5%b7%9d%e5%8c%97%e7%94%ba/',                   'yomi': ['kawakita',        'かわきた']},
			\ '津幡町':     {'pri': 13, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e6%b4%a5%e5%b9%a1%e7%94%ba/',                   'yomi': ['tsubata',         'つばた']},
			\ '内灘町':     {'pri': 14, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e5%86%85%e7%81%98%e7%94%ba/',                   'yomi': ['utinada',         'うちなだ']},
			\ '志賀町':     {'pri': 15, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e5%bf%97%e8%b3%80%e7%94%ba/',                   'yomi': ['sika',            'しか']},
			\ '宝達志水町': {'pri': 16, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e5%ae%9d%e9%81%94%e5%bf%97%e6%b0%b4%e7%94%ba/', 'yomi': ['houdatsushimizu', 'ほうだつしみず']},
			\ '中能登町':   {'pri': 17, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e4%b8%ad%e8%83%bd%e7%99%bb%e7%94%ba/',          'yomi': ['nakanoto',        'なかのと']},
			\ '穴水町':     {'pri': 18, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e7%a9%b4%e6%b0%b4%e7%94%ba/',                   'yomi': ['anamizu',         'あなみず']},
			\ '能登町':     {'pri': 19, 'url': 'https://ishikawa-gotoeat-cpn.com/cities/%e8%83%bd%e7%99%bb%e7%94%ba/',                   'yomi': ['noto',            'のと']}
			\ }

func! s:ComplIshikawaCity(ArgLead, CmdLine, CursorPos)
	let list = []
	for [key, vals] in items(s:city_list)
		for val in vals.yomi + [key]
			if val =~ '.*' . a:ArgLead . '.*'
				let list += [ key ]
				break
			endif
		endfor
	endfor
	call sort(list, {a,b->s:city_list[a].pri-s:city_list[b].pri})
	return list
endfunc

func! s:ComplDateDir(ArgLead, CmdLine, CursorPos)
	return join(reverse(readdir('.', {n->isdirectory(n)})), "\n")
endfunc

func! s:GetOutputRootDir()
	if exists('g:tanikawa_gte_output_dirroot')
		let output_dirroot = g:tanikawa_gte_output_dirroot
	else
		let output_dirroot = '.'
	endif
	return output_dirroot
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
