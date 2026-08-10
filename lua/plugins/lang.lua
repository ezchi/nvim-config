-- Per-language support beyond the LSP configs in lua/config/lsp.lua.
--
-- Scope was set by counting what is actually in ~/Projects (see migration-plan
-- phase 6). SystemVerilog/Verilog dominates at ~2200 files, then markdown, C/C++,
-- Python and shell. Go has zero files and no toolchain, Rust and VHDL one file
-- each -- none of those are configured.
--
-- There is no linter plugin here. Every language in use gets its diagnostics
-- from a language server, and the two standalone linters on this machine are
-- already covered:
--
--   * SystemVerilog -- slang-server IS slang. Running `slang -Weverything`
--     separately reports the same warnings a second time; measured on a real
--     file, 16 LSP diagnostics vs 17 CLI, and the "differences" were the same
--     messages with the flag name appended. It also sees one file in isolation
--     rather than the indexed workspace.
--   * sh/bash -- bash-language-server runs shellcheck itself and reports the
--     results, verified.
--
-- See D14. If you ever want the `[-Wflag-name]` suffix that the CLI prints and
-- the server omits, that is the one reason to add nvim-lint back.
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
}
