setlocal foldmethod=indent
set colorcolumn=100

function! YapfAllTheThings()
    let view = winsaveview()
    1,$ call yapf#YAPF()
    call winrestview(view)
endfunction

noremap ,i <CR> :call YapfAllTheThings()<CR>
inoremap ,i <C-O> :call YapfAllTheThings() <CR>

noremap ,o <CR> :call yapf#YAPF()<CR>
inoremap ,o <C-O> :call yapf#YAPF() <CR>

