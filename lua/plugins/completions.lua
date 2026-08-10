return {
    {
        "Saghen/blink.cmp",
        version = "*",
        -- Replaces yasnippet-snippets + doom-snippets. blink's default snippet
        -- source already sets friendly_snippets = true and scans the runtimepath,
        -- so no LuaSnip is needed: expansion goes through Neovim's built-in
        -- vim.snippet. Custom snippets go in ~/.config/nvim/snippets as VSCode
        -- JSON. (~/.emacs.d/snippets was empty, so nothing had to be ported.)
        dependencies = { "rafamadriz/friendly-snippets" },
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
