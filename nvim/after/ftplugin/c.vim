"Use the clang formatter for C-familiy languages. This
"is also sourced for filetype=cpp
function! MyCodeFormat()
    let my_clang_format_file = "/usr/share/clang/clang-format.py"
    let l:lines = "all"
	exec ":silent! py3f " . my_clang_format_file
endfunction

noremap ,i :call MyCodeFormat() <CR>
inoremap ,i <C-O> :call MyCodeFormat() <CR>
noremap ,o :py3f /usr/share/clang/clang-format.py<CR>
inoremap ,o <C-O> :py3f /usr/share/clang/clang-format.py<CR>

"For C and the like, foldmethod syntax is the way to go
setlocal foldmethod=syntax
