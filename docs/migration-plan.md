# Emacs → Neovim migration — plan and status tracker

> **This document is the single source of truth for the migration.**
> It is written to be resumable: anyone (or any new AI session) can read this file
> alone and know exactly what is done, what is next, and why every decision was made.
> Update it *in the same commit* as the work it describes.

---

## 0. How to resume (read this first)

If you are starting a fresh session:

1. Read §1 (context), §2 (status dashboard), §3 (locked decisions).
2. Find the first phase in §2 whose status is not `DONE`. That is the next work.
3. Open that phase's section in §5. Work through its unchecked `[ ]` items in order.
4. When a phase is finished:
   - tick every `[x]` item,
   - set its row in §2 to `DONE` with the date,
   - add a line to §8 (session log),
   - commit: `docs(migration): phase N complete` together with the config changes.
5. If a decision is made mid-phase, append it to §3 — never leave a decision only in chat.

**Verification before declaring a phase done:** run `nvim --headless "+checkhealth" +qa`
(or `:checkhealth` interactively), confirm no new errors, and use the migrated feature for
one real task.

**Rollback:** every phase is one commit. `git revert <sha>` then `:Lazy restore` returns
Neovim to the previous phase. Emacs is untouched by Neovim phases and always works.

---

## 1. Context snapshot

| | |
|---|---|
| Source config | `~/.emacs.d` — straight.el + use-package + evil + general, ~6.5k lines elisp, 41 `lisp/my-*.el` modules |
| Target config | `~/.config/nvim` — lazy.nvim, hand-rolled, git repo on branch `develop` (main branch: `main`) |
| Neovim version | 0.12.4 |
| Notes/tasks data | `~/Projects/org-gtd/` — stays in Emacs, out of scope |
| Plan created | 2026-08-10 |

**Emacs modules in scope for replacement:** basic, functions, keybindings, evil, yasnippet,
ediff, completion, version-control, project, lsp, treesit, cpp, eshell, jinja, lua, python,
shell, verilog, yaml, spell, appearance, ai, tramp, packages.

**Emacs modules explicitly out of scope (stay in Emacs):** org, org-gtd, org-review,
org-archive-subtree-hierarchical, and their dependencies (denote, ox-hugo, ox-epub,
org-babel, jupyter, wavedrom, plantuml, mermaid, ditaa).

---

## 2. Status dashboard

Status values: `TODO` · `IN PROGRESS` · `DONE` · `SKIPPED`

| # | Phase | Status | Date | Effort | Blocks |
|---|---|---|---|---|---|
| 0 | Baseline and guardrails | TODO | | 30 min | 1 |
| 1 | **Keybinding contract** | TODO | | 1–2 h | everything |
| 2 | Core editing parity | TODO | | 1–2 h | — |
| 3 | Finding and navigation | TODO | | 1–2 h | — |
| 4 | Project and workspace | TODO | | 1 h | 6 |
| 5 | LSP, diagnostics, format, lint | TODO | | 2 h | 6 |
| 6 | Languages (one at a time) | TODO | | 30 min each | — |
| 7 | Git | TODO | | 1 h | — |
| 8 | Terminal, build, run | TODO | | 1 h | — |
| 9 | AI | TODO | | 1 h | — |
| 10 | Appearance and long tail | TODO | | 1 h | — |
| 11 | Cutover | TODO | | 1 h | all |

Phases 2, 3, 7, 8, 9, 10 are mutually independent — reorder by whatever annoys you most.
Phase 1 must come first. Phase 11 must come last.

---

## 3. Locked decisions

Append here; do not silently change an earlier entry.

