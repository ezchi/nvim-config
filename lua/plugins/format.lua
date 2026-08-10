-- Formatting, replacing eglot-format, python-black and ws-butler.
--
-- Only formatters that are actually installed are listed. conform skips a
-- formatter whose binary is missing, so a missing one degrades to the next
-- entry rather than erroring -- but listing aspirational tools hides the fact
-- that a filetype has no formatter at all, so don't.
--
-- `trim_whitespace` is conform's built-in and is what closes follow-up F6:
-- ws-butler's job, done per-language as part of formatting rather than by a
-- separate whole-buffer plugin.
return {
    {
        "stevearc/conform.nvim",
        event = "BufWritePre",
        cmd = "ConformInfo",
        keys = {
            {
                "<leader>cf",
                function()
                    require("conform").format({ async = true, lsp_format = "fallback" })
                end,
                mode = { "n", "x" },
                desc = "Format buffer",
            },
        },
        opts = {
            formatters_by_ft = {
                python = { "ruff_organize_imports", "ruff_format" },
                c = { "clang-format" },
                cpp = { "clang-format" },
                systemverilog = { "verible_verilog_format" },
                verilog = { "verible_verilog_format" },
                lua = { "stylua" },
                sh = { "shfmt" },
                bash = { "shfmt" },
                toml = { "taplo" },
                -- Everything else at least gets trailing whitespace removed.
                ["_"] = { "trim_whitespace" },
            },

            -- Off by default, toggled with SPC u f. Format-on-save rewrites
            -- other people's files on a stray :w, which is exactly the noisy
            -- diff problem that got mini.trailspace removed.
            format_on_save = function(bufnr)
                if not vim.g.autoformat and not vim.b[bufnr].autoformat then
                    return nil
                end
                return { timeout_ms = 1000, lsp_format = "fallback" }
            end,
        },
    },
}
