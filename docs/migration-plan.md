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

**Verification before declaring a phase done:** run `:checkhealth`, confirm no new errors,
and use the migrated feature for one real task.

> **Caveat — do not trust headless `:checkhealth` for snacks.nvim.** The `input`,
> `dashboard`, `scroll`, `scope`, and `picker` modules are wired on the `UIEnter` event,
> which never fires under `nvim --headless`. They will report `setup did not run` and
> `vim.ui.input is not set to Snacks.input` as *errors* that do not exist in a real UI.
> To check them headlessly, fire the event first:
> ```sh
> nvim --headless -c 'lua vim.defer_fn(function() vim.cmd("doautocmd UIEnter") end, 500)' ...
> ```
> Verified 2026-08-10 against `snacks.nvim/lua/snacks/init.lua`.

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
| 0 | Baseline and guardrails | **DONE** | 2026-08-10 | 30 min | 1 |
| 1 | **Keybinding contract** | **DONE** | 2026-08-10 | 1–2 h | everything |
| 1b | Treesitter parsers | **DONE** | 2026-08-10 | 20 min | 3, 5 |
| 2 | Core editing parity | **DONE** | 2026-08-10 | 1–2 h | — |
| 3 | Finding and navigation | **DONE** | 2026-08-10 | 1–2 h | — |
| 4 | Project and workspace | **DONE** | 2026-08-10 | 1 h | 6 |
| 5 | LSP, diagnostics, format, lint | **DONE** | 2026-08-11 | 2 h | 6 |
| 6 | Languages (one at a time) | **DONE** | 2026-08-11 | 30 min each | — |
| 7 | Git | **DONE** | 2026-08-11 | 1 h | — |
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
| D14 | 2026-08-11 | **No linter plugin.** SystemVerilog linting is `slang-server`; shell linting is `bash-language-server`'s built-in shellcheck. `nvim-lint` installed in Phase 6 and removed the same day. | Enze chose slang over verible, and slang-server *is* slang — measured, the CLI reports the same findings the server already does, so both together double every warning. bashls likewise already runs shellcheck. Re-add nvim-lint only for the `[-Wflag-name]` suffix the CLI prints and the server omits. |
| D13 | 2026-08-11 | **`mason-lspconfig` `automatic_enable = false`.** Language servers are enabled explicitly in `lua/config/lsp.lua`. | Left on, it enables every mason package that happens to have an lspconfig entry. Installing `stylua` as a *formatter* silently started `stylua --lsp` as a *server*, competing with conform. Explicit enabling means installing a tool never changes editor behaviour by surprise. |
| D12 | 2026-08-11 | **No trouble.nvim and no nvim-lint (yet).** Diagnostic lists use `Snacks.picker.diagnostics` / `diagnostics_buffer` / `qflist` / `loclist` on `SPC x`. Linting is deferred to Phase 6, per language. | `Snacks.picker.diagnostics()` already gives a filterable, previewable diagnostic list, and quickfix is where results want to end up. trouble's real edge is a *persistent* split — add it if you miss that. For linting: every language configured today (Python, C/C++, SystemVerilog) gets diagnostics from its LSP, so nvim-lint would sit idle. The two standalone linters on this machine, `shellcheck` and `verible-verilog-lint`, belong to specific languages — wire them where those languages are set up. |
| D11 | 2026-08-10 | **Project root detection is `vim.fs.root()` in the `pick()` helper, not a plugin.** Marker list: `.git`, `Makefile`, `pyproject.toml`, `compile_commands.json`, `slang.json`, `.envrc`. | The gap was real — snacks.picker defaults to plain `uv.cwd()` — but `vim.fs.root()` does what `project.el` does in three lines. Only the picker was affected; LSP has its own `root_markers`, git tools ask git. |
| D10 | 2026-08-10 | **Phase 3 adds no plugins.** `dired` → `Snacks.explorer` rather than `oil.nvim`; `wgrep`/`substitute` → the native `<C-q>` → quickfix → `:cfdo` flow rather than `grug-far.nvim`. | Both were already paid for: snacks is loaded and has an explorer source, and quickfix bulk-edit is built in. Consistent with the Phase 2 pattern of removing plugins that turned out to duplicate built-ins. `oil.nvim` is a genuinely different model (edit the directory as text) — worth revisiting only if `Snacks.explorer` annoys you. |
| D9 | 2026-08-10 | **No LuaSnip.** Snippets are `friendly-snippets` + blink's default source, expanding through Neovim's built-in `vim.snippet`. Custom snippets go in `~/.config/nvim/snippets/` as VSCode JSON. | `~/.emacs.d/snippets/` turned out to be **empty** — there were no custom snippets to port, only the community packs, which `friendly-snippets` replaces directly. blink already defaults to `friendly_snippets = true`. Adding LuaSnip would be a dependency and a second snippet syntax bought for nothing. Revisit only if a snippet needs real logic. |
| D8 | 2026-08-10 | **Treesitter parser fix pulled forward from Phase 5 to a new Phase 1b.** | It degrades editing *today* (every language on regex highlighting), Phase 3 needs parsers for `picker.treesitter()` as the `consult-outline` replacement, and Phase 5 needs them for indent. ~20 min of work sitting behind four phases. |
| D7 | 2026-08-10 | **`H` / `L` keep Neovim's defaults** (screen top / bottom) on both sides. Drop the `evil-args` rebinding in Emacs rather than porting it to Neovim. | Enze has never knowingly used the argument-motion binding, so there is nothing to preserve. Matching the vim default aligns both editors at zero learning cost. Revisit via F1 if the motion turns out to be missed. |

