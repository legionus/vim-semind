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

function! s:quickFixFormater(info) abort
	let qfl = getqflist(#{id: a:info.id, items: 0}).items

	let lnum_width = range(a:info.start_idx - 1, a:info.end_idx - 1)
				\ ->map({_, v -> qfl[v].lnum})
				\ ->max()
				\ ->len()
	let col_width = range(a:info.start_idx - 1, a:info.end_idx - 1)
				\ ->map({_, v -> qfl[v].col})
				\ ->max()
				\ ->len()
	let fname_width = range(a:info.start_idx - 1, a:info.end_idx - 1)
				\ ->map({_, v -> qfl[v].bufnr->bufname()->strchars(1)})
				\ ->max()
	let module_width = range(a:info.start_idx - 1, a:info.end_idx - 1)
				\ ->map({_, v -> qfl[v].module->strchars(1)})
				\ ->max()

	let l = []

	for i in range(a:info.start_idx - 1, a:info.end_idx - 1)
		let e = qfl[i]

		if e.valid
			call add(l, printf('%-*S | %*d col %*d | %-*S | %s',
						\ fname_width, bufname(e.bufnr),
						\ lnum_width, e.lnum,
						\ col_width, e.col,
						\ module_width, e.module,
						\ e.text))
		else
			call add(l, 'EE ' .. e.text)
		endif
	endfor

	return l
endfunction

function! s:openResultBuffer()
	let qf = get(g:, 'semind_window_position', []) + []
	let winsz = get(g:, 'semind_window_size', 10)

	if get(g:, 'semind_window_shrink', 0) == 1
		let result_len = get(g:, 'qfix_result_len', 0)
		if result_len < winsz
			let winsz = result_len + 1
		else
			let winsz = winsz
		endif
	endif

	call add(qf, 'copen')
	call add(qf, winsz)

	execute join(qf, ' ')

	let g:qfix_win = bufnr("$")
endfunction

function! s:closeResultBuffer()
	execute 'cclose'
	unlet g:qfix_win
endfunction

function! s:semindSearch(...)
	let cmd = [
		\ get(g:, 'semind_prog', 'semind'),
		\ 'search',
		\ '--format="%f:%l:%c: (%m) %C # %s "' ]
	for a in a:000
		call add(cmd, shellescape(a))
	endfor

	let result = systemlist(join(cmd, ' '))

	if len(result) == 0
		echomsg "semind: nothing was found."
		return
	endif

	let g:qfix_result_len = len(result)

	call s:openResultBuffer()
	call setqflist([], 'r',
				\ {
				\ 'title': 'semind search results: ' . join(a:000, ' '),
				\ 'efm': '%f:%l:%c: %o #%*[ 	]%m',
				\ 'quickfixtextfunc': 's:quickFixFormater',
				\ 'lines': result,
				\ })
	execute 'set' 'nowrap'
endfunction

function! s:quickfixToggle(forced)
	if exists("g:qfix_win") && a:forced == 0
		call s:closeResultBuffer()
	else
		call s:openResultBuffer()
	endif
endfunction

command -bang -nargs=? QFixToggle                  call s:quickfixToggle(<bang>0)
command -bang -nargs=? SemindQuickSearchUsage      call s:semindSearch(expand("<cword>"))
command -bang -nargs=? SemindQuickSearchDefinition call s:semindSearch("-m", "def", expand("<cword>"))
command       -nargs=+ SemindSearch                call s:semindSearch(<f-args>)

nmap <silent> <C-s>q :QFixToggle<CR>
nmap <silent> <C-s>s :SemindQuickSearchUsage<CR>
nmap <silent> <C-s>d :SemindQuickSearchDefinition<CR>
