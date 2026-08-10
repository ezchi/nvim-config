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
            -- Servers mason should install on a fresh machine. Not listed here
            -- because they come from elsewhere: slang-server and ruff (~/.local/bin),
            -- taplo (cargo), bash-language-server (homebrew).
            require("mason-lspconfig").setup({
                -- Off, because it enables *every* mason package that happens to
                -- have an lspconfig entry. Installing stylua as a formatter also
                -- started `stylua --lsp` as a language server, competing with
                -- conform. Servers are enabled explicitly in lua/config/lsp.lua.
                automatic_enable = false,
                ensure_installed = {
                    "basedpyright",
                    "clangd",
                    "lua_ls",
                    "marksman",
                    "yamlls",
                },
            })
        end,
    },

    {
        "p00f/clangd_extensions.nvim",
        opts = {},
    },
}

