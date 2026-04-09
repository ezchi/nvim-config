return {
    {
        "nvim-treesitter/nvim-treesitter",
        build = ":TSUpdate",
        config = function()
            require("nvim-treesitter").setup({
                ensure_installed = {
                    "lua",
                    "markdown",
                    "markdown_inline",
                    "python",
                    "c",
                    "c++",
                },
                highlight = {
                    enable = true,
                },
                indent = {
                    enable = true,
                },
            })
        end,
    },
}
