local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("basedpyright", {
    capabilities = capabilities,
})

vim.lsp.config("slang_server", {
    cmd = { "slang-server" },
    filetypes = { "systemverilog", "verilog" },
    root_markers = { ".git", "slang.json", "compile_commands.json" },
    capabilities = capabilities,
})

vim.lsp.config("clangd", {
    capabilities = capabilities,
})

vim.lsp.enable("basedpyright")
vim.lsp.enable("slang_server")
vim.lsp.enable("clangd")

-- Diagnostics presentation, replacing the flymake setup in my-lsp.el.
-- ]e / [e navigate; SPC x x lists. See lua/config/keymaps.lua.
vim.diagnostic.config({
    -- Sort so the worst problem on a line is the one shown inline.
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    },
    -- Inline text for warnings and above only. Hints and info are usually
    -- noise at the end of a line; they still show in the sign column,
    -- on hover, and in the SPC x x list.
    virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        spacing = 2,
        source = "if_many",
    },
    float = {
        border = "rounded",
        source = "if_many",
        header = "",
    },
})
