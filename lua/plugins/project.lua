-- Project and workspace handling, replacing tabspaces + project.el.
--
-- Root detection is NOT a plugin: vim.fs.root() with a marker list in
-- lua/config/keymaps.lua does what project.el does (D11).
--
-- direnv is NOT a plugin either: the zsh hook in ~/.zshrc already applies .envrc
-- before nvim starts, so a nvim launched inside a project inherits the right
-- venv and PATH, and so do the LSP servers it spawns. Only `:tcd` to another
-- project inside a running nvim would go stale -- follow-up F8.
return {
    -- Session persistence per directory. Snacks' project picker looks for this
    -- plugin by name: SPC p p chdirs into a project and then calls
    -- require("persistence").load() to restore that project's windows.
    {
        "folke/persistence.nvim",
        event = "BufReadPre",
        opts = {},
    },
}
