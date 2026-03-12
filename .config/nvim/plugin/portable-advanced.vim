" Optional advanced Neovim layer for the portable setup.
"
" This keeps richer UI, completion, DAP, and fuzzy-finder integrations out of
" `host-specific/` while still allowing the terminal-first base config to exist
" underneath.

if !has('nvim')
	finish
endif

if !empty($NVIM_PORTABLE_BASE_ONLY)
	finish
endif

silent! packadd sonokai
silent! packadd fzf-lua
if has('nvim-0.10')
	silent! packadd treesitter
	silent! packadd treesitter-textobjects
endif

set completeopt=menu,menuone,noselect
let g:vsnip_snippet_dir = $XDG_CONFIG_HOME . '/nvim/snippets'

if has('termguicolors')
	set termguicolors
endif
let g:sonokai_style = 'maia'
let g:sonokai_disable_terminal_colors = 1
let g:sonokai_colors_override = {'bg0': ['#000000', '0']}
silent! colorscheme sonokai

au FileType dap-repl lua require('portable_advanced').attach_dap_repl()

lua require('portable_advanced').setup()

" vim:foldmethod=marker:ft=vim
