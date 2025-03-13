if vim.fn.expand('$XDG_CONFIG_HOME/nvim/autoload/plug.vim') ~= '' then
    local Plug = vim.fn['plug#']
    -- Use vim-plug
    vim.fn['plug#begin'](vim.fn.expand('$XDG_CONFIG_HOME/nvim/plugged'))

    if vim.fn.expand('$USER') ~= "root" then

        -- Code completion
        Plug('ms-jpq/coq_nvim', {branch='coq'})
        Plug('ms-jpq/coq.artifacts', {branch='artifacts'})
        Plug('neovim/nvim-lspconfig')

        --Highlight words under the cursor
        Plug('itchyny/vim-cursorword')

        Plug('lervag/vimtex')

        Plug('jez/vim-superman')

        Plug('ibhagwan/fzf-lua', {branch='main'})

        Plug('SirVer/ultisnips')

        Plug('google/yapf', { branch='main', rtp='plugins/vim', ['for']='python' })

    end

    -- Plugins that may be used with the root account

    Plug('croaker/mustang-vim', { frozen=true })

    --File browser
    Plug('preservim/nerdtree', { on='NERDTreeToggle' })

    Plug('preservim/vim-markdown', { ['for']='markdown' })
    vim.fn['plug#end']()
end


-- language servers
if vim.fn.expand("$USER") ~= "root" then
    local lspconfig = require "lspconfig"
    local coq = require "coq"

    lspconfig.clangd.setup(coq.lsp_ensure_capabilities())
    lspconfig.pyright.setup(coq.lsp_ensure_capabilities())
    lspconfig.texlab.setup(coq.lsp_ensure_capabilities())
    lspconfig.vls.setup(coq.lsp_ensure_capabilities())
end

-- keymaps and vim options

vim.keymap.set('n', 'grn', function()
  vim.lsp.buf.rename()
end, { desc = 'vim.lsp.buf.rename()' })

vim.keymap.set({ 'n', 'x' }, 'gra', function()
  vim.lsp.buf.code_action()
end, { desc = 'vim.lsp.buf.code_action()' })

vim.keymap.set('n', 'grr', function()
  vim.lsp.buf.references()
end, { desc = 'vim.lsp.buf.references()' })

vim.keymap.set('i', '<C-S>', function()
  vim.lsp.buf.signature_help()
end, { desc = 'vim.lsp.buf.signature_help()' })

-- mappings for interacting with buffers
vim.keymap.set('', '<leader>bn',  ':bnext <CR>', {noremap = true})
vim.keymap.set('', '<leader>bp',  ':bprev <CR>', {noremap = true})
vim.keymap.set('', '<leader>bg',  ':buf <SPACE>', {noremap = true})
vim.keymap.set('', '<leader>bq',  ':bp <BAR> bd #<CR>', {noremap = true})


-- show whitespaces
vim.opt.listchars= 'eol:$,tab:>-,trail:~,extends:>,precedes:<'
vim.keymap.set('', '<F6>', ':set list! <CR>', {noremap = true})

--do not highlight search results
vim.keymap.set('n', 'm', ':nohls <CR>', {noremap = true})



--move 'normally' in wrapped lines
vim.keymap.set('n', 'j', 'gj', {noremap=true})
vim.keymap.set('n', 'k', 'gk', {noremap=true})


vim.opt.autoindent = true
vim.opt.number = true
vim.opt.background = 'dark'
vim.opt.cursorline = true
vim.opt.hidden = true

--vim.opt.lazyredraw = true -- redraw only when necessary. may speed up things.
vim.opt.showmatch = true

vim.cmd.syntax('enable')
vim.cmd.filetype{'plugin', 'indent', 'on'}

--tab settings. softtabstop and tabstop should be identical or else mixtures of
--tabs and spaces may be used
vim.opt.tabstop=4      -- visual spaces per tab (existing spaces)
vim.opt.softtabstop=4  -- spaces per tab in insert mode (i.e. creating new spaces vs. displaying)
vim.opt.shiftwidth=4   -- spaces used when indenting '>>' or '<<'
vim.opt.expandtab=true -- use spaces not tabs

vim.opt.incsearch = true --highlight search results as you type
vim.opt.hlsearch = true  --highlight search results

-- folds
vim.opt.foldenable = true --enable folding
vim.opt.foldlevelstart=10 --first ten levels of folds are open by default
vim.opt.foldmethod=manual -- others: marker manual expr syntax diff

-- man page viewer
vim.cmd.runtime 'ftplugin/man.vim'


-- Set the default color-scheme
vim.cmd.colorscheme('mustang')

--##########  Status Line ###########

--We use airline. This is just legacy for systems without airline
vim.opt.statusline='%F%m%r%h%w [FORMAT=%{&ff}] [TYPE=%Y] [ASCII=%03.3b] [HEX=%02.2B] [POS=%04l,%04v][%p%%] [LEN=%L]'
vim.opt.laststatus=2
vim.opt.wildmenu=true
vim.opt.wildmode='list:longest,full'

--Now for airline
vim.g['airline_theme']="solarized"
vim.g['airline#extensions#branch#enabled']= 1 --enable git integration
vim.g['airline_powerline_fonts']= 1
vim.g['airline#extensions#tabline#enabled'] = 1 --show buffers at the top
vim.g['airline#extensions#tabline#formatter'] = 'default'

