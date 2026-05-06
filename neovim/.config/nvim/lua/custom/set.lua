vim.opt.termguicolors = true
vim.opt.background = 'dark'
-- disabled netrw as per nvim-tree suggestion
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.opt.mouse = ''
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = vim.fn.stdpath("data") .. "/undodir"
vim.opt.undofile = true

vim.opt.wrap = false

vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.scrolloff = 8
vim.opt.shiftwidth = 4
vim.opt.signcolumn = 'yes'
vim.opt.smartindent = true
vim.opt.splitright = true
vim.opt.tabstop = 4
vim.opt.colorcolumn = "110"

vim.opt.spelllang = 'en_us,en_gb,pl'
vim.opt.spell = true

vim.diagnostic.config({
    virtual_text = true,
})

vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.cls", "*.trigger", "*.apex" },
    command = "set filetype=apex"
})
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern = { "*.soql" },
    command = "set filetype=soql"
})
