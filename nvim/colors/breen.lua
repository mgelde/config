-- Maintainer:   Marcus Gelderie
-- Version:      1.0
-- Last Change:  July 2025

vim.opt.background='dark'

vim.cmd.highlight('clear')

vim.cmd.syntax('reset')

vim.g.colors_name = 'breen'



local function truecolor2termcolor(colorcode)
    local bit = require('bit')
    local number = tonumber(colorcode:sub(2, #colorcode), 16)
    local red = bit.band(bit.rshift(number, 16), 0xFF)
    local green = bit.band(bit.rshift(number, 8), 0xFF)
    local blue = bit.band(number, 0xFF)
    return bit.lshift((red * 7 / 255), 5) + bit.lshift((green * 7 / 255), 2) + (blue * 3 / 255)
end



local function highlight(args)
    local guifg = args.guifg and string.format('guifg=%s', args.guifg) or ''
    local guibg = args.guibg and string.format('guibg=%s', args.guibg) or ''
    local gui = args.gui and string.format('gui=%s', args.gui) or ''
    local ctermfg = args.ctermfg or (args.guifg and string.format('ctermfg=%d', truecolor2termcolor(args.guifg))) or ''
    local ctermbg = args.ctermbg or (args.guibg and string.format('ctermbg=%d', truecolor2termcolor(args.guibg))) or ''
    local cterm = args.cterm or (args.gui and string.format('cterm=%s', args.gui)) or ''
    vim.cmd.highlight(string.format('%s %s %s %s %s %s %s',
        args.group,
        guifg,
        guibg,
        gui,
        ctermbg,
        ctermfg,
        cterm
    ))
end

local background_base_color = '#0f282d'
local background_complementary_color = '#2d140f'
local background_dark_color = '#09191c'
local background_light_color = '#39494c'

highlight{group='Normal', guifg='#e7e7f0', guibg=background_base_color, gui='none'}

highlight{group='CursorLine',    guibg=background_light_color}
highlight{group='LineNr',        guifg='#808080', guibg=background_dark_color, gui='none' }
highlight{group='CursorLineNr',  guifg='#B0D0B0',               gui='bold' }


vim.cmd.highlight('ColorColumn   guibg=#2d2d2d ctermbg=236')
vim.cmd.highlight('CursorColumn  guibg=#2d2d2d ctermbg=236')
vim.cmd.highlight('MatchParen    guifg=#d0fff0  guibg=#0b4338 gui=bold ctermfg=157 ctermbg=237 cterm=bold')
vim.cmd.highlight('Pmenu		 guifg=#ffffff  guibg=#091F24 ctermfg=255 ctermbg=238')
vim.cmd.highlight('PmenuSel		 guifg=#0FF29F guibg=#14444F ctermfg=0 ctermbg=148 cterm=reverse')

vim.cmd.highlight('Cursor       guifg=NONE    guibg=#626262 gui=none ctermbg=241')
vim.cmd.highlight('NonText      guifg=#808080 guibg=#0A2328 gui=none ctermfg=244 ctermbg=235')
vim.cmd.highlight('StatusLine   guifg=#d3d3d5 guibg=#444444 gui=italic ctermfg=253 ctermbg=238 cterm=italic')
vim.cmd.highlight('StatusLineNC guifg=#939395 guibg=#444444 gui=none ctermfg=246 ctermbg=238')
vim.cmd.highlight('VertSplit    guifg=#444444 guibg=#444444 gui=none ctermfg=238 ctermbg=238')
vim.cmd.highlight('Folded       guifg=#a0a8b0 guibg=#202020 gui=none ctermbg=4 ctermfg=248')
vim.cmd.highlight('Title        guifg=#f6f3e8 guibg=NONE	  gui=bold ctermfg=254 cterm=bold')
vim.cmd.highlight('Visual       guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=254 ctermbg=4')
vim.cmd.highlight('SpecialKey   guifg=#808080 guibg=#202020 gui=none ctermfg=244 ctermbg=236')

vim.cmd.highlight('Comment    guifg=#609070 gui=italic ctermfg=244')
vim.cmd.highlight('Boolean    guifg=#91e651 gui=none ctermfg=148')
vim.cmd.highlight('String     guifg=#91e651 gui=italic ctermfg=148')
vim.cmd.highlight('Identifier guifg=#91e651 gui=none ctermfg=148')
vim.cmd.highlight('Function   guifg=#a0F0e0 gui=bold ctermfg=255')
vim.cmd.highlight('Type       guifg=#9e8aa2 gui=none ctermfg=103')
vim.cmd.highlight('Statement  guifg=#9e8aa2 gui=none ctermfg=103')
vim.cmd.highlight('Keyword    guifg=#ff9800 gui=none ctermfg=208')
vim.cmd.highlight('Constant   guifg=#a08890 gui=none  ctermfg=208')
vim.cmd.highlight('Number     guifg=#dfa880 gui=none ctermfg=208')
vim.cmd.highlight('Special    guifg=#ff9800 gui=none ctermfg=208')
vim.cmd.highlight('PreProc    guifg=#faf4d6 gui=none ctermfg=230')
vim.cmd.highlight('Todo       guifg=#000204 guibg=#e0a090 gui=italic')



vim.cmd.highlight('SpellBad   cterm=italic,undercurl ctermbg=NONE ctermfg=red gui=italic,undercurl guifg=LightRed')



vim.cmd.highlight('pythonOperator guifg=#7e8aa2 gui=none ctermfg=103')