-- for now until libutf8prog is fixed on my machine
--vim.g['airline#extensions#whitespace#enabled'] = 0

-- use .vimrtprc marker-files to add path to runtimepath
-- This is currently only used for ultisnippets and moreover should probably be done somwhere when
-- a new buffer is opened via an autocmd.
do
    local current_buffer_dirname = vim.fs.dirname(vim.api.nvim_buf_get_name(0))

    local rtp_folders = vim.fs.find({'.vimrtprc'},
        {   type='file',
            path=current_buffer_dirname,
            upward=true})
    if #rtp_folders > 0 then
        local filename = rtp_folders[1]
        local rtp_file = io.open(filename)
        local have_lines = false
        for line in rtp_file:lines() do
            if line ~= nil and line ~= "" then
                have_lines = true
                vim.opt.rtp:append(line)
            end
        end
        if not have_lines then
            vim.opt.rtp:append(vim.fs.dirname(filename))
        end
        rtp_file:close()
    end
end


if vim.fn.glob("~/.nvimcustom") ~= "" then
    for _, f in ipairs(vim.fn.glob("~/.nvimcustom/*", false, true)) do
        vim.cmd.source(f)
    end
end




---##########  Trailing Whitespace ###########

-- Trailing Whitespaces
do

    -- DEPRECATED
       -- Define a highlight group and ensure that it survives colorscheme commands
       -- (some colorscheme commands apparently clear user-defined groups)
       -- vim.api.nvim_create_autocmd({'ColorScheme'}, {pattern='*', command='highlight ExtraWhitespace ctermbg=red guibg=red'})
    --- END DEPRECATED

    vim.cmd.highlight('ExtraWhitespace ctermbg=red guibg=red')

    -- Make spelling error highlighting a little easier on the eyes
    vim.cmd.highlight('clear SpellBad')
    vim.cmd.highlight('SpellBad cterm=italic,undercurl ctermbg=NONE ctermfg=red gui=italic,undercurl guifg=LightRed')

    -- Define a function to highlight trailing whitespaces
    --   This function checks for a window-local variable
    --   'w:no_trailing_ws_highlight' and ignores trailing
    --   whitespace if that variable is set to 1.
    local TrailingWhitespaceHighlight = function()
        if vim.w.no_trailing_ws_highlight == nil then
            vim.w.no_trailing_ws_highlight = 0
        end
        if vim.w.no_trailing_ws_highlight == 1 then
            return
        end

        if vim.w.whitespace_match_number ~= nil then
            vim.fn.matchdelete(vim.w.whitespace_match_number)
        end
        vim.w.whitespace_match_number = vim.fn.matchadd('ExtraWhitespace', '\\s\\+\\%#\\@<!$')
    end

    --enable trailing whitespace matching
    TrailingWhitespaceHighlight()

    --enure that trailing whitespace highlighting is enabled on new windows
    vim.api.nvim_create_augroup('TrailingWhitespace', {clear = true })
    vim.api.nvim_create_autocmd({'BufWinEnter'}, {pattern='*', group='TrailingWhitespace', callback=TrailingWhitespaceHighlight })

    -- Binding to delete trailing whitespace
        --define a function to do the job
    local DeleteTrailingWhitespace = function ()
        vim.cmd('silent! %s/[ \\t]\\+$//ge')
        vim.cmd.nohls()
    end
    -- map to F5 for convenience
    vim.keymap.set('', '<F5>',  DeleteTrailingWhitespace, {noremap=true})
end




-- for git commits:
vim.api.nvim_create_autocmd({'BufNewFile','BufRead'}, {pattern='COMMIT_EDITMSG', command=[[
set spell spl=en
set colorcolumn=72
]]})

--for nerdtree
vim.keymap.set('', '<F2>', ':NERDTreeToggle <CR>', {noremap=true})


--for vimtex
-- prevent files from being recognized as plaintex
vim.g.tex_flavor = 'latex'

--do not spellcheck comments
vim.g.tex_comment_nospell = 1

-- make support for formatting suck less ever so slightly
vim.g.vimtex_format_enabled=1
vim.g.vimtex_indent_enabled=1
vim.g.vimtex_intent_bib_enabled=1

--configure latexmk
vim.g.vimtex_compiler_latexmk_engines = {
         ['_']                = '-xelatex',
         ['pdflatex']         = '-pdf',
         ['lualatex']         = '-lualatex',
         ['xelatex']          = '-xelatex',
         ['context (pdftex)'] = '-pdf -pdflatex=texexec',
         ['context (luatex)'] = '-pdf -pdflatex=context',
         ['context (xetex)']  = "-pdf -pdflatex=''texexec --xtx" }

--viewer that is launched
vim.g.vimtex_view_method='zathura'


-- FZF
vim.keymap.set('', '<C-B>', ':FzfLua buffers <CR>', { noremap=true })
vim.keymap.set('', '<C-P>', ':FzfLua files <CR>', { noremap=true })
vim.keymap.set('', '<C-F>', ':FzfLua git_files <CR>', { noremap=true })




-- Snippets
vim.g.UltiSnipsSnippetDirectories = {'ultisnippets'}
vim.g.UltiSnipsExpandTrigger = '<c-j>'
vim.g.UltiSnipsJumpForwardTrigger = '<c-j>'
vim.g.UltiSnipsJumpBackwardTrigger = '<c-k>'

