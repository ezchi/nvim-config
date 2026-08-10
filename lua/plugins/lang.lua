-- Per-language support beyond the LSP configs in lua/config/lsp.lua.
--
-- Scope was set by counting what is actually in ~/Projects (see migration-plan
-- phase 6). SystemVerilog/Verilog dominates at ~2200 files, then markdown, C/C++,
-- Python and shell. Go has zero files and no toolchain, Rust and VHDL one file
-- each -- none of those are configured.
return {
    -- Neovim API types for lua_ls. Only worth having because this config is
    -- itself the Lua you edit; it makes `vim.*` complete and stops the
    -- undefined-global warnings.
    {
        "folke/lazydev.nvim",
        ft = "lua",
        opts = {
            library = {
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            },
        },
    },

    -- Linters that have no language server. Everything else gets its
    -- diagnostics from LSP, which is why this is a short list -- see D12.
    {
        "mfussenegger/nvim-lint",
        event = { "BufReadPost", "BufWritePost" },
        config = function()
            local lint = require("lint")

            -- nvim-lint ships slang, verilator and ghdl, but no verible, so
            -- define it. verible is the style checker -- naming, formatting
            -- conventions -- which is exactly what slang-server does NOT do,
            -- so the two do not overlap.
            --
            -- Output: `file.sv:1:8-15: message [Style: file-names] [rule-name]`
            lint.linters.verible = {
                cmd = "verible-verilog-lint",
                stdin = false,
                args = {},
                append_fname = true,
                stream = "stderr", -- verible writes diagnostics to stderr, not stdout
                ignore_exitcode = true, -- exits 1 whenever it finds anything
                parser = require("lint.parser").from_pattern(
                    "([^:]+):(%d+):(%d+)[%-%d]*:%s*(.+)",
                    { "file", "lnum", "col", "message" },
                    nil,
                    { source = "verible", severity = vim.diagnostic.severity.WARN }
                ),
            }

            lint.linters_by_ft = {
                verilog = { "verible" },
                systemverilog = { "verible" },
                sh = { "shellcheck" },
                bash = { "shellcheck" },
            }

            -- Lint on read and write rather than on every keystroke: verible
            -- shells out per file and this is a 2000-file codebase.
            vim.api.nvim_create_autocmd({ "BufReadPost", "BufWritePost", "InsertLeave" }, {
                group = vim.api.nvim_create_augroup("nvim_lint", { clear = true }),
                callback = function()
                    lint.try_lint(nil, { ignore_errors = true })
                end,
            })
        end,
    },
}
