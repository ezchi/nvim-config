local capabilities = require("blink.cmp").get_lsp_capabilities()

vim.lsp.config("basedpyright", {
    capabilities = capabilities,
})

vim.lsp.config("slang_server", {
    cmd = { "slang-server" },
    filetypes = { "systemverilog", "verilog" },
    root_markers = { ".git", "slang.json", "compile_commands.json" },
    capabilities = capabilities,
})

vim.lsp.config("clangd", {
    capabilities = capabilities,
})

-- ruff runs alongside basedpyright: basedpyright does types and completion,
-- ruff does lint and import sorting. Together they replace pylint + flymake,
-- which is why nvim-lint is not needed for Python.
vim.lsp.config("ruff", {
    cmd = { "ruff", "server" },
    filetypes = { "python" },
    root_markers = { "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" },
    capabilities = capabilities,
})

vim.lsp.config("lua_ls", {
    capabilities = capabilities,
    settings = {
        Lua = {
            -- lazydev supplies the Neovim API types; telling lua_ls the
            -- runtime version and globals avoids the usual `vim` warnings.
            runtime = { version = "LuaJIT" },
            workspace = { checkThirdParty = false },
            diagnostics = { globals = { "vim", "Snacks" } },
        },
    },
})

vim.lsp.config("bashls", { capabilities = capabilities })
vim.lsp.config("marksman", { capabilities = capabilities })
vim.lsp.config("yamlls", { capabilities = capabilities })

vim.lsp.config("taplo", {
    cmd = { "taplo", "lsp", "stdio" },
    filetypes = { "toml" },
    root_markers = { ".taplo.toml", "taplo.toml", ".git" },
    capabilities = capabilities,
})

vim.lsp.enable({
    "basedpyright",
    "ruff",
    "slang_server",
    "clangd",
    "lua_ls",
    "bashls",
    "marksman",
    "yamlls",
    "taplo",
})

-- Diagnostics presentation, replacing the flymake setup in my-lsp.el.
-- ]e / [e navigate; SPC x x lists. See lua/config/keymaps.lua.
vim.diagnostic.config({
    -- Sort so the worst problem on a line is the one shown inline.
    severity_sort = true,
    underline = true,
    update_in_insert = false,
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "󰅚 ",
            [vim.diagnostic.severity.WARN] = "󰀪 ",
            [vim.diagnostic.severity.INFO] = "󰋽 ",
            [vim.diagnostic.severity.HINT] = "󰌶 ",
        },
    },
    -- Inline text for warnings and above only. Hints and info are usually
    -- noise at the end of a line; they still show in the sign column,
    -- on hover, and in the SPC x x list.
    virtual_text = {
        severity = { min = vim.diagnostic.severity.WARN },
        spacing = 2,
        source = "if_many",
    },
    float = {
        border = "rounded",
        source = "if_many",
        header = "",
    },
})
