"Use YCM for code formatting for Java

noremap ,i :YcmCompleter Format <CR>
inoremap ,i <ESC> :YcmCompleter Format <CR>i
noremap ,o :YcmCompleter Format <CR>
inoremap ,o <ESC> :YcmCompleter Format <CR>i

"For Java, foldmethod syntax is the way to go
setlocal foldmethod=syntax

