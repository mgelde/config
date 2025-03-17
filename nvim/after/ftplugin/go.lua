vim.opt.colorcolumn='100'
vim.opt.foldmethod=syntax

vim.opt.expandtab=false
vim.opt.softtabstop=0

vim.keymap.set('', ',i', function() vim.lsp.buf.format({range=nil}) end, {noremap=true})
vim.keymap.set('', ',o', function() vim.lsp.buf.format() end, {noremap=true})

vim.cmd.COQnow('--shut-up')