---

## 4. Keymap contract

**This table is the source of truth for both editors.** Phase 1 implements it.

> For what is *actually bound today* — every key, not just the contract — see
> **[keymaps.md](keymaps.md)**, generated from a live keymap dump. This table is the
> target; that file is the state.

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
| `H` / `L` | `evil-forward-arg` / `evil-backward-arg` | screen top/bottom | **Neovim default on both** (D7) — unbind in Emacs, add nothing in Neovim. Buffer switching goes on `[b` / `]b` instead |
| `SPC w` | window prefix | window prefix | **window prefix**; this is the biggest muscle-memory hazard — `SPC w h` currently *saves* in Neovim |

---

## 5. Phases

### Phase 0 — Baseline and guardrails · `DONE` (2026-08-10)

- [x] Commit the untracked tree (`GEMINI.md`, `conductor/` — both intentional, now tracked)
- [x] Run `:checkhealth`, triage everything red (see below)
- [x] Confirm `lazy-lock.json` is tracked and current — 27 entries, all installed, no orphans, no drift
- [x] Commit this plan document
- [x] Confirm Emacs still starts clean (`emacs --batch -l ~/.emacs.d/init.el`)
- [x] Silence the unused remote-plugin providers so future healthchecks are readable

#### Health triage (2026-08-10)

| Finding | Verdict | Action |
|---|---|---|
| `luarocks`: needs Lua 5.1, found 5.5 → **ERROR** | Real, but caused **only** by Neorg's `tree-sitter-norg` rocks | Disappears in Phase 1 when Neorg is removed (D3) |
| `nvim-treesitter`: **"Installed languages" list is empty** | **Real and significant** — confirms I1. No parsers are installed at all; only Neovim's bundled ones and Neorg's rocks are present. Highlighting for Python / C++ / Verilog is running on regex, not treesitter | Phase 5 |
| `Snacks.dashboard`: `setup did not run` → ERROR | **False positive** — headless artifact, `UIEnter` never fires | none |
| `Snacks.input`: `vim.ui.input` not set → ERROR | **False positive** — same cause; passes once `UIEnter` is fired | none |
| `Snacks.image`: no kitty graphics protocol → ERROR | Benign — module is disabled, and the terminal genuinely lacks the protocol | none |
| `Snacks.picker`: `setup {disabled}` | Expected | Phase 3 enables it |
| Neorg: key `gO` conflict | Expected | Phase 1 removes Neorg |
| node / perl / ruby / python3 provider warnings | Noise | **Fixed** — providers disabled in `options.lua` |
| `mini.icons` / `nvim-web-devicons` missing | Expected | Phase 10 |
| `vim.deprecated` | ✅ clean — I9 and I10 are soft deprecations that this check does not flag | Phase 5 |
| Emacs `emacs-mcp`: port 38840 in use | Benign — an Emacs daemon is already running and holds the port. Config itself loads clean | none |

**Baseline recorded:** Neovim 0.12.4 · lazy.nvim 11.17.5 · 27 plugins · treesitter parsers: 0 installed.

---

### Phase 1 — Keybinding contract · `DONE` (2026-08-10)

**Neovim side** — `lua/config/keymaps.lua` rewritten around §4
- [x] All which-key groups declared in one place, with a header comment pointing at §4
- [x] `<leader>w` → window prefix (`wh/wj/wk/wl/wp/ws/wv/wc/wd/wo/w=`); save moved to `<C-s>`
- [x] `<leader>h` → help prefix; `nohlsearch` moved to `<Esc>`
- [x] `<leader>t` (tabs) → `<leader><tab>`
- [x] `<leader>x` (`:wq`) removed, reserved for trouble.nvim
- [x] `<leader>q` → `<leader>qq` quit / `<leader>qQ` quit-all
- [x] Added `SPC SPC`, `SPC ,`, `SPC /`, `SPC f`, `SPC s`, `SPC h`, `SPC b b`
- [x] `jk` → `<Esc>` in insert mode
- [x] `]e` / `[e` diagnostics via `vim.diagnostic.jump`
- [x] `[b` / `]b` buffer prev/next (`H` / `L` untouched — D7)
- [x] `lua/plugins/neorg.lua` deleted (D3) — `Lazy clean` removed 8 plugins, 27 → 19
- [x] Global `conceallevel` / `concealcursor` removed from `options.lua`

