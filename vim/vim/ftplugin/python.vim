setlocal foldmethod=indent
set colorcolumn=100


noremap ,i :1,$ call yapf#YAPF()<CR>
inoremap ,i <C-O> :call yapf#YAPF() <CR>
