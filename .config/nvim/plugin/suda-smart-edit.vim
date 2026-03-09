" Portable smart-edit wrapper for suda.vim.
"
" Keep privileged edit support enabled by default, but skip known cases where
" automatic suda entry is more disruptive than helpful.

if !exists('*suda#BufEnter')
	finish
endif

augroup suda_smart_edit
	autocmd!
	autocmd BufEnter * nested call SudaBufEnter()
augroup END

function! SudaBufEnter()
	if !empty($NO_SUDA)
		return
	endif
	if &diff
		return
	endif
	let realpath = resolve(expand('<afile>'))
	if realpath =~ '^/nix' || realpath =~ '^/var'
		return
	endif
	call suda#BufEnter()
endfunction

" vim:foldmethod=marker:ft=vim