| # | Date | Decision | Rationale |
|---|---|---|---|
| D1 | 2026-08-10 | **No big bang.** One phase per sitting, one commit per phase, Emacs stays functional throughout. | Learnability and revertibility. |
| D2 | 2026-08-10 | **Neovim keybinding conventions win.** Where the two schemes differ, adopt the popular Neovim binding and patch the Emacs `general` definers to match. | User preference; Emacs-side edits are cheap (one `:general` block each). |
| D3 | 2026-08-10 | **Org is out of scope.** Notes/tasks/agenda/GTD/billing/review stay in Emacs indefinitely. No org bridge in Neovim, no Neorg. | ~1750 lines of custom elisp (GTD client billing, LLM review coach) with no realistic Neovim equivalent. |
| D4 | 2026-08-10 | **Hand-rolled config, not a distro.** Steal from LazyVim's source; do not install LazyVim. | User wants to understand and learn the config. |
| D5 | 2026-08-10 | **snacks.picker, not telescope.** | Both are currently installed; running two pickers is the main source of drift. snacks is already loaded and is the closest match to vertico+consult+embark. |
| D6 | 2026-08-10 | **Emacs endgame is an org-only appliance** behind `emacsclient` + daemon, gated so the full config can be restored with an env var. Not deleted. | Insurance against a regressed phase. |

---

## 4. Keymap contract

**This table is the source of truth for both editors.** Phase 1 implements it.

| Key | Meaning | Emacs today | Neovim today | Action |
|---|---|---|---|---|
| `SPC SPC` | find file in project | `project-find-file` | — | add to nvim |
| `SPC ,` / `SPC b b` | switch buffer | `consult-buffer` | — | add to nvim |
| `SPC /` or `SPC s g` | grep project | `SPC s r` ripgrep | `SPC p g` | align both on `SPC s g` |
| `SPC a` | **AI** | `SPC A` (AI); `SPC a` = applications | `SPC a` = AI ✓ | **swap Emacs**: AI → `SPC a`, applications → `SPC A` |
| `SPC b` | buffer | ✓ | ✓ | — |
| `SPC c` | code / LSP | ✓ | ✓ | — |
| `SPC f` | file | ✓ | — | add to nvim (`ff` find, `fr` recent, `fn` new) |
| `SPC g` | git | ✓ | ✓ | — |
| `SPC h` | help / describe | ✓ | ✗ `nohlsearch` | **nvim**: move `nohlsearch` to `<Esc>`, free `SPC h` |
| `SPC p` | project | `project-prefix-map` | project/session ✓ | — |
| `SPC q` | quit / session | ✓ (group) | ✗ bare `:q` | **nvim**: `SPC q q` quit all, free the prefix |
| `SPC s` | search | ✓ | — | add to nvim |
| `SPC u` | UI toggles | ✗ at `SPC t` | ✓ (snacks) | **Emacs**: move toggles `SPC t` → `SPC u` |
| `SPC w` | **window** | ✓ (`w h/j/k/l/v/s/c/o/=`) | ✗ save file | **nvim**: `SPC w` = window prefix; save → `<C-s>` |
| `SPC <tab>` | tabs / workspaces | `tabspaces-command-map` ✓ | ✗ at `SPC t` | **nvim**: tabs `SPC t` → `SPC <tab>` |
| `SPC x` | diagnostics / quickfix | — | ✗ `:wq` | **nvim**: drop `:wq`, reserve for trouble.nvim |
| `SPC -` / `SPC \|` | split horizontal / vertical | ✓ | ✓ | — |
| `<C-h/j/k/l>` | window + tmux nav | ✓ (`my/nav-*`) | ✓ (vim-tmux-navigator) | — |
| `jk` | insert → normal | ✓ (`general-key-dispatch`) | — | add to nvim |
| `g d` / `g r` / `K` | LSP definition / refs / hover | ✓ (xref/eldoc) | ✓ | — |
| `] e` / `[ e` | next / prev diagnostic | ✓ flymake | — | add to nvim |
| `] h` / `[ h` | next / prev git hunk | — | ✓ gitsigns | add to Emacs (optional) |
| `zg` / `zw` | spell add / remove word | `SPC z g` / `SPC z w` | native | align Emacs onto native keys |

### Three conflicts that need an explicit choice

