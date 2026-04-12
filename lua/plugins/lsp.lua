return {
    {
        "neovim/nvim-lspconfig",
        keys = {
            { "gd", vim.lsp.buf.definition, desc = "Goto Definition" },
            { "gr", vim.lsp.buf.references, desc = "References" },
            { "gI", vim.lsp.buf.implementation, desc = "Goto Implementation" },
            { "gy", vim.lsp.buf.type_definition, desc = "Goto T[y]pe Definition" },
            { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
            { "K", function() return vim.lsp.buf.hover() end, desc = "Hover" },
            { "gK", function() return vim.lsp.buf.signature_help() end, desc = "Signature Help" },
            { "<c-k>", function() return vim.lsp.buf.signature_help() end, mode = "i", desc = "Signature Help" },
            { "<leader>ca", vim.lsp.buf.code_action, desc = "Code Action", mode = { "n", "x" } },
            { "<leader>cc", vim.lsp.codelens.run, desc = "Run Codelens", mode = { "n", "x" } },
            { "<leader>cC", vim.lsp.codelens.refresh, desc = "Refresh & Display Codelens", mode = { "n" } },
            { "<leader>cr", vim.lsp.buf.rename, desc = "Rename" },
        },
    },

    {
        "hudson-trading/slang-server.nvim",
        opts = {},
    },

    {
        "mason-org/mason.nvim",
        config = function()
            require("mason").setup()
        end,
    },

    {
        "mason-org/mason-lspconfig.nvim",
        dependencies = {
            "mason-org/mason.nvim",
            "neovim/nvim-lspconfig",
        },
        config = function()
            require("mason-lspconfig").setup({
                ensure_installed = { "basedpyright" },
            })
        end,
    },
}

