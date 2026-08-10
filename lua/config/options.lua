vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.expandtab = true
vim.opt.shiftwidth = 4
vim.opt.tabstop = 4

vim.opt.cursorline = true

-- Enable true color
vim.opt.termguicolors = true

-- Note: conceallevel/concealcursor used to be set globally here for Neorg. Neorg is
-- gone (org lives in Emacs), and a global conceallevel hides quotes in JSON and
-- markup in markdown. Plugins that want it set it per-filetype instead.

-- Disable the remote-plugin providers we don't use. Nothing in this config needs
-- them, and leaving them on makes :checkhealth report four warnings that drown out
-- real problems. Re-enable python3 here if you ever install a pynvim-based plugin.
vim.g.loaded_node_provider = 0
vim.g.loaded_perl_provider = 0
vim.g.loaded_ruby_provider = 0
vim.g.loaded_python3_provider = 0