| Key | Emacs binding | Neovim convention | Decision |
|---|---|---|---|
| `K` | `evil-jump-out-args` | hover docs | **hover on both**; move evil-args jump elsewhere |
| `H` / `L` | `evil-forward-arg` / `evil-backward-arg` | screen top/bottom, or buffer prev/next | **UNDECIDED** — pick in Phase 1; `[b`/`]b` for buffers is the more common modern choice |
| `SPC w` | window prefix | window prefix | **window prefix**; this is the biggest muscle-memory hazard — `SPC w h` currently *saves* in Neovim |

---

## 5. Phases

### Phase 0 — Baseline and guardrails · `TODO`

- [ ] Commit or ignore the untracked tree (`GEMINI.md`, `conductor/`)
- [ ] Run `:checkhealth`, fix anything red
- [ ] Confirm `lazy-lock.json` is tracked and current (`:Lazy sync` then commit)
- [ ] Commit this plan document
- [ ] Confirm Emacs still starts clean (`emacs --batch -l ~/.emacs.d/init.el`)

**Done when:** clean `git status`, clean `:checkhealth`, plan committed.

---

### Phase 1 — Keybinding contract · `TODO`

*Do this first. Everything else builds on it.*

**Neovim side**
- [ ] Rewrite `lua/config/keymaps.lua` around §4; declare *all* which-key groups in one place
- [ ] `<leader>w` → window prefix (`wh/wj/wk/wl/wv/ws/wc/wo/w=`); save moves to `<C-s>`
- [ ] `<leader>h` → help prefix; `nohlsearch` moves to `<Esc>`
- [ ] `<leader>t` (tabs) → `<leader><tab>`
- [ ] `<leader>x` (`:wq`) → removed, reserved for trouble.nvim
- [ ] `<leader>q` → `<leader>qq` quit-all, prefix freed
- [ ] Add `SPC SPC`, `SPC ,`, `SPC f`, `SPC s`, `SPC h` mappings
- [ ] Add `jk` → `<Esc>` in insert mode
- [ ] Add `]e` / `[e` diagnostic navigation
- [ ] Resolve the `H` / `L` decision and record it in §3
- [ ] Delete `lua/plugins/neorg.lua` (D3)
- [ ] Remove the Neorg-only `conceallevel` / `concealcursor` from `lua/config/options.lua`

**Emacs side**
- [ ] Swap `SPC a` (applications) ↔ `SPC A` (AI) in `lisp/my-ai.el` + `lisp/my-packages.el` group table
- [ ] Move toggles `SPC t` → `SPC u`
- [ ] Align grep on `SPC s g` in `lisp/my-completion.el`
- [ ] Rebind `K` to hover/`helpful-at-point`; move `evil-jump-out-args` in `lisp/my-evil.el`
- [ ] Apply the `H` / `L` decision
- [ ] Move spell to native `zg` / `zw` in `lisp/my-spell.el`

**Done when:** pressing `SPC` in both editors shows the same top-level menu.

---

### Phase 2 — Core editing parity · `TODO`

