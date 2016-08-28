" If we have vundle, let's unleash awesome plugins. If not -> "normal" vimrc
:if !empty(glob("~/.vim/bundle/Vundle.vim"))

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'

Plugin 'taglist.vim'

" All vundle Plugins must be added before the following line
call vundle#end()            " required

:endif "endif have vundle

filetype plugin indent on    " required

syntax enable "enable syntax highlighting while keeping highlight settings intact

set autoindent
set number
set background=dark

set cursorline "display a line under the cursor

"this does not work. why?
set showcmd "show last command in bottom right corner. also: number of selected characters and such

set lazyredraw "redraw only when necessary. may speed up things.

set showmatch "highlight matching parentheses

"tab settings. softtabstop and tabstop should be identical or else mixtures of
"tabs and spaces may be used
set tabstop=4   "visual spaces per tab (exisitng spaces)
set softtabstop=4 "spaces per tab in insert mode (i.e. creating new spaces vs. displaying)
set shiftwidth=4 "spaces used when indenting '>>' or '<<'
set expandtab "use spaces not tabs

set incsearch "highlight search results as you type
set hlsearch "highlight search results

set foldenable "enable folding
set foldlevelstart=10 "first ten levels of folds are open by default
noremap <space> za
set foldmethod=manual " others: marker manual expr syntax diff

set listchars=eol:$,tab:>-,trail:~,extends:>,precedes:<
map <F6> :set list! <CR>

"delete trailing whitespace
map <F5> :%s/[ \t]\+$//g <CR>

"do not highlight search results
nnoremap m :nohls <CR>

"We use airline. The above is just legacy for systems without airline
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
set laststatus=2
set wildmenu
set wildmode=list:longest,full

colorscheme desert

"move 'normally' in wrapped lines
nnoremap j gj
nnoremap k gk

"jump to beginning and end of line
nnoremap B ^
nnoremap E $

"for git commits:
au BufNewFile,BufRead COMMIT_EDITMSG set spell
au BufNewFile,BufRead COMMIT_EDITMSG set colorcolumn=72

"for taglist
noremap <F1> :Tlist <CR>

function MyCodeFormat()
    let my_clang_format_file = "/usr/share/clang/clang-format.py"
    let l:lines = "all"
	execute ":pyf " . my_clang_format_file
endfunction

map <C-I> :call MyCodeFormat() <CR>
imap <C-I> <ESC> :call MyCodeFormat() <CR>i

"TODO:
"gundo
"sessions 'mksession' etc

:if !empty(glob("~/.vim/custom"))
for f in split(glob("~/.vim/custom/*"), "\n")
    exe "source" f
endfor
:endif
