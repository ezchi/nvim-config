-- Editing parity with the evil-* plugin stack in ~/.emacs.d/lisp/my-evil.el.
-- See docs/migration-plan.md phase 2 for the full mapping table.
--
-- Not ported, deliberately:
--   * evil-nerd-commenter -> `gc` / `gcc` are built in since Neovim 0.10
--   * evil-numbers        -> `<C-a>` / `<C-x>` are built in
--   * evil-owl            -> which-key already previews registers and marks
--   * evil-mc             -> see follow-up F2; `gr` is now the builtin LSP prefix
--   * undo-fu-session     -> 'undofile' in lua/config/options.lua covers persistence;
--                            a tree visualiser is follow-up F4
--   * ws-butler           -> conform.nvim in phase 5 handles trailing whitespace as
--                            part of per-language formatting; follow-up F6
return {
    -- evil-surround. ys/cs/ds, the vim-surround keys evil-surround emulates.
    {
        "kylechui/nvim-surround",
        version = "*",
        event = "VeryLazy",
        opts = {},
    },

    -- evil-easymotion + evil-snipe. Both take `s` in Emacs; flash does the same,
    -- and also enhances f/t/F/T with labels the way evil-snipe's char-fold does.
    {
        "folke/flash.nvim",
        event = "VeryLazy",
        opts = {},
        keys = {
            { "s", mode = { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
            { "S", mode = { "n", "x", "o" }, function() require("flash").treesitter() end, desc = "Flash Treesitter" },
            { "r", mode = "o", function() require("flash").remote() end, desc = "Remote Flash" },
            { "R", mode = { "o", "x" }, function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        },
    },

    -- evil-args, plus the custom quoted text objects defined in my-evil.el.
    -- mini.ai gives `ia`/`aa` for arguments out of the box, and treats any other
    -- punctuation as a self-delimiting pair -- so `vi|`, `vi/`, `vi*`, `vi=` and
    -- `vi$` all work without the define-and-bind-quoted-text-object macro.
    {
        "nvim-mini/mini.ai",
        event = "VeryLazy",
        opts = {},
    },

    -- evil-lion. Note the keys differ from Emacs' default gl/gL; ga/gA is the
    -- Neovim convention, and my-evil.el has been changed to match.
    {
        "nvim-mini/mini.align",
        event = "VeryLazy",
        opts = {},
    },

}
