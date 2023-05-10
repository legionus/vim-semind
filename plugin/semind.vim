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

function! s:semindSearch(...)
	let cmd = [
		\ get(g:, 'semind_prog', 'semind'),
		\ 'search',
		\ '--format="%f:%l:%c: (%m) %C # %s"' ]
	for a in a:000
		call add(cmd, shellescape(a))
	endfor

	let result = systemlist(join(cmd, ' '))

	if len(result) == 0
		echomsg "semind: nothing was found."
		return
	endif

	execute 'copen' get(g:, 'semind_quickfix_size', 10)

	let g:qfix_win = bufnr("$")

	call setqflist([], 'r',
				\ {
				\ 'title': 'semind search results',
				\ 'efm': '%f:%l:%c: %o #%*[ 	]%m',
				\ 'quickfixtextfunc': 's:quickFixFormater',
				\ 'lines': result,
				\ })
	execute 'set' 'nowrap'
endfunction

command! -nargs=+ SemindSearch call s:semindSearch(<f-args>)

function! s:quickfixToggle(forced)
	if exists("g:qfix_win") && a:forced == 0
		execute 'cclose'
		unlet g:qfix_win
	else
		execute 'copen' get(g:, 'semind_quickfix_size', 10)
		let g:qfix_win = bufnr("$")
	endif
endfunction

command -bang -nargs=? QFix call s:quickfixToggle(<bang>0)
nmap <silent> <C-s>q :QFix<CR>

command -bang -nargs=? SemindQuickSearchUsage call s:semindSearch(expand("<cword>"))
nmap <silent> <C-s>s :SemindQuickSearchUsage<CR>

command -bang -nargs=? SemindQuickSearchDefinition call s:semindSearch("-m", "def", expand("<cword>"))
nmap <silent> <C-s>d :SemindQuickSearchDefinition<CR>
