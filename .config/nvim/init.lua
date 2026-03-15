-- Main Neovim entrypoint for the portable terminal-first setup.
--
-- This file owns editor-wide defaults such as UI behavior, search, folds,
-- indentation, backup paths, package loading, and host overlay loading.
-- Most keymaps and plugin-specific behavior live under `plugin/`.
--
-- Common edits:
-- - global editor defaults: edit the matching section in this file
-- - keymaps: edit files under `plugin/`
-- - host-only overrides: edit `host-specific/`
-- - plugin set: edit `pack/` and related runtime config

-- {{{1 Leader keys
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- {{{1 Terminal colors
-- Enable true color support
if vim.fn.has('termguicolors') == 1 then
  vim.opt.termguicolors = true
end

-- {{{1 Uncategorized
-- Make any buffer able to be hidden even if not saved
vim.opt.hidden = true
-- no word wrap:
vim.opt.wrap = false
-- Easier to launch new splits:
vim.opt.splitbelow = true
vim.opt.splitright = true
-- When opening new files, look recursively into subdirectories
vim.opt.path:append('**')
-- The languages I speak
vim.opt.spelllang = { 'en', 'he' }
vim.cmd('filetype plugin on')
-- Default tex flavor
vim.g.tex_flavor = 'latex'
-- file completion
vim.opt.isfname:remove('=')

-- {{{1 keys timeout
vim.opt.timeoutlen = 1000
-- make the return to normal mode with escape not take too long and confuse me:
vim.opt.ttimeoutlen = 0

-- {{{1 search
-- highlight search during typing
vim.opt.hlsearch = false
-- incremental search
vim.opt.incsearch = true
-- incremental substitution
if vim.fn.exists('&inccommand') == 1 then
  vim.opt.inccommand = 'split'
end
-- Smart case: case-sensitive when uppercase, otherwise - not.
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- {{{1 UI
-- Colors
vim.opt.autoread = true
vim.cmd('syntax enable')
vim.cmd('hi normal guibg=#000000 ctermbg=0')
-- who uses Ex mode?
vim.keymap.set('', 'Q', '<nop>')
-- Always display the tabline, even if there is only one tab:
vim.opt.showtabline = 2
vim.opt.list = true
if vim.env.DISPLAY ~= '' then
  vim.opt.showbreak = 'ˆ'
  vim.opt.listchars = { tab = '› ', trail = '-', extends = '»', precedes = '«', eol = '¬' }
else
  vim.opt.showbreak = '^'
  vim.opt.listchars = { tab = '> ', trail = '-', extends = '»', precedes = '«', eol = '¬' }
  -- Used by ~/.zshrc and potentially other configs
  vim.env.TERM_NO_ICONS_FONT = '1'
end
-- Always display the statusline in all windows:
vim.opt.laststatus = 2
-- Hide the default mode text (e.g. -- INSERT -- below the statusline):
vim.opt.showmode = false
-- enable mouse actions
vim.opt.mouse = 'a'

-- {{{1 folds
local function large_files_setup()
  vim.opt_local.foldmethod = 'indent'
  vim.opt_local.foldexpr = '0'
  require('cmp').setup.buffer({ enabled = false })
  vim.b.nix_disable_fenced_highlight = 1
  vim.b.lexima_disabled = 1
end

if vim.fn.has('nvim-0.7') == 1 then
  vim.opt.foldmethod = 'expr'
  vim.opt.foldexpr = 'nvim_treesitter#foldexpr()'
end

vim.api.nvim_create_autocmd('BufReadPre', {
  callback = function(args)
    local filesize = vim.fn.getfsize(vim.fn.expand('<afile>'))
    if filesize > 1024 * 1024 then  -- 1MB threshold
      large_files_setup()
    end
  end,
})

vim.opt.foldenable = true
-- indentation rules, read more at :help indent.txt
vim.g.vim_indent_cont = vim.o.shiftwidth
vim.opt.foldcolumn = '2'
-- set lazyredraw only on ssh
if vim.env.SSH_CLIENT ~= '' then
  vim.opt.lazyredraw = true
end

-- {{{1 UX
-- From some reason this is not the default on Vim, see
-- https://vi.stackexchange.com/a/2163/6411
vim.opt.backspace = { 'indent', 'eol', 'start' }

-- {{{1 tab's and indentation preferences:
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4
vim.opt.autoindent = true
vim.opt.smartindent = true
vim.opt.preserveindent = true
vim.cmd('filetype indent on')

-- {{{1 backup and restore
-- https://www.reddit.com/r/neovim/comments/1e5d7zw/windows_backupdir_related_settings_best_practices/
vim.opt.shellslash = true
vim.opt.backupdir = vim.fn.expand('~/.local/share/nvim/tmp//')
vim.opt.directory = vim.fn.expand('~/.local/share/nvim/tmp//')
vim.opt.viewdir = vim.fn.expand('~/.local/share/nvim/view//')
-- restore-view setting:
vim.opt.viewoptions = { 'cursor' }
-- mks settings:
vim.opt.sessionoptions = { 'folds', 'help', 'resize', 'tabpages', 'winpos', 'winsize' }

-- {{{1 Load local configuration, not using exrc since I use `prj-vim`
vim.opt.modeline = true

-- {{{1 Enable to add plugins via $ENABLE_PLUGINS
if vim.env.ENABLE_PLUGINS and vim.env.ENABLE_PLUGINS ~= '' then
  local plugins_list = vim.split(vim.env.ENABLE_PLUGINS, ',')
  if vim.fn.exists(':packadd') == 2 then
    for _, pl in ipairs(plugins_list) do
      vim.cmd('packadd ' .. pl)
    end
  else
    vim.notify("You don't have :packadd available, hence $ENABLE_PLUGINS is not supported", vim.log.levels.ERROR)
  end
end

-- External Plugins - use pathogen only for old versions of vim
if vim.fn.exists(':packadd') == 0 then
  vim.cmd('runtime pack/functional/opt/pathogen/autoload/pathogen.vim')
  vim.fn['pathogen#infect']()
end

-- {{{1 Load host-specific configuration
if vim.fn.has('win32') == 0 then
  local host_file = 'host-specific/' .. vim.env.HOST .. '.vim'
  if vim.fn.filereadable(vim.fn.expand('~/.config/nvim/' .. host_file)) == 1 then
    vim.cmd('runtime ' .. host_file)
  end
else
  local host_file = 'host-specific/' .. vim.env.COMPUTERNAME .. '.vim'
  if vim.fn.filereadable(vim.fn.expand('~/.config/nvim/' .. host_file)) == 1 then
    vim.cmd('runtime ' .. host_file)
  end
end

-- {{{1 vimtex configuration
if vim.fn.executable('pplatex') == 1 then
  vim.g.vimtex_quickfix_method = 'pplatex'
end

-- {{{1 Load portable advanced Lua configuration
require('portable_advanced').setup()

-- {{{1 Modeline
-- vim: foldmethod=marker
