local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
    desc = "Highlight when yanking text", 
    callback = function ()
        vim.highlight.on_yank()
    end,
})

autocmd("FileType", {
    pattern = { "gitcommit", "markdown", "text"},
    desc = "Enable wrap and spell for text-like files",
    callback = function()
        vim.opt_local.wrap = true
        vim.opt_local.spell = true
    end,
})

