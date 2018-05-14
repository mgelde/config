:if !empty(glob("~/.vim/bundle/Vundle.vim"))

set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

Plugin 'Valloric/YouCompleteMe'

"To get symbols in C/C++ files
Plugin 'taglist.vim'

"File browser
Plugin 'scrooloose/nerdtree'

"Highlight words under the cursor
Plugin 'itchyny/vim-cursorword'

Plugin 'tpope/vim-fugitive'

Plugin 'lervag/vimtex'

Plugin 'ctrlpvim/ctrlp.vim'

" All vundle Plugins must be added before the following line
call vundle#end()            " required

:endif "endif have vundle

filetype plugin indent on    " required

syntax enable "enable syntax highlighting while keeping highlight settings intact

set autoindent
set number
set background=dark

"Allow buffers to be hidden when modified
set hidden

"mappings for interacting with buffers
noremap <leader>bn :bnext <CR>
noremap <leader>bp :bprev <CR>
noremap <leader>bg :buf <SPACE>
noremap <leader>bq :bp <BAR> bd #<CR>

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

"##########  Status Line ###########

"We use airline. This is just legacy for systems without airline
set statusline=%F%m%r%h%w\ [FORMAT=%{&ff}]\ [TYPE=%Y]\ [ASCII=\%03.3b]\ [HEX=\%02.2B]\ [POS=%04l,%04v][%p%%]\ [LEN=%L]
set laststatus=2
set wildmenu
set wildmode=list:longest,full

"Now for airline
let g:airline_theme="onedark"
let g:airline#extensions#branch#enabled = 1 "enable git integration
let g:airline#extensions#tabline#enabled = 1 "show buffers at the top
let g:airline#extensions#tabline#fnamemod = ':t'

"##########  Trailing Whitespace ###########

"Define a highlight group and ensure that it survives colorscheme commands
"(some colorscheme commands apparently clear user-defined groups)
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
"Set the default color-scheme
colorscheme desert

"Make search hits readable
hi Search cterm=NONE ctermfg=black ctermbg=blue

"Make spelling error highlighting a little easier on the eyes
hi clear SpellBad
hi SpellBad cterm=underline ctermbg=Magenta ctermfg=black

"Define a function to highlight trailing whitespaces
"   This function checks for a window-local variable
"   'w:no_trailing_ws_highlight' and ignores trailing
"   whitespace if that variable is set to 1.
function! MyTrailingWhitespaceHighlight()
    if !exists('w:no_trailing_ws_highlight')
        let w:no_trailing_ws_highlight = 0
    endif
    if w:no_trailing_ws_highlight == 1
        return
    endif

    if exists('w:whitespace_match_number')
        call matchdelete(w:whitespace_match_number)
    endif
    let w:whitespace_match_number = matchadd('ExtraWhitespace', '\s\+\%#\@<!$')
endfunction

"enable trailing whitespace matching
call MyTrailingWhitespaceHighlight()

"enure that trailing whitespace highlighting is enabled on new windows
augroup TrailingWhitespace
    au!
    autocmd BufWinEnter * call MyTrailingWhitespaceHighlight()
augroup END

"Binding to delete trailing whitespace
    "define a function to do the job

function MyDeleteTrailingWhitespace()
    :silent! %s/[ \t]\+$//ge
    :nohls
endfunction
    "map to F5 for convenience
noremap <F5> :call MyDeleteTrailingWhitespace() <CR>

" ###############################################


"do not highlight search results
nnoremap m :nohls <CR>

"move 'normally' in wrapped lines
nnoremap j gj
nnoremap k gk

"for git commits:
au BufNewFile,BufRead COMMIT_EDITMSG set spell
au BufNewFile,BufRead COMMIT_EDITMSG set colorcolumn=72

"for taglist
noremap <F1> :Tlist <CR>

"for nerdtree
noremap <F2> :NERDTreeToggle <CR>

"delete without yank
noremap <leader>d "_d

""for vimtex

"prevent files from being recognized as plaintex
let g:tex_flavor = 'latex'

"do not spellcheck comments
let g:tex_comment_nospell = 1

"make support for formatting suck less ever so slightly
let g:vimtex_format_enabled=1

"configure latexmk
let g:vimtex_compiler_latexmk = {
        \ 'backend' : 'jobs',
        \ 'background' : 1,
        \ 'build_dir' : '',
        \ 'callback' : 1,
        \ 'continuous' : 1,
        \ 'executable' : 'latexmk',
        \ 'options' : [
        \   '-xelatex',
        \   '-verbose',
        \   '-file-line-error',
        \   '-synctex=1',
        \   '-interaction=nonstopmode',
        \ ],
        \}

"viewer that is launched
let g:vimtex_view_method='zathura'

" YouComepleteMe
let g:ycm_global_ycm_extra_conf = '~/.vim/.ycm_extra_conf.py'
noremap <leader>yt :YcmCompleter GetType <CR>
noremap <leader>yg :YcmCompleter GoToDefinition <CR>
noremap <leader>yd :YcmCompleter GetDoc <CR>

"TODO:
"gundo
"sessions 'mksession' etc
"

"CptrlP
noremap <C-B> :CtrlPBuffer <CR>
noremap <leader>cp :CtrlPMRU <CR>
let g:ctrlp_extensions = ['autoignore']

:if !empty(glob("~/.vim/custom"))
for f in split(glob("~/.vim/custom/*"), "\n")
    exe "source" f
endfor
:endif
