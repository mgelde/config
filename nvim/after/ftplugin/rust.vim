set colorcolumn=100
set foldmethod=syntax

set noexpandtab
set softtabstop=0

noremap ,i :YcmCompleter Format <CR>
inoremap ,i <ESC> :YcmCompleter Format <CR>i
noremap ,o :YcmCompleter Format <CR>
inoremap ,o <ESC> :YcmCompleter Format <CR>i
