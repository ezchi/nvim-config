# Implementation Plan: Git Commit Generation Plugins

## Objective
Extract the existing git commit message generation logic from `ai.lua` into two separate, maintainable Neovim plugins hosted on GitHub using the `gh` CLI:
1. `cliproxyapi.nvim`: A foundation plugin to manage the `cliproxyapi` server lifecycle, perform health checks, and provide an API wrapper via `plenary.curl`.
2. `git-commit-gen.nvim`: A feature plugin that depends on `cliproxyapi.nvim` to automatically generate commit messages using the provided API and models.

## Key Files & Context
- GitHub repositories: `ezchi/cliproxyapi.nvim` and `ezchi/git-commit-gen.nvim`
- Local development paths: `~/Projects/cliproxyapi.nvim/` and `~/Projects/git-commit-gen.nvim/`
- `~/.config/nvim/lua/plugins/ai.lua` (To be updated)
- `~/.config/nvim/lua/plugins/git-commit-gen.lua` (New lazy configuration to load from GitHub)

## Implementation Steps

### Phase 1: Create `cliproxyapi.nvim`
1. Initialize the directory structure in `~/Projects/cliproxyapi.nvim`.
2. Use `gh repo create ezchi/cliproxyapi.nvim --public --source=. --remote=origin` to create and link the public GitHub repository.
3. Implement `lua/cliproxyapi/init.lua`:
   - Store default configuration (`port = 8317`, `host = "localhost"`, `api_key = "any-value"`, default model lists).
   - Add logic to verify if `cliproxyapi` is listening on the configured port (`lsof -i:<port>`).
   - Add an autostart mechanism: If not listening, start the binary in the background using `vim.fn.jobstart`.
   - Expose `completions()` and `models()` functions wrapped with `plenary.curl`.
4. Implement `lua/cliproxyapi/health.lua`:
   - Create a `:checkhealth cliproxyapi` check.
   - Verify `cliproxyapi` binary exists (`vim.fn.executable`).
   - Verify server is reachable.
   - Fetch the list of available models and validate the configuration.
5. Commit and push the initial version to GitHub.

### Phase 2: Create `git-commit-gen.nvim`
1. Initialize the directory structure in `~/Projects/git-commit-gen.nvim`.
2. Use `gh repo create ezchi/git-commit-gen.nvim --public --source=. --remote=origin` to create and link the public GitHub repository.
3. Implement `lua/git-commit-gen/init.lua`:
   - Store default configuration (model name, prompt overrides).
   - Register the `:GitCommitGen` command.
   - Register an `autocmd` for `FileType gitcommit` to auto-trigger the generation.
4. Implement `lua/git-commit-gen/generator.lua`:
   - Collect inputs: `git branch`, `git status --short`, `git diff --staged`.
   - Build the Conventional Commits prompt.
   - Invoke `require('cliproxyapi').completions(...)` using the configured model.
   - Process the response line by line, trim markdown blocks, and insert it into the current buffer.
5. Commit and push the initial version to GitHub.

### Phase 3: Neovim Configuration Update
1. Update `~/.config/nvim/lua/plugins/ai.lua` to remove the hardcoded `gemini-ai` configuration block.
2. Create `~/.config/nvim/lua/plugins/git-commit-gen.lua` with `lazy.nvim` specs to load the two plugins directly from GitHub:
   ```lua
   return {
     {
       "ezchi/cliproxyapi.nvim",
       dependencies = { "nvim-lua/plenary.nvim" },
       opts = {},
     },
     {
       "ezchi/git-commit-gen.nvim",
       dependencies = { "ezchi/cliproxyapi.nvim" },
       opts = {},
     }
   }
   ```
3. Use the local directories (`~/Projects/...`) for testing during development using Lazy's `dev = true` or standard `dir = ...` overrides if necessary, but the final committed config will point to the GitHub repos.

## Verification & Testing
1. Reload Neovim and run `:checkhealth cliproxyapi` to ensure the server starts automatically and the models are fetched.
2. Ensure `:GitCommitGen` successfully queries the local API and outputs a formatted commit message.
3. Verify opening a `gitcommit` buffer automatically populates the text.