vim.keymap.set("n", "<leader>w", ":w<CR>", { desc = "Save file" })
vim.keymap.set("n", "<leader>q", ":q<CR>", { desc = "Quit" })
vim.keymap.set("n", "<leader>x", ":wq<CR>", { desc = "Save and Quit" })
vim.keymap.set("n", "<leader>h", ":nohlsearch<CR>", { desc = "Clear Search" })
vim.keymap.set("n", "<leader>s", ":split<CR>", { desc = "Horizontal Split" })
vim.keymap.set("n", "<leader>v", ":vsplit<CR>", { desc = "Vertical Split" })

-- Window Navigation
vim.keymap.set("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window" })
vim.keymap.set("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window" })
vim.keymap.set("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window" })
vim.keymap.set("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window" })

-- Terminal Navigation
vim.keymap.set("t", "<C-h>", [[<C-\><C-n><C-w>h]], { desc = "Go to Left Window" })
vim.keymap.set("t", "<C-j>", [[<C-\><C-n><C-w>j]], { desc = "Go to Lower Window" })
vim.keymap.set("t", "<C-k>", [[<C-\><C-n><C-w>k]], { desc = "Go to Upper Window" })
vim.keymap.set("t", "<C-l>", [[<C-\><C-n><C-w>l]], { desc = "Go to Right Window" })
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

-- AI
vim.keymap.set("n", "<leader>ag", function()
    vim.cmd("botright vsplit")
    local width = math.floor(vim.o.columns / 3)
    vim.cmd("vertical resize " .. width)
    vim.cmd("terminal gemini")
end, { desc = "Open Gemini CLI" })