**Emacs side** — 14 edits, all verified applied
- [x] `SPC a` ↔ `SPC A` swapped: AI is now `SPC a` (claude `a c`, gemini `a g`, codex `a x`, gptel `a t m`), applications moved to `SPC A` (calc, eshell, proced)
- [x] Toggles `SPC t` → `SPC u` (`my-keybindings.el` d/r/w/F/M, `my-appearance.el` font, `my-spell.el` spell-fu)
- [x] `SPC s g` = `consult-ripgrep` (project grep); `consult-git` moved to `SPC s V`. `SPC s r` kept as an alias so existing muscle memory still works
- [x] `K` unbound from `evil-jump-out-args` — falls back to `evil-lookup-func`, already set to `helpful-at-point`
- [x] `H` / `L` unbound from `evil-args` (D7); `ia` / `aa` argument text objects kept
- [x] Spell `zg` / `zw` — **no-op, already correct.** They were on `general-nmap`, i.e. already the native vim keys, not under the leader

**Notes for later**
- `lisp/my-maybe.el` still binds `SPC a d d` (detached), but `init.el` never requires that
  file. It is dead code — left alone deliberately.
- Telescope is still the implementation behind `SPC SPC` / `SPC f` / `SPC s` / `SPC h`.
  Phase 3 swaps in snacks.picker by changing only the right-hand side of those mappings;
  the keys do not move again.

**Verified:** `SPC wh` → "Go to left window", `<C-s>` → "Save file", `SPC sg` → "Grep
project", `SPC <tab><tab>` → "New tab", old `SPC w` save mapping gone, `conceallevel` 0.
Emacs config loads clean under `emacs --batch`.

---

### Phase 1b — Treesitter parsers · `DONE` (2026-08-10)

Pulled forward from Phase 5 (D8). Fixes I1.

- [x] Rewrite `lua/plugins/treesitter.lua` for the `main` branch API: `setup{}` +
      `install()` for missing parsers only + `vim.treesitter.start()` in a FileType autocmd
- [x] Set `indentexpr` to `v:lua.require'nvim-treesitter'.indentexpr()` per buffer
- [x] Install parsers — **26 installed**, all with highlight and injection queries
- [x] Verify a real buffer: `python` parser attached, highlighter active, indentexpr set

**Parser-name gotchas found** (all three would have failed silently):
- There is **no `verilog` parser** on `main` — it is `systemverilog`, which covers both.
  This is the same substitution `~/.emacs.d/lisp/my-treesit.el` already makes.
- `jinja`, not `jinja2`.
- There is no `jsonc` parser; `json` handles both.
- The old config's `"c++"` was never a valid name either (`cpp`).

**Done when:** ✅ `:checkhealth nvim-treesitter` lists parsers under "Installed languages".

---

### Phase 2 — Core editing parity · `DONE` (2026-08-10)

| Emacs | Neovim replacement | Done |
|---|---|---|
| `evil-surround` | `kylechui/nvim-surround` — `ys` / `cs` / `ds` | [x] |
| `evil-nerd-commenter` | built-in `gc` / `gcc`, no plugin | [x] |
| `evil-easymotion` + `evil-snipe` | `folke/flash.nvim` — `s`, `S`, `r`, `R`. Both took `s` in Emacs, so the key carries over | [x] |
| `evil-args` + the 5 custom quoted text objects | `nvim-mini/mini.ai` | [x] |
| `evil-lion` | `nvim-mini/mini.align` — `ga` / `gA`, and Emacs rebound to match (was `gl` / `gL`) | [x] |
| `evil-owl` | which-key register/mark preview, already installed | [x] |
| `evil-numbers` | built-in `<C-a>` / `<C-x>` — **deliberate divergence, see below** | [x] |
| `undo-fu` + session | `undofile` + `undolevels = 10000`. **undotree removed** — see F4 | [x] |
| `super-save` | `FocusLost` / `BufLeave` autocmd, guarded on modified + modifiable + real file | [x] |
| `ws-butler` | **nothing yet** — mini.trailspace removed; conform in Phase 5 covers it. See F6 | — |
| `yasnippet` + `doom-snippets` | blink's built-in `snippets` source over `vim.snippet` — **no LuaSnip (D9), and no snippet pack, see F5** | [x] |
| `evil-mc` | **skipped** — see follow-up F2 | — |
| custom filepath textobject (`vif`/`vaf`) | not ported — see follow-up F3 | — |

- [x] Per-filetype indent overrides: `lua`, `yaml`, `json`, `toml`, `jinja`, `html`, `css` → 2 spaces

**Findings**

- **`~/.emacs.d/snippets/` is empty** — zero custom snippets, so nothing had to be ported.
  Only the community packs (`yasnippet-snippets`, `doom-snippets`) were in play, and
  `friendly-snippets` is the direct equivalent. This is what makes D9 possible.
- **mini.ai covers the `define-and-bind-quoted-text-object` macro for free.** It treats any
  unclaimed punctuation as a self-delimiting pair, so `vi|`, `vi/`, `vi*`, `vi=`, `vi$` all
  work with no config. Verified: with the cursor in `foo(alpha, beta) |bar| /baz/`, `ia`
  selects `alpha`, `i|` selects `bar`, `i/` selects `baz`.
- **`evil-numbers` is a deliberate divergence from D3.** Neovim uses the built-in
  `<C-a>` / `<C-x>`; Emacs keeps `C-c +` / `C-c -`. Binding `C-x` in `evil-normal-state-map`
  would shadow the entire Emacs `C-x` prefix in normal state, which is not worth it.

