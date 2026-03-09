" Installed imperatively
silent! packadd treesitter
" Using win32yank (install via scoop)
set clipboard=unnamedplus
if stridx(&shell, 'bash.exe') >= 0
  " https://vi.stackexchange.com/q/22869/6411
  set shellcmdflag=-c
  set shellquote=
  set shellxquote=
endif
