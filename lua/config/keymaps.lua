-- Global keymaps.
--
-- The layout here follows docs/migration-plan.md §4 "Keymap contract", which is the
-- shared source of truth for this config and ~/.emacs.d. Do not add a leader mapping
-- here without checking that table first — the whole point is that SPC means the same
-- thing in both editors.
--
-- Plugin-local mappings live with their plugin spec (see lua/plugins/*.lua). The
-- which-key group labels for those prefixes are still declared here, in one place, so
-- there is a single list of what every leader key means.

local map = vim.keymap.set

-- ─── Basics ──────────────────────────────────────────────────────────────────

-- Clear search highlight. Emacs has no equivalent (isearch clears itself), so this
-- follows the Neovim convention rather than the contract.
map("n", "<Esc>", "<cmd>nohlsearch<CR>", { desc = "Clear search highlight" })

-- `jk` leaves insert mode. Mirrors the general-key-dispatch trick in my-evil.el.
map("i", "jk", "<Esc>", { desc = "Exit insert mode" })

-- Save. This used to be <leader>w, which collides with the window prefix in both
-- editors — <leader>wh would save and then wait for a window motion.
map({ "n", "i", "x", "s" }, "<C-s>", "<cmd>write<CR><Esc>", { desc = "Save file" })

-- ─── which-key groups ────────────────────────────────────────────────────────

require("which-key").add({
    { "<leader><tab>", group = "Tabs" },
    { "<leader>a", group = "AI" },
    { "<leader>b", group = "Buffer" },
    { "<leader>c", group = "Code" },
    { "<leader>f", group = "File" },
    { "<leader>g", group = "Git" },
    { "<leader>gh", group = "Hunk" },
    { "<leader>gl", group = "Log" },
    { "<leader>h", group = "Help" },
    { "<leader>p", group = "Project" },
    { "<leader>q", group = "Quit" },
    { "<leader>s", group = "Search" },
    { "<leader>u", group = "UI Toggles" },
    { "<leader>w", group = "Window" },
    { "<leader>x", group = "Diagnostics" },
})

-- ─── Window (SPC w) ──────────────────────────────────────────────────────────
-- Mirrors the `w` block in ~/.emacs.d/lisp/my-evil.el.

map("n", "<leader>wh", "<C-w>h", { desc = "Go to left window" })
map("n", "<leader>wj", "<C-w>j", { desc = "Go to lower window" })
map("n", "<leader>wk", "<C-w>k", { desc = "Go to upper window" })
map("n", "<leader>wl", "<C-w>l", { desc = "Go to right window" })
map("n", "<leader>wp", "<C-w>p", { desc = "Go to previous window" })
map("n", "<leader>ws", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>wv", "<C-w>v", { desc = "Split vertical" })
map("n", "<leader>wc", "<C-w>c", { desc = "Close window" })
map("n", "<leader>wd", "<C-w>c", { desc = "Close window" })
map("n", "<leader>wo", "<C-w>o", { desc = "Close other windows" })
map("n", "<leader>w=", "<C-w>=", { desc = "Balance windows" })

-- Split shortcuts, kept from the previous config.
map("n", "<leader>-", "<C-w>s", { desc = "Split horizontal" })
map("n", "<leader>|", "<C-w>v", { desc = "Split vertical" })

-- Window navigation from a terminal buffer. Normal-mode <C-hjkl> is owned by
-- vim-tmux-navigator (see lua/plugins/tmux.lua), which also crosses into tmux panes
-- the same way my/nav-* does in Emacs.
map("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Go to left window" })
map("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Go to lower window" })
map("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Go to upper window" })
map("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Go to right window" })

-- ─── Tabs (SPC <tab>) ────────────────────────────────────────────────────────
-- Mirrors tabspaces-command-map. Real project-scoped workspaces arrive in phase 4.

map("n", "<leader><tab><tab>", "<cmd>tabnew<CR>", { desc = "New tab" })
map("n", "<leader><tab>d", "<cmd>tabclose<CR>", { desc = "Close tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<CR>", { desc = "Next tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<CR>", { desc = "Previous tab" })
map("n", "<leader><tab>f", "<cmd>tabfirst<CR>", { desc = "First tab" })
map("n", "<leader><tab>l", "<cmd>tablast<CR>", { desc = "Last tab" })

-- ─── Buffer (SPC b) ──────────────────────────────────────────────────────────
-- <leader>bd (delete) is mapped by snacks — see lua/plugins/snacks.lua.

map("n", "<leader>br", "<cmd>edit!<CR>", { desc = "Reload buffer" })
map("n", "<leader>b[", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "<leader>b]", "<cmd>bnext<CR>", { desc = "Next buffer" })
map("n", "[b", "<cmd>bprevious<CR>", { desc = "Previous buffer" })
map("n", "]b", "<cmd>bnext<CR>", { desc = "Next buffer" })

-- ─── Quit (SPC q) ────────────────────────────────────────────────────────────

map("n", "<leader>qq", "<cmd>quit<CR>", { desc = "Quit window" })
map("n", "<leader>qQ", "<cmd>quitall<CR>", { desc = "Quit all" })

-- ─── Diagnostics ─────────────────────────────────────────────────────────────
-- Mirrors flymake-goto-next/prev-error. The <leader>x prefix is reserved for
-- trouble.nvim in phase 5.

map("n", "]e", function()
    vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Next diagnostic" })
map("n", "[e", function()
    vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Previous diagnostic" })

-- ─── Find / search (SPC SPC, SPC f, SPC s, SPC h) ────────────────────────────
--
-- These keys are the contract; the picker behind them is not. Telescope is the
-- implementation today and gets swapped for snacks.picker in phase 3 — when that
-- happens only the right-hand side of these mappings changes, not the keys.

local telescope = require("telescope.builtin")

map("n", "<leader><space>", telescope.find_files, { desc = "Find file in project" })
map("n", "<leader>,", telescope.buffers, { desc = "Switch buffer" })
map("n", "<leader>/", telescope.live_grep, { desc = "Grep project" })

-- File
map("n", "<leader>ff", telescope.find_files, { desc = "Find file" })
map("n", "<leader>fr", telescope.oldfiles, { desc = "Recent files" })
map("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New file" })

-- Search
map("n", "<leader>sg", telescope.live_grep, { desc = "Grep project" })
map("n", "<leader>sb", telescope.current_buffer_fuzzy_find, { desc = "Search buffer" })
map("n", "<leader>sl", telescope.current_buffer_fuzzy_find, { desc = "Search buffer lines" })
map("n", "<leader>si", telescope.lsp_document_symbols, { desc = "Symbols (LSP)" })
map("n", "<leader>sh", telescope.treesitter, { desc = "Outline (treesitter)" })
map("n", "<leader>sm", telescope.marks, { desc = "Marks" })
map("n", "<leader>sf", telescope.find_files, { desc = "Find file" })
map("n", "<leader>sr", telescope.resume, { desc = "Resume last search" })

-- Buffer list also under its own prefix, matching `SPC b b` in Emacs.
map("n", "<leader>bb", telescope.buffers, { desc = "Switch buffer" })

-- Help (SPC h) — mirrors the helpful/describe block in Emacs.
map("n", "<leader>hh", telescope.help_tags, { desc = "Help tags" })
map("n", "<leader>hk", telescope.keymaps, { desc = "Keymaps" })
map("n", "<leader>hc", telescope.commands, { desc = "Commands" })
map("n", "<leader>hm", "<cmd>Telescope man_pages<CR>", { desc = "Man pages" })
map("n", "<leader>ho", telescope.vim_options, { desc = "Vim options" })

-- ─── Project / session (SPC p) ───────────────────────────────────────────────
-- Replaced by proper project detection and persistence.nvim in phase 4.

map("n", "<leader>pd", ":tcd ", { desc = "Tab-local CWD" })
map("n", "<leader>ps", "<cmd>mksession! .session.vim<CR>", { desc = "Save session" })
map("n", "<leader>pl", "<cmd>source .session.vim<CR>", { desc = "Load session" })