**Verified:** `ys`→surround, `s`→flash, `ga`→align, `gc`→comment, `<C-a>`→builtin,
`<leader>uu`→undotree, `<leader>cw`→trim, `undofile` on, mini.ai loaded. 26 plugins,
targeted `:checkhealth` 0 errors. Emacs loads clean after the evil-lion rebind.

**Done when:** you can edit for an hour without reaching for an Emacs-only motion.

---

### Phase 3 — Finding and navigation · `DONE` (2026-08-10)

**snacks.picker** replaces vertico + orderless + marginalia + consult + embark (D5), and
telescope. **Net −2 plugins: 23 → 21, nothing added.**

| Emacs | Neovim | Done |
|---|---|---|
| `SPC SPC` project-find-file | `picker.files()` | [x] |
| `SPC ,` / `SPC b b` consult-buffer | `picker.buffers()` | [x] |
| `SPC /` `SPC s g` consult-ripgrep | `picker.grep()` | [x] |
| `SPC s l` / `SPC s b` consult-line | `picker.lines()` | [x] |
| `SPC s i` consult-imenu | `picker.lsp_symbols()` | [x] |
| `SPC s h` consult-outline | `picker.treesitter()` | [x] |
| `SPC s m` consult-mark | `picker.marks()` | [x] |
| `SPC f r` recentf | `picker.recent()` | [x] |
| `SPC *` my/search-project-for-symbol-at-point | `picker.grep_word()` | [x] |
| `SPC h h/k/c/m` helpful | `picker.help/keymaps/commands/man()` | [x] |
| `embark-act` (`C-;`) | picker actions, `<C-q>` → quickfix | [x] |
| `dired` | **`Snacks.explorer()` on `SPC f e`** — see D10 | [x] |
| `wgrep` + `substitute` (`SPC r`) | **native `<C-q>` + `:cfdo`** — see D10, F7 | [x] |

- [x] Remove telescope + telescope-fzf-native from `lua/plugins/example.lua`
- [x] Replace the telescope keymaps in `lua/config/keymaps.lua` with a `pick()` helper
- [x] Drop telescope from neogit's dependencies; it has a native `integrations.snacks`
- [x] Enable `picker` and `explorer` in `lua/plugins/snacks.lua`

**Bonus pickers added** (no Emacs counterpart, but cheap and useful): `SPC s R` registers,
`SPC s u` undo history, `SPC h a` autocmds, `SPC h H` highlight groups.

