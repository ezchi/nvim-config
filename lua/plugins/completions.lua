return {
    {
        "Saghen/blink.cmp",
        version = "*",
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
