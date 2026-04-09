vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":wq<CR>", { desc = "Save and Quit" })
-- vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear Search" })
vim.keymap.set("n", "<leader>s", ":split<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical Split" })
vim.keymap.set("n", "<leader>tn", ":set number!<CR>", { desc = "Toggle number" })
vim.keymap.set("n", "<leader>tr", ":set relativenumber!<CR>", { desc = "Toggle relative number" })

local wk = require("which-key")

wk.add({
    { "<leader>w", group = "File" },
    { "<leader>t", group = "Toggle" },
    { "<leader>f", group = "Find" },
})

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })

-- gitsigns
vim.keymap.set("n", "<leader>hp", "<cmd>Gitsigns preview_hunk<CR>", { desc = "Preview hunk" })
vim.keymap.set("n", "<leader>hb", "<cmd>Gitsigns blame_line<CR>", { desc = "Blame line" })
vim.keymap.set("n", "<leader>hs", "<cmd>Gitsigns stage_hunk<CR>", { desc = "Stage hunk" })
vim.keymap.set("n", "<leader>hr", "<cmd>Gitsigns reset_hunk<CR>", { desc = "Reset hunk" })
vim.keymap.set("n", "]h", "<cmd>Gitsigns next_hunk<CR>", { desc = "Next hunk" })
vim.keymap.set("n", "[h", "<cmd>Gitsigns prev_hunk<CR>", { desc = "Previous hunk" })
