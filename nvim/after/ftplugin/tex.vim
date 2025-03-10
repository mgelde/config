set spell
set spelllang=de

"Enable automatic line breaks
set tw=100
set colorcolumn=100
set fo+=t


:COQnow --shut-up


" vimtex sets this mapping, we want to override it
nunmap <buffer> <localleader>lt
nnoremap <unique> <buffer> <localleader>lt <Plug>(vimtex-toggle-main)