**Dropped:** `SPC h o` (telescope's `vim_options`) — snacks has no equivalent picker.

**Search and replace across a project, without a plugin:**
1. `SPC / ` or `SPC s g` and search
2. `<C-q>` inside the picker → sends every match to the quickfix list
3. `:cfdo %s/old/new/g | update`

That is the wgrep workflow using only built-ins, which is why no plugin was added (D10).

**Verified:** all 11 contract keys resolve to picker functions, `vim.ui.select` is now
`Snacks.picker.select`, and `:checkhealth snacks` reports the whole picker section green —
including the `regex` parser requirement, which Phase 1b had already installed.

**Done when:** ✅ telescope is gone and `SPC p f` is no longer mapped.

---

### Phase 4 — Project and workspace · `DONE` (2026-08-10)

Rewritten before execution: the original plan assumed a root-detection plugin and a direnv
plugin. Investigation showed both were already covered — see D11 and F8. **One plugin added.**

- [x] **Project root detection — no plugin.** `vim.fs.root()` with a marker list
      (`.git`, `Makefile`, `pyproject.toml`, `compile_commands.json`, `slang.json`, `.envrc`)
      inside the existing `pick()` helper in `keymaps.lua`. Applied only to the four
      tree-searching sources (`files`, `grep`, `grep_word`, `explorer`); everything else is
      buffer-scoped and ignores `cwd`
- [x] `folke/persistence.nvim` for per-directory sessions, replacing the manual
      `.session.vim` mappings (`SPC p s` / `SPC p l`)
- [x] `SPC p p` → `Snacks.picker.projects()`, pointed at `~/Projects`. This is the
      tabspaces equivalent: it chdirs into the project **and** calls
      `require("persistence").load()` to restore that project's session — snacks looks the
      plugin up by name, which is why persistence was the right choice over alternatives
- [x] `SPC p r` shows the detected root, for when a picker searches somewhere surprising
- [x] `SPC p D` opens **any** directory as a project — the `project-prompt-project-dir`
      equivalent. `Snacks.picker.projects()` can only match directories it already scanned,
      so this covers first-time and one-off projects. Path completion works because
      `Snacks.input` forwards `completion = "dir"` to `vim.fn.getcompletion()`
- [x] `envrc` → **no plugin (F8)**
- [x] `SPC <tab>` tabspaces mirror — already done in Phase 1
- [x] `SPC p d` → `:tcd` kept

**Why no root-detection plugin:** `Snacks.picker.files()`/`grep()` default to `uv.cwd()`,
with no root detection (only the `git.*` and `recent` sources use `Snacks.git.get_root()`).
So the gap was real — `SPC /` launched from `~` would grep the whole home directory — but
`vim.fs.root()` is a built-in that closes it in three lines. Nothing else was affected: LSP
does its own detection via `root_markers`, and gitsigns/neogit ask git directly.

**Why no direnv plugin:** `direnv` 2.37.1 is installed and `eval "$(direnv hook zsh)"` is
already active in `~/.zshrc`, so any nvim launched from a project directory inherits the
`.envrc` environment — and so do the LSP servers it spawns. There are 7 `.envrc` files
across `~/Projects`. The only stale case is `:tcd` to a different project inside a running
nvim, which the tmux-pane-per-project workflow makes rare. See F8.

**Verified:** with cwd `~/Projects/org-gtd` and the open buffer in `~/Projects/dotfiles`,
`vim.fs.root()` resolved to `~/Projects/dotfiles` — exactly the case where plain `cwd`
would have been wrong. All 7 `SPC p` keys resolve; the old `SPC p s` is gone.

**Not verified end-to-end:** that the picker *visibly* opens at the detected root, and the
project → session round trip. Both need a real UI — do them as the "one real task" gate.

**Done when:** `SPC p p` switches project and restores its layout.

---

### Phase 5 — LSP, diagnostics, format, lint · `TODO`

You are already on Neovim's native `vim.lsp.config` API — this is gap-filling, not replacement.

- [x] ~~Fix treesitter, match the parser list to Emacs `treesit-auto`~~ — **moved to Phase 1b (D8), done**
- [x] `vim.diagnostic` config: signs, severity sort, inline text for WARN and above only, rounded float
- [x] ~~`folke/trouble.nvim` on `SPC x`~~ — **not added, see D12.** `SPC x x` / `x X` / `x q` / `x l` use the picker
- [x] `stevearc/conform.nvim` — replaces `eglot-format`, `python-black`, and `ws-butler`. **Closes F6**
- [ ] ~~`mfussenegger/nvim-lint`~~ — **deferred to Phase 6 (D12).** LSP already supplies diagnostics for every language currently configured
- [x] ~~LuaSnip source for `blink.cmp`~~ — N/A, superseded by D9
- [ ] Extend mason `ensure_installed` to cover every Phase 6 language — deferred to Phase 6, where the languages are
- [x] Fix deprecations I9 (`vim.highlight.on_yank` → `vim.hl.on_yank`) and I10 (`vim.loop` → `vim.uv`)

**Formatters wired** (only ones actually installed — conform skips a missing binary, but
listing aspirational tools would hide that a filetype has none):

| Filetype | Formatter | Source |
|---|---|---|
| python | `ruff_organize_imports`, `ruff_format` | `~/.local/bin/ruff` — replaces `python-black`; ruff's formatter is black-compatible |
| c, cpp | `clang-format` | homebrew |
| systemverilog, verilog | `verible_verilog_format` | `~/.local/bin` |
| toml | `taplo` | cargo |
| lua | `stylua` | installed via `:MasonInstall` during this phase |
| sh, bash | `shfmt` | installed via `:MasonInstall` during this phase |
| *everything else* | `trim_whitespace` | conform built-in — this is what closes F6 |

**Format-on-save is off by default**, toggled with `SPC u f` (global) or `SPC u F` (buffer).
Same reasoning that removed mini.trailspace: silently rewriting a file you only opened to
read produces noisy diffs. `SPC c f` formats on demand and mirrors Emacs' `SPC c f`.

**Verified end-to-end**, not just loaded: `stylua` normalised `local  x   =  1`, `ruff`
reformatted `def  f( a,b )`, and a plain `.txt` file had its trailing whitespace stripped by
the `_` fallback. `:checkhealth vim.deprecated` is clean.

**Note for a fresh machine:** `stylua` and `shfmt` came from `:MasonInstall stylua shfmt`.
mason-lspconfig's `ensure_installed` only covers LSP servers, so these two are not yet
declared anywhere. Either run that command again or revisit in Phase 6.

**Done when:** ✅ formatting works on demand, diagnostics render, `SPC x x` lists them.

---

### Phase 6 — Languages · `DONE` (2026-08-11)

**Scope was set by counting files in `~/Projects`, not by porting the Emacs module list.**
That changed the plan substantially — three of the languages with Emacs modules turned out
to be unused.

| Extension | Files | Verdict |
|---|---|---|
| `.v` / `.svh` / `.sv` | 1885 / 167 / 133 | **dominant** — configured |
| `.md` | 866 | configured |
| `.h` / `.cpp` / `.cc` | 272 / 186 / 7 | configured |
| `.py` | 129 | configured |
| `.sh` | 126 | configured |
| `.toml` / `.yml` / `.yaml` | 79 / 38 / 8 | configured |
| `.lua` | 18 | configured (this repo) |
| `.rs` | 1 | **skipped** — no rust-analyzer installed either |
| `.vhd` | 1 | **skipped** |
| `.go` | **0** | **skipped** — no Go toolchain either. `my-go.el` is 234 lines of dead config |

**Servers wired and verified attaching to a real file of each type:**

| Filetype | Client(s) | Installed via |
|---|---|---|
| python | `basedpyright` + `ruff` | mason / `~/.local/bin` |
| systemverilog, verilog | `slang_server` | `~/.local/bin` |
| c, cpp | `clangd` | mason |
| lua | `lua_ls` + lazydev | mason |
| markdown | `marksman` | mason |
| yaml | `yamlls` | mason |
| toml | `taplo` | cargo |
| sh, bash | `bashls` | homebrew |

`ruff` runs *alongside* basedpyright — types and completion from one, lint and import
sorting from the other. Together they replace `pylint` + flymake, which is why Python needs
no nvim-lint entry.

**Linting: no linter plugin at all.** The Phase 5 deferral (D12) resolved to "not needed" —
see D14. Both candidate linters were already covered:

- **SystemVerilog** — you chose slang over verible, and `slang-server` *is* slang. Measured
  on a real 2 KB `.sv` file: 16 diagnostics from the LSP, 17 from `slang -Weverything` via
  nvim-lint, 7 byte-identical. Diffing the rest showed they were the *same* findings — the
  CLI just appends the flag name (`unused parameter 's' [-Wunused-parameter]`) and offsets
  columns slightly. Running both would double every warning. The CLI also lints one file in
  isolation, while the server has the indexed workspace.
- **sh/bash** — `bash-language-server` runs shellcheck itself and reports the results.
  Verified: a `[ $1 == "x" ]` quoting warning arrives under `ns=nvim.lsp.bashls`, with no
  linter plugin installed.

Passing `-Weverything` to slang-server was tried three ways — LSP `settings`,
`init_options`, and a workspace `slang.json` with `{"flags": "-Weverything"}` — and the
count stayed at 16 in every case, so the server already reports at that level.

**Three things verification caught that would have failed silently:**

1. **`stylua` was running as a language server.** `mason-lspconfig`'s `automatic_enable`
   defaults to on and enables *every* installed mason package that has an lspconfig entry —
   and nvim-lspconfig ships a `stylua` entry (`stylua --lsp`). Installing stylua as a
   formatter in Phase 5 silently started it as a server competing with conform. Fixed with
   `automatic_enable = false`; servers are enabled explicitly in `lua/config/lsp.lua`. See D13.
2. **`nvim-lint` has no `verible_verilog_lint` linter.** The name from the original plan
   does not exist, so the config would have been a no-op. (Moot now — verible was replaced
   by slang, then nvim-lint removed entirely.)
3. **verible wrote to stderr, not stdout.** With `stream = "stdout"` the linter ran and
   parsed nothing. Only caught by checking diagnostic *namespaces* — a `vim.diagnostic.get()`
   count looked like success because slang-server's diagnostic was already in the buffer.
   The same namespace technique is what later exposed the slang double-reporting.

**Filetype check that turned out fine:** `vim.filetype.match()` on a bare `.v` filename
returns `v` (the V language), which would have broken 1885 files. On real content Neovim
detects `verilog` correctly, and already maps that filetype to the `systemverilog` parser.
No fix needed — verified rather than assumed.

**Not configured, deliberately:** Go, Rust, VHDL (see the file counts above), jinja,
graphviz/plantuml/mermaid. `cmake` has no `.cmake` files here; `CMakeLists.txt` support can
come with a real need.

**Done when:** ✅ every language you touched in the last month has LSP, format, and lint.

### Phase 7 — Git · `DONE` (2026-08-11)

One plugin added — **diffview**, the only real gap. Everything else was already paid for:
`Snacks.picker` ships eight git sources, and gitsigns/neogit/git-commit-gen were installed
in earlier phases.

| Emacs | Neovim | Done |
|---|---|---|
| `SPC g g` magit-status | `SPC g g` neogit | [x] |
| `SPC g b` magit-branch-checkout | `SPC g b` `picker.git_branches()` | [x] |
| `SPC g B` magit-blame-addition | `SPC g B` gitsigns blame buffer | [x] |
| `SPC g l l` magit-log | `SPC g l l` `picker.git_log()` | [x] |
| `SPC g l b` magit-log-buffer-file | `SPC g l b` `picker.git_log_file()` | [x] |
| — | `SPC g l L` `picker.git_log_line()` | [x] |
| `SPC g t` git-timemachine | `SPC g t` `:DiffviewFileHistory %` | [x] |
| `SPC g S` magit-stage-file | `SPC g h S` gitsigns stage buffer; `SPC g S` is stashes | [x] |
| `magit-diff`, `ediff` | `SPC g d` / `SPC g D` diffview | [x] |
| — | `SPC g s` `picker.git_status()`, `SPC g f` `picker.git_files()` | [x] |
| `gptel-magit` | `SPC g m` / `g M` git-commit-gen | [x] |
| hunks | `SPC g h *` gitsigns, `]h` / `[h` | [x] |
| — | `SPC g o` open in browser | [x] |

**Two collisions fixed.** `SPC g B` was snacks' gitbrowse but is blame in Emacs, and
`SPC g l b` was blame-line but is this file's log in Emacs. Browse moved to `SPC g o`;
blame-line remains at `SPC g h b`.

**Why diffview was worth a plugin, when oil/grug-far/project.nvim/nvim-lint were not:**
it is the only thing that provides a side-by-side diff across a whole changeset, steppable
file history, and 3-way merge conflict resolution. `Snacks.picker.git_diff` lists changed
files and previews them; neogit's status buffer shows per-hunk diffs. Neither is a review
UI. It also replaces two Emacs packages at once — `ediff` and `git-timemachine` — and
neogit has a native `integrations.diffview` so the two cooperate.

**Verified:** all 15 `SPC g` keys resolve, and `:DiffviewFileHistory %` actually opens a
view (checked via `diffview.lib.get_current_view()`, not just that the command returned).

**Left to you:** neogit itself. It is ~80% of magit but the keys are its own — spend a
session doing a real stage → commit → push through it.

**Done when:** ✅ a full stage → commit → push cycle without opening magit.

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
| I1 | `lua/plugins/treesitter.lua` uses the pre-`main` API against a `main`-pinned plugin — `ensure_installed`/`highlight`/`indent` are silently ignored; `"c++"` is not a valid parser name | ~~5~~ 1b | [x] |
| I2 | `<leader>w` = save collides with the window prefix in both schemes | 1 | [x] |
| I3 | `<leader>h` = `nohlsearch` collides with the help prefix | 1 | [x] |
| I4 | `<leader>t` = tabs collides with the Emacs toggle prefix | 1 | [x] |
| I5 | which-key groups in `keymaps.lua` are stale — `<leader>w` labelled "File", `<leader>t` "Tabs"; several plugin-spec groups undeclared | 1 | [x] |
| I6 | Telescope and snacks.picker both installed | 3 | [x] |
| I7 | `lua/plugins/example.lua` holds unrelated specs; should be split | 10 | [ ] partly — telescope removed in Phase 3, so it is down to which-key + plenary. Still wants renaming |
| I8 | Neorg configured against `~/Projects/org-gtd/neorg/notes`, which is empty | 1 | [x] |
| I9 | `vim.highlight.on_yank` deprecated on 0.12 → `vim.hl.on_yank` | 5 | [x] |
| I10 | `vim.loop` in `lua/config/lazy.lua` deprecated → `vim.uv` | 5 | [x] |
| I11 | Full `:checkhealth` takes >3 min headless — mason's registry-api network call is the likely culprit. Use a targeted `:checkhealth lazy nvim-treesitter which-key vim.lsp vim.treesitter` as the phase gate instead | — | [ ] |

---

## 8. Session log

One line per working session. Newest last.

| Date | Phase | What happened |
|---|---|---|
| 2026-08-10 | — | Surveyed both configs; wrote this plan. Decisions D1–D6 locked. |
| 2026-08-10 | 0 | Baseline done. Health triaged: only real finding is **zero treesitter parsers installed** (I1 confirmed, worse than expected). Two snacks "errors" proved to be headless artifacts — caveat added to §0. lazy-lock verified in sync (27/27). Emacs loads clean. Providers disabled. |
| 2026-08-10 | 1 | `H` / `L` resolved as D7 — vim defaults on both sides, evil-args binding dropped. Logged F1 to revisit if missed. Phase 1 is unblocked. |
| 2026-08-11 | 7 | **Done.** One plugin (diffview), 24 → 25 — the one genuine gap, since it is the only source of side-by-side changeset diffs, steppable file history and 3-way merges, and it replaces both `ediff` and `git-timemachine`. The other eight `SPC g` entries came free from `Snacks.picker`'s git sources. Fixed two keymap collisions against the magit map. Next: **Phase 8** (terminal, build, run). |
| 2026-08-11 | 6 | Verilog linting switched from verible to **slang** at Enze's request — which then made the linter plugin redundant, since slang-server is slang. Measured the overlap, found the CLI re-reports what the LSP already gives, and confirmed bashls runs shellcheck on its own. **nvim-lint removed, 25 → 24** (D14). |
| 2026-08-11 | 6 | **Done, scoped by file counts rather than by the Emacs module list** — Go (0 files, no toolchain), Rust (1) and VHDL (1) dropped. 8 languages wired, each verified attaching to a real file. 2 plugins (lazydev, nvim-lint), 23 → 25. Verification caught three silent failures: stylua running as an LSP (D13), a linter name that does not exist, and verible writing to stderr. Next: **Phase 7** (git) — neogit is already installed, mostly needs diffview and learning. |
| 2026-08-11 | 5 | **Done.** One plugin added (conform), 22 → 23. trouble.nvim and nvim-lint both declined (D12): the picker already lists diagnostics, and every configured language gets them from its LSP. Formatters verified end-to-end for lua/python/plain-text rather than just loaded. **F6 closed** by conform's `trim_whitespace`. I9 and I10 deprecations fixed; `:checkhealth vim.deprecated` clean. Next: **Phase 6** (languages), which also picks up mason tool declarations and per-language linters. |
| 2026-08-10 | 4 | **Done, rewritten first.** Challenged the two plugin assumptions and both fell: root detection is `vim.fs.root()` in three lines (D11), and direnv is already handled by the zsh hook (F8). Only persistence.nvim added, 21 → 22 — and it earns its place because `Snacks.picker.projects()` looks it up **by name** to restore a project's session on switch, giving the tabspaces workflow. Next: **Phase 5** (LSP/format/lint), which also closes F6. |
| 2026-08-10 | 3 | **Done, and it removed plugins instead of adding them** (23 → 21): telescope + fzf-native out, nothing in. `Snacks.explorer` covers dired and the native `<C-q>`/`:cfdo` flow covers wgrep, so neither oil.nvim nor grug-far was needed (D10, F7). Neogit moved to its native snacks integration. `vim.ui.select` now routes through the picker, closing a Phase 0 health warning. Next: **Phase 4** (project/workspace) — it blocks Phase 6 via direnv. |
| 2026-08-10 | 2 | Trimmed on review: **undotree and friendly-snippets removed** as unused (F4, F5), 26 → 24 plugins. `undofile` and blink's snippet source stay — neither needed the plugin. |
| 2026-08-10 | 2 | **mini.trailspace removed** as unused (F6), 24 → 23. Phase 5's conform is the better home for this anyway. Phase 2 settles at 4 added plugins: nvim-surround, flash, mini.ai, mini.align. |
| 2026-08-10 | 2 | **Done.** 6 plugins added (nvim-surround, flash, mini.ai, mini.align, mini.trailspace, undotree) + friendly-snippets; `gc` and `<C-a>`/`<C-x>` needed no plugin at all. Two things fell out cheaper than planned: `~/.emacs.d/snippets/` is empty so LuaSnip was dropped entirely (D9), and mini.ai covers the custom quoted text objects for free. `evil-mc` deferred to F2 over the `gr` LSP-prefix collision. 26 plugins, 0 health errors. Next: **Phase 3** (snacks.picker). |
| 2026-08-10 | 1 + 1b | **Both done.** Keymap contract implemented on both sides (12 Neovim items, 14 Emacs edits). Neorg removed, 27 → 19 plugins, which killed the luarocks/Lua 5.1 error. Treesitter rebuilt for the `main` API: 26 parsers installed, highlighter and indentexpr verified live in a real buffer. Targeted `:checkhealth` is **0 errors**, down from 3. Emacs loads clean. Next: **Phase 2** (editing parity) or **Phase 3** (snacks.picker) — independent, pick either. |

---

## 9. Follow-ups

Deliberately deferred. Not blocking any phase; revisit when the trigger fires.

| # | Item | Trigger to revisit | Raised |
|---|---|---|---|
| F8 | No direnv integration inside Neovim. The zsh hook covers launch-time, so this only matters if you `:tcd` to a different project inside a running nvim — the env, and any LSP server already started, keep the old project's `.envrc`. Fix by restarting nvim in that project, or add `direnv/direnv.vim`. | You `:tcd` between projects and an LSP or tool picks up the wrong venv | 2026-08-10 |
| F7 | No dedicated search-and-replace UI. `MagicDuck/grug-far.nvim` is the candidate; the native `<C-q>` → `:cfdo %s/old/new/g \| update` flow covers the same ground and was chosen instead (D10). | The quickfix flow gets tedious — e.g. you want a live preview of replacements before committing | 2026-08-10 |
| F6 | ~~**CLOSED in Phase 5**~~ — conform's `trim_whitespace` runs as the `_` fallback for every filetype without a real formatter, verified on a plain `.txt`. Original note: No trailing-whitespace handling. `mini.trailspace` was installed in Phase 2 and removed the same day as unused. **Phase 5 should cover this**: conform.nvim trims trailing whitespace as part of per-language formatting, which is closer to ws-butler's intent than a whole-buffer trim anyway. Check it there before adding anything. | Phase 5, or you notice whitespace creeping into diffs | 2026-08-10 |
| F4 | `mbbill/undotree` was installed in Phase 2 and removed the same day as unused. Persistent undo still works — that is `undofile`, not the plugin. Re-add only if you actually want to browse the undo *tree* (branches), which plain `u` / `<C-r>` cannot reach. | You lose work down an undo branch | 2026-08-10 |
| F5 | No snippet corpus. `friendly-snippets` (the `yasnippet-snippets` / `doom-snippets` equivalent) was installed in Phase 2 and removed the same day as unused. blink's `snippets` source is still enabled and will pick up anything you put in `~/.config/nvim/snippets/` as VSCode JSON — so writing your own few needs no plugin at all. | You want tab-expandable boilerplate and don't want to hand-write it | 2026-08-10 |
| F2 | `evil-mc` was not replaced. `jake-stewart/multicursor.nvim` is the candidate, but its conventional `gr…` prefix now collides with Neovim 0.11+'s built-in LSP maps (`grn` rename, `gra` code action, `grr` references) and with `gr` in `lua/plugins/lsp.lua`. Pick a non-conflicting prefix before adding it. | You want multiple cursors and LSP rename isn't enough | 2026-08-10 |
| F3 | The custom filepath text object from `my-evil.el` (`vif` = basename, `vaf` = full path) was not ported. Doable as a custom `mini.ai` spec. | You reach for `vif` on a path and it selects a function | 2026-08-10 |
| F1 | `H` / `L` argument motions (`evil-forward-arg` / `evil-backward-arg`) were dropped per D7. If you find yourself missing a "jump to next/previous function argument" motion, add it in Neovim via `nvim-treesitter-textobjects` (e.g. `]a` / `[a`) rather than re-taking `H` / `L`. | You reach for it and it isn't there | 2026-08-10 |
