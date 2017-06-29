version 5.4             " avoid warning for wrong version

behave xterm            " Sets selectmode, mousemodel, keymodel, selection

filetype off            " Required for vundle
set mouse-=a            " Disable visual mode
set noautoindent        " Turn autoindent off
set noautowrite         " Don't automatically write the file
set background=dark     " Make sure we can read the file we are editing
set backspace=2         " allow backspacing over everything in insert mode
set nobackup            " Don't create backup files
set cmdheight=2         " Less Hit Return messages
set nocompatible        " Use Vim defaults (much better!)
if has("unix")
   set dictionary=/usr/dict/words  " Use with i-ctrl-X ctrl-K
endif
set noerrorbells        " Stop the beeps
if has("unix")
   set fileformats=unix,dos,mac  " Allow editing of all types of files
else
   set fileformats=dos,unix,mac
endif
set history=20          " Keep 20 lines of command line history (use arrow keys for history)
set incsearch           " Incremental search
set nohlsearch          " Turn off search highlighting
set laststatus=2        " Always show status bar
set nolist              " Command to show hidden chacters: tabs, eol's
set modeline            " Scan for modeline commands
set modelines=5         " Scan 5 lines for modelines
set report=0            " Always report line changes for : commands
set ruler               " Show cursor location
set shortmess=a         " Abbreviate the status messages
set showcmd             " Show command I'm typing
set showmatch           " Show matching brace
set smarttab            " Tab in front of line uses shiftwidth - good for coding
set tw=0                " don't automatically wrap my text
set viminfo='20,\"50    " read/write a .viminfo file, don't store more
                        " than 50 lines of registers
set visualbell          " Try to flash instead
set wildchar=<TAB>      " Character to start command line completion
set wildmenu            " Enhanced command line completion
set writebackup         " Make temp backup while overwrite file (for safety)

" tab, linebreak & wrap settings
set expandtab           " I hate tabs!
set tabstop=4
set softtabstop=4
set shiftwidth=4
set shiftround
set linebreak
set wrap

" Set Tab to Spaces
map <silent> TS :set expandtab<CR>:%retab!<CR>
" Set Tab back to Tabs
map <silent> TT :set noexpandtab<CR>:%retab!<CR>
" Set Tab spacing
map <silent> T@ :call NewTabSpacing(2)<CR>
map <silent> T# :call NewTabSpacing(3)<CR>
map <silent> T$ :call NewTabSpacing(4)<CR>
map <silent> T* :call NewTabSpacing(8)<CR>

function NewTabSpacing (newtabsize)
   let was_expanded = &expandtab
   normal TT
   execute "set ts=" . a:newtabsize
   execute "set sw=" . a:newtabsize
   execute "map          F !GautoFormat -T" . a:newtabsize . " -"
   execute "map <silent> f !GautoFormat -T" . a:newtabsize . "<CR>"
   if was_expanded
      normal TS
   endif
endfunction

" ,j loads the java file starting for this file name.  This
"    is very common in Net Dynamics so I made an alias
map ,j :n %:r.java<CR>

"
" set the size for win32
"
if ! has("unix")
   win 80 42
   set guifont=Courier_New:h8
endif


augroup cprog
  au!

  autocmd FileType cpp,c,xs call FT_cpp()

  function FT_cpp()
    set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,b:// cinkeys=0{,0},0#,!^F,o,O,e
    call Set_comments("c")
  endfunction
augroup END


augroup java
  au!

  autocmd FileType java call FT_java()

  function FT_java()
    set formatoptions=croql cindent comments=sr:/*,mb:*,el:*/,b:// cinkeys=0{,0},0#,!^F,o,O,e
    call Set_comments("j")
  endfunction
augroup END


augroup perl
  au!

  autocmd FileType perl call FT_perl()

  function FT_perl()
    call Set_comments("p")
  endfunction
augroup END


function Set_comments(type)
  if has("unix")
     let perlpath=$VIM
  else
     let perlpath="perl " .  $VIM
  endif

  exe "vmap ,i ! " . perlpath . "/cor.pl -l " . a:type . " -b i<CR>"
  exe "vmap ,c ! " . perlpath . "/cor.pl -l " . a:type . " -b c<CR>"
  exe "vmap ,o ! " . perlpath . "/cor.pl -l " . a:type . " -b o<CR>"
  exe "vmap ,r ! " . perlpath . "/cor.pl -l " . a:type . " -r<CR>"
endfunction

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Disable security risk features in .vimrc and .exrc in directories I edit in
set secure

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setting up Vundle - the vim plugin bundler
let getVundle=1
let vundle_readme=expand('~/.vim/bundle/vundle/README.md')
if !filereadable(vundle_readme)
  echo "Installing Vundle..."
  echo ""
  silent !mkdir -p ~/.vim/bundle
  silent !git clone https://github.com/gmarik/vundle ~/.vim/bundle/vundle
  let getVundle=0
endif
set rtp+=~/.vim/bundle/vundle/

call vundle#rc()
Bundle 'gmarik/vundle'
" Add your bundles here
Bundle 'scrooloose/nerdtree'
Bundle 'jnurmine/Zenburn'
Bundle 'godlygeek/tabular'
Bundle 'Shougo/neocomplcache.vim'

if getVundle == 0
  echo "Installing Bundles, please ignore key map error messages"
  echo ""
  :BundleInstall
endif

" Brief help
" :BundleList          - list configured bundles
" :BundleInstall(!)    - install (update) bundles
" :BundleSearch(!) foo - search (or refresh cache first) for foo
" :BundleClean(!)      - confirm (or auto-approve) removal of unused bundles"
" see :h vundle for more details or wiki for FAQ
" NOTE: comments after Bundle commands are not allowed.
" Setting up Vundle - the vim plugin bundler end
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

filetype plugin indent on

" neocomplcache keybindings
let g:neocomplcache_enable_at_startup = 1

" nerdtree
map <leader>n :NERDTreeToggle<CR>

" remove trailing whitespace in puppet files
autocmd FileType puppet autocmd BufWritePre <buffer> :%s/\s\+$//e

color zenburn
syn on
