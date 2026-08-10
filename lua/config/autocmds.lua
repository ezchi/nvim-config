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

-- Per-filetype indentation. The global default in options.lua is 4 spaces,
-- which is right for Python, C++ and SystemVerilog but wrong for these.
autocmd("FileType", {
    pattern = { "lua", "yaml", "json", "toml", "jinja", "html", "css" },
    desc = "Two-space indent for markup and config filetypes",
    callback = function()
        vim.opt_local.shiftwidth = 2
        vim.opt_local.tabstop = 2
    end,
})

-- super-save. Write modified file-backed buffers when focus or the buffer is
-- left, so switching to a terminal or another app never loses work.
autocmd({ "FocusLost", "BufLeave" }, {
    desc = "Auto-save modified buffers (super-save)",
    callback = function(event)
        local buf = event.buf
        if
            not vim.bo[buf].modified
            or not vim.bo[buf].modifiable
            or vim.bo[buf].readonly
            or vim.bo[buf].buftype ~= ""
            or vim.api.nvim_buf_get_name(buf) == ""
        then
            return
        end
        vim.api.nvim_buf_call(buf, function()
            vim.cmd("silent! write")
        end)
    end,
})

