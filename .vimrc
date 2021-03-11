""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
set noerrorbells        " Stop the beeps
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

" os dependent settings
if ! has("unix")
    " set the size for win32
    win 80 42
    set guifont=Courier_New:h8
    set fileformats=dos,unix,mac
else
    set dictionary=/usr/dict/words  " Use with i-ctrl-X ctrl-K
    set fileformats=unix,dos,mac    " Allow editing of all types of files

    " Disable backup file on Mac OSX
    let os = substitute(system('uname -s'), "\n", "", "")
    if os == "Darwin"
        set nowritebackup
    endif
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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

" Shift+Tab for tab when expandtab is on
:inoremap <S-Tab> <C-V><Tab>

" ,j loads the java file starting for this file name.  This
"    is very common in Net Dynamics so I made an alias
map ,j :n %:r.java<CR>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

" indent yaml, jinja files to 2 spaces
autocmd FileType yaml setl sw=2 sts=2 ts=2 et
autocmd FileType jinja setl sw=2 sts=2 ts=2 et

" remove trailing whitespace in puppet files
autocmd FileType puppet autocmd BufWritePre <buffer> :%s/\s\+$//e

" Disable security risk features in .vimrc and .exrc in directories I edit in
set secure

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Setup vim-plug (Minimalist Vim Plugin Manager)
let getVIMPlug=1
let vim_plug=expand('~/.vim/autoload/plug.vim')
if !filereadable(vim_plug)
    echo "Installing plug.vim..."
    echo ""
    silent !curl -sfLo ~/.vim/autoload/plug.vim --create-dirs https://git.io/VgrSsw
    let getVIMPlug=0
endif

call plug#begin('~/.vim/plugged')
Plug 'nvie/vim-flake8'
Plug 'jnurmine/Zenburn'
Plug 'junegunn/vim-plug'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'sheerun/vim-polyglot'
Plug 'Glench/Vim-Jinja2-Syntax'
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
call plug#end()

if getVIMPlug == 0
    echo "Installing VIM plugins..."
    echo ""
    :PlugInstall
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin on

" markdown
let g:markdown_fenced_languages = ['bash=sh', 'python=py', 'yaml=yml']

" neocomplcache
let g:neocomplcache_enable_at_startup = 1

" nerdtree
map <leader>n :NERDTreeToggle<CR>

" python error checking
autocmd BufWritePost *.py call flake8#Flake8()

color zenburn

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin on
