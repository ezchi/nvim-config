return {
    {
        "vhyrro/luarocks.nvim",
        priority = 1000,
        config = function(_, opts)
            local rocks_path = vim.fn.stdpath("data") .. "/lazy/luarocks.nvim/.rocks"
            package.path = package.path .. ";" .. rocks_path .. "/share/lua/5.1/luarocks/vendor/?.lua"
            require("luarocks-nvim").setup(opts)
        end,
        opts = {
            rocks = { "neorg" },
        },
    },
    {
        "nvim-neorg/neorg",
        dependencies = { "luarocks.nvim" },
        lazy = false, -- Disable lazy loading as per Neorg's recommendation
        version = "*",
        config = function()
            require("neorg").setup({
                load = {
                    ["core.defaults"] = {},
                    ["core.concealer"] = {},
                    ["core.dirman"] = {
                        config = {
                            workspaces = {
                                notes = "~/Projects/neorg/notes",
                            },
                            default_workspace = "notes",
                        },
                    },
                },
            })
        end,
    },
}
