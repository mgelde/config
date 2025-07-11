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
    return string.format('%d', bit.lshift((red * 7 / 255), 5) + bit.lshift((green * 7 / 255), 2) + (blue * 3 / 255))
end



local function highlight(args)
    local guifg = args.guifg and string.format('guifg=%s', args.guifg) or ''
    local guibg = args.guibg and string.format('guibg=%s', args.guibg) or ''
    local gui = args.gui and string.format('gui=%s', args.gui) or ''

    local ctermfg =''
    if args.ctermfg then
        ctermfg = string.format('ctermfg=%s', args.ctermfg)
    elseif args.guifg then
        ctermfg = string.format('ctermfg=%s', truecolor2termcolor(args.guifg))
    end

    local ctermbg = ''
    if args.ctermbg then
        ctermbg = string.format('ctermbg=%s', args.ctermbg)
    elseif args.guibg then
        ctermbg = string.format('ctermbg=%s', truecolor2termcolor(args.guibg))
    end

    local cterm = args.cterm and string.format('cterm=%s', args.cterm) or ''

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

local background_base_color = '#0f2027'
local background_complementary_color = '#2c5b6d'
local background_dark_color = '#081115'
local background_light_color = '#162f39'
local theme_yellow1='#A0C561'

local theme_green='#72AB8C'
local theme_red='#a09060'
local theme_bright_yellow='#d0d0c0'
local theme_blue='#6096b8'
local theme_orange='#cfaa30'
local theme_yellow2='#a1e6a1'

highlight{group='Normal', guifg='#f0f0f0', guibg=background_base_color, gui='none'}

highlight{group='CursorLine',    guibg=background_light_color}
highlight{group='LineNr',        guifg='#808080', guibg=background_dark_color, gui='none' }
highlight{group='CursorLineNr',  guifg='#B0D0B0', gui='bold' }
highlight{group='ColorColumn',   guibg=background_complementary_color}

highlight{group='Pmenu',		 guifg='#E0E0E0', guibg='#102020' }
highlight{group='PmenuSel',		 guifg=theme_green, guibg='#0a0a0a', cterm='reverse'}
highlight{group='Folded',       guifg='#a0a8b0', guibg=background_base_color, gui='none'}
highlight{group='NonText',      guifg='#808080', guibg=background_base_color, gui='none'}
highlight{group='Special',    guifg=theme_orange}


highlight{group='String',     guifg=theme_green, gui='italic'}
highlight{group='PreProc',    guifg=theme_yellow1, gui='none' }
highlight{group='Type',       guifg=theme_blue, gui='none'}
highlight{group='Comment',    guifg='#508080', gui='italic'}
highlight{group='Keyword',    guifg=theme_blue, gui='bold'}
highlight{group='Constant',   guifg=theme_red, gui='none'}
highlight{group='Number',     guifg=theme_red}
highlight{group='Identifier', guifg=theme_yellow2, gui=italic}


highlight{group='Function',     guifg=theme_bright_yellow, gui='bold'}
highlight{group='Statement',    guifg=theme_red, gui='bold' }
highlight{group='Todo',         guifg='#040404', guibg=theme_yellow1, gui='italic'}


vim.cmd.highlight('MatchParen    guifg=#d0fff0  guibg=#0b4338 gui=bold ctermfg=157 ctermbg=237 cterm=bold')

vim.cmd.highlight('Cursor       guifg=NONE    guibg=#626262 gui=none ctermbg=241')
vim.cmd.highlight('StatusLine   guifg=#d3d3d5 guibg=#444444 gui=italic ctermfg=253 ctermbg=238 cterm=italic')
vim.cmd.highlight('StatusLineNC guifg=#939395 guibg=#444444 gui=none ctermfg=246 ctermbg=238')
vim.cmd.highlight('VertSplit    guifg=#444444 guibg=#444444 gui=none ctermfg=238 ctermbg=238')
vim.cmd.highlight('Title        guifg=#f6f3e8 guibg=NONE	  gui=bold ctermfg=254 cterm=bold')
vim.cmd.highlight('Visual       guifg=#faf4c6 guibg=#3c414c gui=none ctermfg=254 ctermbg=4')
vim.cmd.highlight('SpecialKey   guifg=#808080 guibg=#202020 gui=none ctermfg=244 ctermbg=236')




vim.cmd.highlight('SpellBad   cterm=italic,undercurl ctermbg=NONE ctermfg=red gui=italic,undercurl guifg=LightRed')



vim.cmd.highlight('pythonOperator guifg=#7e8aa2 gui=none ctermfg=103')