| Emacs | Neovim replacement | Done |
|---|---|---|
| `evil-surround` | `kylechui/nvim-surround` (closer to vim-surround's `ys`/`cs`/`ds`) | [ ] |
| `evil-nerd-commenter` | built-in `gc` / `gcc` — no plugin needed on 0.12 | [ ] |
| `evil-easymotion` + `evil-snipe` | `folke/flash.nvim` (replaces both) | [ ] |
| `evil-mc` | `jake-stewart/multicursor.nvim` — or skip; LSP rename covers most uses | [ ] |
| `evil-args` | `nvim-mini/mini.ai` + treesitter textobjects (`ia`/`aa`) | [ ] |
| `evil-lion` | `nvim-mini/mini.align` (`ga` / `gA`) | [ ] |
| `evil-owl` | which-key register/mark display (already installed) | [ ] |
| `evil-numbers` | built-in `<C-a>` / `<C-x>`, `g<C-a>` in visual | [ ] |
| `undo-fu` + session | `vim.opt.undofile = true` + `mbbill/undotree` | [ ] |
| `super-save` | autocmd on `FocusLost` / `BufLeave` (~5 lines) | [ ] |
| `ws-butler` | `nvim-mini/mini.trailspace` (or conform in Phase 5) | [ ] |
| `yasnippet` + `doom-snippets` | `L3MON4D3/LuaSnip` + `friendly-snippets` | [ ] |
| custom filepath textobject (`vif`/`vaf`) | custom mini.ai spec — port only if missed | [ ] |

- [ ] Add per-filetype indent overrides (`lua`=2, `yaml`=2); current `shiftwidth=4` is global

**Done when:** you can edit for an hour without reaching for an Emacs-only motion.

---

### Phase 3 — Finding and navigation · `TODO`

Target: **snacks.picker** replaces vertico + orderless + marginalia + consult + embark (D5).

| Emacs | Neovim | Done |
|---|---|---|
| `SPC SPC` project-find-file | `picker.files()` (root) | [ ] |
| `SPC b b` consult-buffer | `picker.buffers()` | [ ] |
| `SPC s r` consult-ripgrep | `picker.grep()` | [ ] |
| `SPC s l` consult-line | `picker.lines()` | [ ] |
| `SPC s i` consult-imenu | `picker.lsp_symbols()` | [ ] |
| `SPC s h` consult-outline | `picker.treesitter()` | [ ] |
| `SPC s m` consult-mark | `picker.marks()` | [ ] |
| `recentf` | `picker.recent()` | [ ] |
| `embark-act` (`C-;`) | picker actions / `<C-t>` → quickfix | [ ] |
| `wgrep` + `substitute` (`SPC r`) | `MagicDuck/grug-far.nvim` | [ ] |
| `dired` | `stevearc/oil.nvim` (edit directory as a buffer) | [ ] |

- [ ] Remove telescope + telescope-fzf-native from `lua/plugins/example.lua`
- [ ] Remove the four telescope keymaps from `lua/config/keymaps.lua`

**Done when:** telescope is gone and you stop typing `SPC p f` out of habit.

---

### Phase 4 — Project and workspace · `TODO`

- [ ] Project root detection (snacks picker root detection, or `ahmedkhalf/project.nvim`)
- [ ] `folke/persistence.nvim` for per-directory sessions — replaces the manual `.session.vim` mappings
- [ ] `envrc` → `direnv/direnv.vim` (**needed before Phase 6** for Python venvs and toolchain paths)
- [ ] Map `SPC <tab>` to mirror `tabspaces-command-map` (`.` switch/create, `[` recent, `]` next, `f` first, `l` last)
- [ ] Keep `SPC p d` → `:tcd` (already correct)

**Done when:** opening Neovim in a project restores the layout and picks up `.envrc`.

---

### Phase 5 — LSP, diagnostics, format, lint · `TODO`

You are already on Neovim's native `vim.lsp.config` API — this is gap-filling, not replacement.

- [ ] **Fix treesitter** — `lua/plugins/treesitter.lua` uses the pre-`main` API. The lock file pins `nvim-treesitter` to branch `main`, where `setup()` accepts only `{ install_dir }`; `ensure_installed`, `highlight`, and `indent` are silently ignored. Also `"c++"` is not a parser name (`cpp` is). Migrate to `require("nvim-treesitter").install{...}` + `vim.treesitter.start()` via FileType autocmd
- [ ] Match the parser list to Emacs `treesit-auto` (~15 grammars)
- [ ] `vim.diagnostic` config: signs, virtual text, float
- [ ] `folke/trouble.nvim` on `SPC x`
- [ ] `stevearc/conform.nvim` — replaces `eglot-format`, `python-black`, `verilog-ext` formatters, and `ws-butler`
- [ ] `mfussenegger/nvim-lint` — replaces `pylint` + flymake backends
- [ ] Add the LuaSnip source to `blink.cmp` (after Phase 2)
- [ ] Extend mason `ensure_installed` to cover every Phase 6 language
- [ ] Fix deprecation: `vim.highlight.on_yank` → `vim.hl.on_yank` in `lua/config/autocmds.lua`

**Done when:** format-on-save works, diagnostics render, `SPC c a` works in Python and C++.

---

### Phase 6 — Languages · `TODO`

Do these in the order you actually use them. Each is ~30 min once Phase 5 lands.

| Emacs module | Neovim work | Done |
|---|---|---|
| `my-python.el` (basedpyright, pet, black, pylint, tox) | basedpyright ✓ + ruff + venv via direnv | [ ] |
| `my-cpp.el` (clangd, cmake-ts-mode, eldoc-cmake) | clangd ✓ + `neocmake` + `Civitasv/cmake-tools.nvim` | [ ] |
| `my-verilog.el` (verilog-ts-mode, verilog-ext, slang) | slang-server ✓ — **`verilog-ext` has no Neovim equivalent**; audit which features (hierarchy, templates, beautify) you rely on and decide per feature | [ ] |
| `my-vhdl.el` (vhdl-ext, vhdl-ts-mode) | `rust_hdl` / `vhdl_ls` — same caveat | [ ] |
| `my-go.el` (234 lines) | `gopls` + `ray-x/go.nvim` | [ ] |
| `my-rust.el` (rustic) | `mrcjkb/rustaceanvim` | [ ] |
| `my-lua.el` | `lua_ls` + `folke/lazydev.nvim` (essential for editing this config) | [ ] |
| `my-yaml.el`, `toml-mode` | `yamlls`, `taplo` | [ ] |
| `my-jinja.el` | treesitter `jinja2` + `djlint` | [ ] |
| `my-shell.el`, `sh-script` | `bashls` + `shellcheck` via nvim-lint | [ ] |
| `markdown-mode` | `render-markdown.nvim` + `marksman` | [ ] |
| `graphviz-dot`, `plantuml`, `mermaid` modes | treesitter + external render commands — **preview is a downgrade** | [ ] |

**Done when:** every language you touched in the last month has LSP + format + lint.

---

### Phase 7 — Git · `TODO`

Mostly done already.

- [ ] Spend a session learning neogit (installed ✓) — it is ~80% of magit
- [ ] `sindrets/diffview.nvim` — replaces `magit-diff` and `ediff`, the biggest neogit gap
- [ ] `git-timemachine` → `:DiffviewFileHistory %`
- [ ] Align the `SPC g` submap with Emacs (`gg` status, `gb` branch, `gl l` log, `gl b` file log, `gB` blame)
- [x] `gitsigns` — installed
- [x] `gptel-magit` → `git-commit-gen.nvim` — installed and working

**Done when:** a full stage → commit → push cycle without opening magit.

---

### Phase 8 — Terminal, build, run · `TODO`

- [ ] `eshell` / `vterm` → snacks `terminal` (`<C-/>` already mapped) + tmux
- [ ] `compile` / `recompile` (`SPC c c` / `SPC c C`) → `:make` + `makeprg`/`errorformat`, or `stevearc/overseer.nvim` for a magit-style task runner. Keep the same keys
- [ ] `detached.el` → tmux detached panes, no plugin
- [ ] `proced` → drop, use a terminal
- [x] tmux navigation — `vim-tmux-navigator` already mirrors the Emacs `my/nav-*` functions

**Done when:** your build/test loop runs from Neovim into quickfix.

---

### Phase 9 — AI · `TODO`

Emacs surface: `gptel`, `copilot`, `claude-code-ide`, `codex-cli`, `gemini-cli-ide`,
`gh-copilot-chat`, `emacs-mcp`.

- [ ] `claude-code-ide` → `coder/claudecode.nvim`
- [ ] `copilot` → `zbirenbaum/copilot.lua`
- [ ] `gptel` → `olimorris/codecompanion.nvim` (closest to gptel's buffer-based chat) — or skip if claudecode covers you
- [ ] Consolidate everything under `SPC a`; today `ai.lua` and `git-commit-gen.lua` both write into `SPC a` / `SPC g` with no shared group table
- [x] `gemini-cli` → `<leader>ag` terminal launcher (keep or fold into codecompanion)

**Done when:** one AI entry point, no duplicate terminal launchers.

---

### Phase 10 — Appearance and long tail · `TODO`

- [ ] `doom-modeline` → `nvim-lualine/lualine.nvim`
- [ ] `modus-themes` → currently tokyonight; add `miikanissi/modus-themes.nvim` for identical colours in both editors
- [ ] `nerd-icons` → `nvim-web-devicons` or `mini.icons`
- [ ] `spell-fu` → built-in `spell` (already on for text filetypes) + native `zg`/`zw`
- [ ] `helpful` → built-in `:help` behind the `SPC h` submap
- [ ] Split `lua/plugins/example.lua` into `which-key.lua` / `picker.lua`
- [x] `dashboard`, `indent guides`, `notifier` — snacks, already enabled
- [ ] Not needed: `restart-emacs`, `no-littering`, `benchmark` (use `:Lazy profile`)

**Done when:** Neovim looks like a finished editor, not a work in progress.

---

### Phase 11 — Cutover · `TODO`

- [ ] Shrink `~/.emacs.d/init.el` to an org-only profile: `my-core`, `my-packages`, `my-basic`, `my-evil`, `my-org*`, `my-spell`, `my-appearance`
- [ ] Gate the dropped modules behind an `EMACS_FULL=1` env var so a week of the old setup is one variable away (D6)
- [ ] Run Emacs as a daemon; open it only via `emacsclient` for org
- [ ] Measure: Emacs startup time before/after
- [ ] Final pass over §6 — confirm the "still needs Emacs" list is accurate

**Done when:** Emacs is opened only for org, and nothing else.

---

## 6. Accepted losses

No good Neovim equivalent; these keep you in Emacs or in an external tool.

| Feature | Status | Partial mitigation |
|---|---|---|
| org-mode (agenda, capture, refile, clocking, GTD, billing, review) | stays in Emacs (D3) | — |
| org-babel + jupyter | stays in Emacs | — |
| org exports: `ox-hugo`, `ox-epub`, LaTeX/Chinese PDF | stays in Emacs | — |
| `denote` note-taking | stays in Emacs | — |
| `pdf-tools` | lost | external viewer |
| `tramp` remote editing | lost | `oil.nvim` SSH, `distant.nvim` |
| `.org.gpg` encrypted files | lost | `vim-gnupg` for non-org files |
| `wavedrom` / `ditaa` / `plantuml` inline rendering | lost | external CLI + image viewer |
| `google-translate` | lost | external tool |
| `verilog-ext` / `vhdl-ext` advanced features | partial | audit in Phase 6 |
| `calc` | lost | external tool |

---

## 7. Known issues in the current Neovim config

Discovered 2026-08-10 while surveying. Each is assigned to a phase.

| # | Issue | Phase | Done |
|---|---|---|---|
| I1 | `lua/plugins/treesitter.lua` uses the pre-`main` API against a `main`-pinned plugin — `ensure_installed`/`highlight`/`indent` are silently ignored; `"c++"` is not a valid parser name | 5 | [ ] |
| I2 | `<leader>w` = save collides with the window prefix in both schemes | 1 | [ ] |
| I3 | `<leader>h` = `nohlsearch` collides with the help prefix | 1 | [ ] |
| I4 | `<leader>t` = tabs collides with the Emacs toggle prefix | 1 | [ ] |
| I5 | which-key groups in `keymaps.lua` are stale — `<leader>w` labelled "File", `<leader>t` "Tabs"; several plugin-spec groups undeclared | 1 | [ ] |
| I6 | Telescope and snacks.picker both installed | 3 | [ ] |
| I7 | `lua/plugins/example.lua` holds unrelated specs; should be split | 10 | [ ] |
| I8 | Neorg configured against `~/Projects/org-gtd/neorg/notes`, which is empty | 1 | [ ] |
| I9 | `vim.highlight.on_yank` deprecated on 0.12 → `vim.hl.on_yank` | 5 | [ ] |
| I10 | `vim.loop` in `lua/config/lazy.lua` deprecated → `vim.uv` | 5 | [ ] |

---

## 8. Session log

One line per working session. Newest last.

| Date | Phase | What happened |
|---|---|---|
| 2026-08-10 | — | Surveyed both configs; wrote this plan. Decisions D1–D6 locked. |
