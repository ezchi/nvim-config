local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("basedpyright", {
    capabilities = capabilities,
})

vim.lsp.enable("basedpyright")
