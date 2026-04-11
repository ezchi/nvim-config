local capabilities = require("cmp_nvim_lsp").default_capabilities()

vim.lsp.config("basedpyright", {
    capabilities = capabilities,
})

vim.lsp.enable("basedpyright")
