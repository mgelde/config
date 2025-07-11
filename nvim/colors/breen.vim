" Maintainer:   Marcus Gelderie
" Version:      1.0
" Last Change:  July 2025

set background=dark

hi clear

if exists("syntax_on")
  syntax reset
endif

let colors_name = "breen"

hi CursorLine                   guibg=#0D3138 ctermbg=236
hi ColorColumn                  guibg=#2d2d2d ctermbg=236
hi CursorColumn                 guibg=#2d2d2d ctermbg=236
hi MatchParen    guifg=#d0fff0  guibg=#0b4338 gui=bold ctermfg=157 ctermbg=237 cterm=bold
hi Pmenu		     guifg=#ffffff  guibg=#091F24 ctermfg=255 ctermbg=238
hi PmenuSel		   guifg=#0FF29F guibg=#14444F ctermfg=0 ctermbg=148 cterm=reverse

" General colors
hi Cursor       guifg=NONE    guibg=#626262 gui=none ctermbg=241
hi Normal       guifg=#e7e7f0 guibg=#0A2328 gui=none ctermfg=253 ctermbg=234
hi NonText      guifg=#808080 guibg=#0A2328 gui=none ctermfg=244 ctermbg=235
hi LineNr       guifg=#808080 guibg=#081820 gui=none ctermfg=244 ctermbg=232
hi StatusLine   guifg=#d3d3d5 guibg=#444444 gui=italic ctermfg=253 ctermbg=238 cterm=italic
hi StatusLineNC guifg=#939395 guibg=#444444 gui=none ctermfg=246 ctermbg=238
hi VertSplit    guifg=#444444 guibg=#444444 gui=none ctermfg=238 ctermbg=238
hi Folded       guifg=#a0a8b0 guibg=#202020 gui=none ctermbg=4 ctermfg=248
hi Title        guifg=#f6f3e8 guibg=NONE	  gui=bold ctermfg=254 cterm=bold
hi Visual       guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=254 ctermbg=4
hi SpecialKey   guifg=#808080 guibg=#202020 gui=none ctermfg=244 ctermbg=236

" Syntax highlighting
" TODO
hi Comment    guifg=#80A080 gui=italic ctermfg=244
hi Boolean    guifg=#b1d631 gui=none ctermfg=148
hi String     guifg=#b1d631 gui=italic ctermfg=148
hi Identifier guifg=#b1d631 gui=none ctermfg=148
hi Function   guifg=#ffffff gui=bold ctermfg=255
hi Type       guifg=#7e8aa2 gui=none ctermfg=103
hi Statement  guifg=#7e8aa2 gui=none ctermfg=103
hi Keyword    guifg=#ff9800 gui=none ctermfg=208
hi Constant   guifg=#ff9800 gui=none  ctermfg=208
hi Number     guifg=#dfa880 gui=none ctermfg=208
hi Special    guifg=#ff9800 gui=none ctermfg=208
hi PreProc    guifg=#faf4c6 gui=none ctermfg=230
hi Todo       guifg=#000204 guibg=#e0a090 gui=italic



hi SpellBad   cterm=italic,undercurl ctermbg=NONE ctermfg=red gui=italic,undercurl guifg=LightRed

" Code-specific colors
hi pythonOperator guifg=#7e8aa2 gui=none ctermfg=103

