return {
    {
        "Saghen/blink.cmp",
        version = "*",
        -- The `snippets` source below is blink's built-in one, expanding through
        -- Neovim's own vim.snippet. No snippet corpus ships with it: it scans the
        -- runtimepath and ~/.config/nvim/snippets for VSCode-style JSON, so it is
        -- live and empty until you write a snippet there. A community pack
        -- (friendly-snippets, the yasnippet-snippets equivalent) is follow-up F5.
        opts = {
            keymap = {
                preset = "default",
                ["<C-Space>"] = { "show", "show_documentation", "hide_documentation" },
                ["<CR>"] = { "accept", "fallback" },
                ["<Tab>"] = { "select_next", "fallback" },
                ["<S-Tab>"] = { "select_prev", "fallback" },
            },
            sources = {
                default = { "lsp", "path", "snippets", "buffer" },
            },
        },
    },
}
