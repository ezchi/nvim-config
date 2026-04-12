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
