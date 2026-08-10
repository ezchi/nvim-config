-- nvim-treesitter, `main` branch.
--
-- The `main` branch is a rewrite: setup() takes only { install_dir }. The old
-- `ensure_installed` / `highlight` / `indent` tables from the `master` branch are
-- accepted and then silently ignored, which is why this config previously had zero
-- parsers installed and every language was falling back to regex highlighting.
--
-- On `main` you drive it yourself:
--   * install parsers with require("nvim-treesitter").install(...)
--   * start highlighting per buffer with vim.treesitter.start()
--   * opt into treesitter indent by setting indentexpr
return {
    {
        "nvim-treesitter/nvim-treesitter",
        branch = "main",
        lazy = false,
        build = ":TSUpdate",
        config = function()
            local ts = require("nvim-treesitter")

            ts.setup({})

            -- Parser names are nvim-treesitter's, not the filetype's. Two that bite:
            --   * there is no `verilog` parser on main — SystemVerilog covers both,
            --     which is the same call ~/.emacs.d/lisp/my-treesit.el makes.
            --   * `jinja`, not `jinja2`.
            --   * there is no `jsonc` parser — the `json` one handles both.
            local ensure_installed = {
                -- config + docs
                "lua",
                "luadoc",
                "vim",
                "vimdoc",
                "query",
                "markdown",
                "markdown_inline",
                -- languages in daily use
                "python",
                "c",
                "cpp",
                "cmake",
                "systemverilog",
                "vhdl",
                "go",
                "rust",
                "bash",
                -- data + config formats
                "json",
                "yaml",
                "toml",
                "jinja",
                -- git
                "gitcommit",
                "git_rebase",
                "gitignore",
                "diff",
                -- required by snacks.picker
                "regex",
            }

            -- install() is async and re-downloads whatever it is given, so only ask
            -- for what is actually missing. Otherwise every startup rebuilds parsers.
            local installed = ts.get_installed("parsers")
            local missing = vim.tbl_filter(function(parser)
                return not vim.tbl_contains(installed, parser)
            end, ensure_installed)

            if #missing > 0 then
                ts.install(missing)
            end

            -- Highlighting and indent are per-buffer on main. pcall because not every
            -- filetype has a parser, and vim.treesitter.start() throws when it doesn't.
            vim.api.nvim_create_autocmd("FileType", {
                group = vim.api.nvim_create_augroup("treesitter_start", { clear = true }),
                desc = "Enable treesitter highlighting and indent where a parser exists",
                callback = function(event)
                    if not pcall(vim.treesitter.start, event.buf) then
                        return
                    end
                    vim.bo[event.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end,
            })
        end,
    },
}
