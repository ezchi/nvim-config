vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>br", ":edit!<CR>", { desc = "Reload buffer" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":wq<CR>", { desc = "Save and Quit" })

vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear Search" })

vim.keymap.set("n", "<leader>s", ":split<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical Split" })

-- Window Navigation
-- Terminal Navigation
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Go to Left Window" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Go to Lower Window" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Go to Upper Window" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Go to Right Window" })

vim.keymap.set("n", "<leader>un", ":set number!<CR>", { desc = "Toggle number" })
vim.keymap.set("n", "<leader>ur", ":set relativenumber!<CR>", { desc = "Toggle relative number" })

-- Tab Navigation
vim.keymap.set("n", "<leader>tn", ":tabnew<CR>", { desc = "New Tab" })
vim.keymap.set("n", "<leader>tc", ":tabclose<CR>", { desc = "Close Tab" })

local wk = require("which-key")

wk.add({
    { "<leader>b", group = "Buffer" },
    { "<leader>w", group = "File" },
    { "<leader>t", group = "Tabs" },
    { "<leader>u", group = "UI Toggles" },
    { "<leader>p", group = "Project/Session" },
    { "<leader>a", group = "AI" },
})

-- Session and Project Management
vim.keymap.set("n", "<leader>pd", ":tcd ", { desc = "Tab-local CWD" })
vim.keymap.set("n", "<leader>ps", ":mksession! .session.vim<CR>", { desc = "Save Session" })
vim.keymap.set("n", "<leader>pl", ":source .session.vim<CR>", { desc = "Load Session" })

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>pf', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>pg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>pb', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>ph', builtin.help_tags, { desc = 'Telescope help tags' })
