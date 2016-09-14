"Use the clang formatter for C-familiy languages. This
"is also sourced for filetype=cpp
function! MyCodeFormat()
    let my_clang_format_file = "/usr/share/clang/clang-format.py"
    let l:lines = "all"
	execute ":pyf " . my_clang_format_file
endfunction

noremap ,i :call MyCodeFormat() <CR>
inoremap ,i <ESC> :call MyCodeFormat() <CR>i

"For C and the like, foldmethod syntax is the way to go
setlocal foldmethod=syntax