if has("vms")
  set nobackup          " do not keep a backup file, use versions instead
else
  set backup            " keep a backup file (restore to previous version)
  if has('persistent_undo')
    set undofile        " keep an undo file (undo changes after closing)
  endif
endif

if &t_Co > 2 || has("gui_running")
  " Switch on highlighting the last used search pattern.
  set hlsearch
endif

" Put these in an autocmd group, so that we can delete them easily.
augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 80 characters.
  autocmd FileType text setlocal textwidth=80
augroup END

" Add optional packages.
"
" The matchit plugin makes the % command work better, but it is not backwards
" compatible.
" The ! means the package won't be loaded right away but when plugins are
" loaded during initialization.
if has('syntax') && has('eval')
  packadd! matchit
endif

if has('syntax')
  set spelllang=en_us
" set spell
endif

" if has('folding')
  "set foldmethod=syntax
"endif

filetype plugin on

set shiftwidth=4 smarttab
set expandtab
set tabstop=8 softtabstop=0

noremap <Leader>C :!xsel -b < %

filetype plugin indent on
set smartindent
set number
set relativenumber

au! BufRead,BufNewFile *.gltf setfiletype json
au! BufRead,BufNewFile *.conf setfiletype ini

autocmd VimEnter * silent! badd /mnt/Projects/jubilant-parakeet/stdfunc/include/stdfunc.h
autocmd VimEnter * silent! badd /mnt/Projects/jubilant-parakeet/test/include/test.h
autocmd VimEnter * silent! badd /mnt/Projects/jubilant-parakeet/log/include/log.h
