let w:no_trailing_ws_highlight = 1
if exists('w:whitespace_match_number')
    :silent! call matchdelete(w:whitespace_match_number)
endif

"Enable automatic line breaks
set tw=100
set colorcolumn=100
set fo+=t2
set fo-=co

set spell
