:if !empty(expand('$XDG_CONFIG_HOME/nvim/autoload/plug.vim'))

" Use vim-plug
call plug#begin(expand('$XDG_CONFIG_HOME/nvim/plugged'))

:if expand('$USER') != "root"

"Code completion
Plug 'ms-jpq/coq_nvim', {'branch': 'coq'}
Plug 'ms-jpq/coq.artifacts', {'branch': 'artifacts'}
Plug 'neovim/nvim-lspconfig'

"To get symbols in C/C++ files
"Plug 'vim-scripts/taglist.vim'

"Highlight words under the cursor
Plug 'itchyny/vim-cursorword'

Plug 'lervag/vimtex'

Plug 'jez/vim-superman'

Plug 'ibhagwan/fzf-lua', {'branch': 'main'}

Plug 'SirVer/ultisnips'

Plug 'google/yapf', { 'branch': 'main', 'rtp': 'plugins/vim', 'for': 'python' }

Plug 'godlygeek/tabular'

:endif

" Plugins that may be used with the root account

Plug 'croaker/mustang-vim', { 'frozen' : 1 }
Plug 'bling/vim-bufferline'

"File browser
Plug 'preservim/nerdtree', { 'on':  'NERDTreeToggle' }

Plug 'preservim/vim-markdown', { 'for' : 'markdown' }
call plug#end()

:endif


"language servers
lua << EOF
local lspconfig = require "lspconfig"


if vim.fn.expand("$USER") ~= "root" then
    local coq = require "coq"

    lspconfig.clangd.setup{coq.lsp_ensure_capabilities()}
    lspconfig.pyright.setup{coq.lsp_ensure_capabilities()}
    lspconfig.texlab.setup{coq.lsp_ensure_capabilities()}
    lspconfig.vls.setup{coq.lsp_ensure_capabilities()}
end

do
    vim.keymap.set('n', 'grn', function()
      vim.lsp.buf.rename()
    end, { desc = 'vim.lsp.buf.rename()' })

    vim.keymap.set({ 'n', 'x' }, 'gra', function()
      vim.lsp.buf.code_action()
    end, { desc = 'vim.lsp.buf.code_action()' })

    vim.keymap.set('n', 'grr', function()
      vim.lsp.buf.references()
    end, { desc = 'vim.lsp.buf.references()' })

    vim.keymap.set('i', '<C-S>', function()
      vim.lsp.buf.signature_help()
    end, { desc = 'vim.lsp.buf.signature_help()' })
end

EOF

set nocompatible
filetype plugin indent on

syntax enable "enable syntax highlighting while keeping highlight settings intact

set autoindent
set number
set background=dark
set cursorline "display a line under the cursor

"Man pages
runtime ftplugin/man.vim

"Allow buffers to be hidden when modified
set hidden

"mappings for interacting with buffers
noremap <leader>bn :bnext <CR>
noremap <leader>bp :bprev <CR>
noremap <leader>bg :buf <SPACE>
noremap <leader>bq :bp <BAR> bd #<CR>


set showcmd "show last command in bottom right corner. also: number of selected characters and such

set lazyredraw "redraw only when necessary. may speed up things.

set showmatch "highlight matching parentheses

"tab settings. softtabstop and tabstop should be identical or else mixtures of
"tabs and spaces may be used
set tabstop=4   "visual spaces per tab (existing spaces)
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
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1 "show buffers at the top
let g:airline#extensions#tabline#formatter = 'default'

"##########  Trailing Whitespace ###########

"Define a highlight group and ensure that it survives colorscheme commands
"(some colorscheme commands apparently clear user-defined groups)
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
"Set the default color-scheme
colorscheme mustang

"Make search hits readable
hi Search cterm=NONE ctermfg=black ctermbg=blue

"Make spelling error highlighting a little easier on the eyes
hi clear SpellBad
hi SpellBad cterm=italic,undercurl ctermbg=NONE ctermfg=red gui=italic,undercurl guifg=LightRed

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
        :call matchdelete(w:whitespace_match_number)
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
au BufNewFile,BufRead COMMIT_EDITMSG set spell spl=en
au BufNewFile,BufRead COMMIT_EDITMSG set colorcolumn=72

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
let g:vimtex_indent_enabled=1
let g:vimtex_intent_bib_enabled=1

"configure latexmk
let g:vimtex_compiler_latexmk_engines = {
        \ '_'                : '-xelatex',
        \ 'pdflatex'         : '-pdf',
        \ 'lualatex'         : '-lualatex',
        \ 'xelatex'          : '-xelatex',
        \ 'context (pdftex)' : '-pdf -pdflatex=texexec',
        \ 'context (luatex)' : '-pdf -pdflatex=context',
        \ 'context (xetex)'  : '-pdf -pdflatex=''texexec --xtx''',
        \}
"viewer that is launched
let g:vimtex_view_method='zathura'



noremap <C-B> :FzfLua buffers <CR>
noremap <C-P> :FzfLua files <CR>
noremap <C-F> :FzfLua git_files <CR>

" Snippets
let g:UltiSnipsSnippetDirectories = ['ultisnippets']
let g:UltiSnipsExpandTrigger = '<c-j>'
let g:UltiSnipsJumpForwardTrigger = '<c-j>'
let g:UltiSnipsJumpBackwardTrigger = '<c-k>'

command! -complete=shellcmd -nargs=+ Shell call s:ShellScratch(<q-args>)
command! -complete=shellcmd -nargs=+ SShell call s:ShellScratch(<q-args>, 0)
function! s:ShellScratch(cmdline, wipe=1)
    let l:expanded = []
    for part in split(a:cmdline)
        if part[0] =~ '\v[%#<]'
            let part = expand(part)
        endif
        let part = shellescape(part, 1)
        call add(expanded, part)
    endfor
    let l:final_cmdline = join(l:expanded)
    if a:wipe == 1
        enew|pu=execute('r!' . l:final_cmdline)|setlocal bufhidden=wipe buftype=nofile noswapfile
    else
        enew|pu=execute('r!' . l:final_cmdline)|setlocal buftype=nofile noswapfile
    endif
endfunction

" Add directories to runtime-path
"   based on config files
function! SetupRtp()
py3 << EOF
import os.path
import vim

name = os.path.realpath(vim.current.buffer.name)

dirname, last = os.path.split(name)
rtps = []
while last != "":
    rtprc = os.path.join(dirname, ".vimrtprc")
    if os.path.isfile(rtprc): # also false if doesn't exist
        with open(rtprc, "r") as f:
            lines = f.readlines()
        if len(lines) > 0:
            rtps.extend(lines)
        else:
            rtps.append(dirname)
    dirname, last = os.path.split(dirname)
vim.command('set rtp+={}'.format(",".join(rtps)))
EOF
endfunction

call SetupRtp()


:if !empty(glob("~/.vim/custom"))
for f in split(glob("~/.vim/custom/*"), "\n")
    exe "source" f
endfor
:endif



