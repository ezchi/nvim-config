# Neovim Configuration (nvim-config)

A modular and modern Neovim configuration tailored for software engineering, featuring deep AI integration and specialized support for SystemVerilog, C++, and Python.

## Project Overview

- **Core:** Built with Neovim 0.10+ using Lua for configuration.
- **Plugin Manager:** [lazy.nvim](https://github.com/folke/lazy.nvim) handles all plugin loading and management.
- **Architecture:** 
    - `init.lua`: The entry point that loads core modules and plugins.
    - `lua/config/`: Contains core Neovim settings:
        - `options.lua`: Global and local Neovim options.
        - `keymaps.lua`: Global keybindings and `which-key` group definitions.
        - `autocmds.lua`: Event-based automation.
        - `lsp.lua`: Built-in LSP client configuration and server enablement.
    - `lua/plugins/`: Individual plugin specifications, categorized by functionality (AI, Git, LSP, etc.).
    - `conductor/`: Project-level planning and implementation tracking (e.g., `cliproxy-git-commit-gen.md`).

## Key Technologies & Tools

- **LSP & Tooling:**
    - **Mason:** Manages external LSP servers, linters, and debuggers.
    - **Servers:** `basedpyright` (Python), `clangd` (C/C++), `slang_server` (SystemVerilog).
    - **Completion:** `blink.cmp` for fast, asynchronous completion.
- **AI Integrations:**
    - **Gemini CLI:** Launched via `<leader>ag` in a terminal split.
    - **AI Git Commit Generation:** Uses custom plugins `cliproxyapi.nvim` and `git-commit-gen.nvim` to automatically generate Conventional Commits.
- **Navigation & UI:**
    - **Telescope:** Fuzzy finding for files, grep, and buffers.
    - **Snacks.lua:** Integrated UI utilities and snacks.
    - **Which-key:** Interactive keybinding documentation.

## Running and Maintenance

- **Launch:** Run `nvim` from the terminal.
- **Update Plugins:** Open Neovim and run `:Lazy update`.
- **LSP Management:** Run `:Mason` to install or update language servers.
- **Health Check:** Run `:checkhealth` to verify the configuration and dependencies (especially `cliproxyapi`).

## Development Conventions

- **Modular Plugins:** New plugins should be added as separate files in `lua/plugins/` to keep the configuration organized.
- **Keybindings:** Global keybindings go in `lua/config/keymaps.lua`. Use `which-key` groups to keep them discoverable.
- **LSP Configuration:** Prefer standard `vim.lsp.config` for server setup in `lua/config/lsp.lua`.
- **Planning:** Use the `conductor/` directory for drafting implementation plans for significant changes or new plugin developments.

## Workflow Tips

- `<leader>ag`: Launch Gemini CLI for AI assistance.
- `<leader>gm`: Generate an AI-powered git commit message (requires `cliproxyapi`).
- `<leader>pf`: Find files using Telescope.
- `<leader>pg`: Live grep through the project.
- `<leader>ps`/`<leader>pl`: Save and load local sessions (`.session.vim`).
