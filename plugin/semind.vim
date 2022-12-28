" Name: Semind integration
" Author: Alexey Gladkov
" License: MIT License
"
" URL: <https://github.com/legionus/vim-semind>
"
if exists('g:loaded_semind_plugin')
	finish
endif
let g:loaded_semind_plugin = 1

function! s:splitSemind(line)
	let arr = split(a:line, '|', 1)
	if len(arr) > 3
		return [arr[0], arr[1], arr[2], join(arr[3:], '|')]
	endif
	return arr
endfunction

function! s:orderQFix()
	silent execute(':set efm=%f:%l:%c:\ %m')
	silent execute(':set nowrap')
	silent execute(':set modifiable')

	let max = []
	let lastpos = getpos("$")

	let i = 1
	while i <= lastpos[1]
		let line = getline(i)
		let arr = s:splitSemind(line)

		let sz = []

		let j = 0
		while j < len(arr)
			call add(sz, strlen(arr[j]))
			let j = j + 1
		endwhile

		let j = 0
		while j < len(sz)
			if get(max, j, -1) < 0
				call add(max, 0)
			endif
			if sz[j] > max[j]
				let max[j] = sz[j]
			endif
			let j = j + 1
		endwhile

		let i = i + 1
	endwhile

	let i = 1
	while i <= lastpos[1]
		let line = getline(i)
		let arr = s:splitSemind(line)

		let sz = []

		let j = 0
		while j < len(arr)
			call add(sz, strlen(arr[j]))
			let j = j + 1
		endwhile

		let j = 0
		while j < len(sz)
			while sz[j] < max[j]
				let arr[j] .= ' '
				let sz[j] = sz[j] + 1
			endwhile
			let j = j + 1
		endwhile

		if len(arr) > 0
			"call setline(i, join(arr, '|'))
			let line = substitute(arr[3], "^[[:space:]]*", " ", "")
			call setline(i, join([ arr[0], arr[2], line ] + arr[4:], '|'))
		endif

		let i = i + 1
	endwhile

	silent execute(':set nomodified')
endfunction

function! s:semindSearch(...)
	let i = 1
	let args_s = ''
	while i <= a:0
		let args_s .= ' ' . get(a:, i, '')
		let i = i + 1
	endwhile

	let semind = get(g:, 'semind_prog', 'semind')
	let result = system(semind . ' search --format="%f:%l:%c: (%m) %C |%s"' . args_s)

	if len(result) == 0
		echomsg "semind: nothing was found."
		return
	endif

	cgetexpr result
	execute('copen' . get(g:, 'semind_quickfix_size', 10))
	let g:qfix_win = bufnr("$")
	call setqflist([], 'a', {'title': 'search' . args_s})

	execute(':set efm=%f:%l:%c:\ %m')
	execute(':set nowrap')
	execute(':set modifiable')
endfunction

command! -nargs=+ SemindSearch call s:semindSearch(<f-args>)

function! s:quickfixToggle(forced)
	if exists("g:qfix_win") && a:forced == 0
		cclose
		unlet g:qfix_win
	else
		execute('copen ' . get(g:, 'semind_quickfix_size', 10))
		let g:qfix_win = bufnr("$")
	endif
endfunction

command -bang -nargs=? QFix call s:quickfixToggle(<bang>0)
nmap <silent> <C-q> :QFix<CR>

command -bang -nargs=? SemindQuickSearchUsage call s:semindSearch(expand("<cword>"))
nmap <silent> <C-s>s :SemindQuickSearchUsage<CR>

command -bang -nargs=? SemindQuickSearchDefinition call s:semindSearch("-m", "def", expand("<cword>"))
nmap <silent> <C-s>d :SemindQuickSearchDefinition<CR>

if !exists('g:semind_no_quickfix_indent')
	autocmd Filetype qf call s:orderQFix()
endif

