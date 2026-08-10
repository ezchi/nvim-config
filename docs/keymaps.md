# Keymap reference

Every mapping this config defines, with its Emacs counterpart from `~/.emacs.d`.

Generated from a live `nvim_get_keymap()` dump on 2026-08-10, after migration phase 3.
The *target* scheme lives in [migration-plan.md §4](migration-plan.md); **this file is what
is actually bound today**. When they disagree, this file is wrong — regenerate it:

```sh
nvim --headless -c 'lua vim.print(vim.api.nvim_get_keymap("n"))' +qa
```

**Leader is `<Space>`** in both editors. `SPC` below means the leader.
Modes: **n** normal · **i** insert · **x** visual · **o** operator-pending · **t** terminal · **c** command-line.

An empty Emacs column means there is no counterpart — usually because the Neovim side is a
built-in that Emacs solved a different way.

---

## Top level

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC SPC` | n | Find file in project | `SPC SPC` project-find-file |
| `SPC ,` | n | Switch buffer | `SPC b b` consult-buffer |
| `SPC /` | n | Grep project | `SPC s g` consult-ripgrep |
| `SPC *` | n, x | Grep symbol at point | `SPC *` my/search-project-for-symbol-at-point |
| `SPC -` | n | Split horizontal | `SPC -` evil-window-split |
| `SPC \|` | n | Split vertical | `SPC \|` evil-window-vsplit |
| `SPC .` | n | Toggle scratch buffer | `SPC b s` my/switch-to-scratch-buffer |
| `SPC S` | n | Select scratch buffer | |
| `SPC n` | n | Notification history | |
| `SPC N` | n | Neovim news | |
| `SPC ?` | n | Buffer-local keymaps | `SPC h b` which-key-show-* |

## `SPC a` — AI

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC a g` | n | Open Gemini CLI | `SPC a g` gemini-cli-ide-menu |

Emacs also has `SPC a c` claude-code-ide, `SPC a x` codex-cli, `SPC a t m` gptel.
Neovim consolidation is **phase 9**.

## `SPC b` — Buffer

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC b b` | n | Switch buffer | `SPC b b` consult-buffer |
| `SPC b d` | n | Delete buffer | `SPC b d` kill-current-buffer |
| `SPC b r` | n | Reload buffer | `SPC b r` revert-buffer |
| `SPC b [` | n | Previous buffer | `SPC b [` previous-buffer |
| `SPC b ]` | n | Next buffer | `SPC b ]` next-buffer |

## `SPC c` — Code / LSP

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC c a` | n, x | Code action | `g c a` eglot-code-actions |
| `SPC c r` | n | Rename symbol | `SPC c l r` eglot-rename |
| `SPC c R` | n | Rename file | `SPC f R` my/move-current-file |
| `SPC c c` | n, x | Run codelens | |
| `SPC c C` | n | Refresh codelens | |

Emacs also has `SPC c c` compile / `SPC c C` recompile — those land in **phase 8**.

## `SPC f` — File

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC f f` | n | Find file | `SPC f f` find-file |
| `SPC f r` | n | Recent files | recentf |
| `SPC f n` | n | New file | |
| `SPC f e` | n | File explorer | `SPC f d` dired |

## `SPC g` — Git

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC g g` | n | Neogit status | `SPC g g` magit-status |
| `SPC g B` | n | Open in browser | |
| `SPC g m` | n | Generate commit message (AI) | gptel-magit |
| `SPC g M` | n | Change commit-gen model | |
| `SPC g l b` | n | Blame line | `SPC g B` magit-blame-addition |
| `SPC g h s` | n, x | Stage hunk | magit |
| `SPC g h r` | n, x | Reset hunk | magit |
| `SPC g h S` | n | Stage buffer | `SPC g S` magit-stage-file |
| `SPC g h u` | n | Undo stage hunk | `SPC g U` magit-unstage-file |
| `SPC g h R` | n | Reset buffer | |
| `SPC g h p` | n | Preview hunk inline | |
| `SPC g h b` | n | Blame line (full) | `SPC g B` |
| `SPC g h B` | n | Blame buffer | |
| `SPC g h d` | n | Diff this | ediff |
| `SPC g h D` | n | Diff this against `~` | |

## `SPC h` — Help

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC h h` | n | Help tags | `SPC h f` / `h v` helpful-* |
| `SPC h k` | n | Keymaps | `SPC h k` helpful-key |
| `SPC h c` | n | Commands | `SPC h c` helpful-command |
| `SPC h m` | n | Man pages | |
| `SPC h a` | n | Autocommands | |
| `SPC h H` | n | Highlight groups | |

## `SPC p` — Project / session

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC p p` | n | Switch project (chdir + restore its session) | `SPC TAB .` tabspaces-switch-or-create |
| `SPC p D` | n | Open **any** directory as a project | `project-prompt-project-dir` |
| `SPC p d` | n | Tab-local cwd | |
| `SPC p r` | n | Show detected project root | |
| `SPC p l` | n | Restore session for cwd | |
| `SPC p L` | n | Restore last session | |
| `SPC p S` | n | Select a session | |
| `SPC p Q` | n | Don't save session on exit | |

Sessions save automatically on exit, so there is no "save session" key.

Pickers that search a tree (`files`, `grep`, `grep_word`, `explorer`) are scoped to the
project root found by `vim.fs.root()` — markers: `.git`, `Makefile`, `pyproject.toml`,
`compile_commands.json`, `slang.json`, `.envrc`. Emacs does this via `project.el`.

## `SPC q` — Quit

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC q q` | n | Quit window | `SPC q q` delete-frame |
| `SPC q Q` | n | Quit all | `SPC q Q` save-buffers-kill-emacs |

## `SPC s` — Search

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC s g` | n | Grep project | `SPC s g` consult-ripgrep |
| `SPC s b` | n | Search buffer lines | `SPC s b` my/consult-line-symbol-at-point |
| `SPC s l` | n | Search buffer lines | `SPC s l` consult-line |
| `SPC s i` | n | Symbols (LSP) | `SPC s i` consult-imenu |
| `SPC s h` | n | Outline (treesitter) | `SPC s h` consult-outline |
| `SPC s m` | n | Marks | `SPC s m` consult-mark |
| `SPC s f` | n | Find file | `SPC s f` consult-find |
| `SPC s r` | n | Resume last picker | `SPC s r` consult-ripgrep |
| `SPC s R` | n | Registers | |
| `SPC s u` | n | Undo history | |

## `SPC u` — UI toggles

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC u s` | n | Spelling | `SPC u s` spell-fu-mode |
| `SPC u w` | n | Wrap | `SPC u w` toggle-truncate-lines |
| `SPC u l` | n | Line numbers | |
| `SPC u L` | n | Relative numbers | |
| `SPC u d` | n | Diagnostics | |
| `SPC u c` | n | Conceal level | |
| `SPC u T` | n | Treesitter highlight | |
| `SPC u b` | n | Dark background | |
| `SPC u h` | n | Inlay hints | |
| `SPC u g` | n | Indent guides | |
| `SPC u D` | n | Dimming | |
| `SPC u n` | n | Dismiss notifications | |

Emacs also has `SPC u d` debug-on-error, `SPC u r` read-only, `SPC u F`/`u M` frame,
`SPC u f` font menu — no Neovim counterparts needed.

## `SPC w` — Window

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC w h/j/k/l` | n | Go to left/lower/upper/right window | same |
| `SPC w p` | n | Previous window | `SPC w p` evil-window-mru |
| `SPC w s` | n | Split horizontal | `SPC w s` |
| `SPC w v` | n | Split vertical | `SPC w v` |
| `SPC w c` / `w d` | n | Close window | `SPC w c` / `w d` |
| `SPC w o` | n | Close other windows | `SPC w O` delete-other-windows |
| `SPC w =` | n | Balance windows | `SPC w =` balance-windows |

## `SPC <Tab>` — Tabs

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `SPC <Tab> <Tab>` | n | New tab | `SPC TAB` tabspaces-command-map |
| `SPC <Tab> d` | n | Close tab | |
| `SPC <Tab> ]` / `[` | n | Next / previous tab | `SPC TAB ]` / `[` |
| `SPC <Tab> f` / `l` | n | First / last tab | `SPC TAB f` / `l` |

---

## Motions and operators

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `s` | n, x, o | Flash jump | `s` evil-snipe / `SPC` evil-easymotion |
| `S` | n, x, o | Flash treesitter select | |
| `r` | o | Remote flash | |
| `R` | o, x | Treesitter search | |
| `ys` / `yss` | n | Add surround around motion / line | evil-surround `ys` |
| `cs` / `ds` | n | Change / delete surround | evil-surround `cs` / `ds` |
| `gS` | x | Surround selection on new lines | |
| `<C-g>s` | i | Add surround at cursor | |
| `gc` / `gcc` | n, x, o | Toggle comment | evil-nerd-commenter `gc` |
| `ga` / `gA` | n, x | Align / align with preview | evil-lion `ga` / `gA` |
| `g[` / `g]` | n, x, o | Jump to left / right edge of text object | |
| `K` | n | Hover docs | `K` helpful-at-point |
| `<C-a>` / `<C-x>` | n | Increment / decrement number | `C-c +` / `C-c -` evil-numbers |
| `zg` / `zw` | n | Add / remove spelling word | same (spell-fu) |

## Text objects — `mini.ai`

Prefix with `i` (inside) or `a` (around).

| Object | Selects | Emacs |
|---|---|---|
| `a` | Function argument | evil-args `ia` / `aa` |
| `f` | Function **call** | |
| `b` | Any bracket `( [ {` | |
| `q` | Any quote `" ' \`` | |
| `t` | HTML/XML tag | |
| `?` | Prompts for delimiters | |
| any punctuation | That character on both sides — `i\|` `i/` `i*` `i=` `i$` | the `define-and-bind-quoted-text-object` macro |

`in` / `an` target the **next** object, `il` / `al` the **last**. Counts work: `2i(`.

## LSP

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `g d` | n | Go to definition | `g d` xref-find-definitions |
| `g r` | n | References | `g r` xref-find-references |
| `g I` | n | Go to implementation | |
| `g y` | n | Go to type definition | |
| `g D` | n | Go to declaration | |
| `g K` | n | Signature help | `g K` eldoc-doc-buffer |
| `<C-k>` | i | Signature help | |

## Brackets — jump lists

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `] e` / `[ e` | n | Next / previous diagnostic | `] e` / `[ e` flymake-goto-*-error |
| `] h` / `[ h` | n | Next / previous git hunk | |
| `] H` / `[ H` | n | Last / first git hunk | |
| `] b` / `[ b` | n | Next / previous buffer | |
| `] ]` / `[ [` | n | Next / previous reference | |
| `i h` | o, x | Git hunk text object | |

Neovim also ships `]d`/`[d` diagnostics, `]q`/`[q` quickfix, `]a`/`[a` args — see `:h ]`.

## Editing and windows

| Key | Mode | Action | Emacs |
|---|---|---|---|
| `<C-s>` | n, i, x, s | Save file | `C-x C-s` |
| `jk` | i | Exit insert mode | `jk` general-key-dispatch |
| `<Esc>` | n | Clear search highlight | |
| `<C-h/j/k/l>` | n | Window + tmux pane navigation | same (my/nav-*) |
| `<C-h/j/k/l>` | t | Leave terminal, go to window | |
| `<C-/>` | n, t | Toggle terminal | `SPC A E` eshell |

## Completion — `blink.cmp`

| Key | Mode | Action |
|---|---|---|
| `<C-space>` | i | Show / toggle documentation |
| `<CR>` | i | Accept |
| `<Tab>` / `<S-Tab>` | i | Next / previous item, or jump snippet placeholder |
| `<C-n>` / `<C-p>` | c | Next / previous (command line) |
| `<C-y>` | c | Accept (command line) |

---

## Not mapped, deliberately

| Was | Why | Tracked as |
|---|---|---|
| `H` / `L` argument motions | Kept at vim defaults; never used | D7, F1 |
| Multiple cursors (`evil-mc`) | `gr…` now collides with built-in LSP maps | F2 |
| `vif` / `vaf` filepath object | Not ported | F3 |
| Undo tree UI | `undofile` covers persistence; tree browsing unused | F4 |
| Snippet expansion corpus | No pack installed; blink still reads `~/.config/nvim/snippets` | F5 |
| Trailing-whitespace trim | conform.nvim will cover it in phase 5 | F6 |
| Search/replace UI | Use `<C-q>` → `:cfdo %s/old/new/g \| update` | F7, D10 |
| `SPC h o` vim options | snacks has no equivalent picker | — |
| `SPC x` diagnostics list | Reserved for trouble.nvim | phase 5 |

## Inside a picker

These are snacks.picker defaults and work in both insert and normal mode inside the picker.

| Key | Action |
|---|---|
| `<C-q>` | Send all results to the quickfix list — the wgrep entry point |
| `<C-t>` | Open in a new tab |
| `<C-v>` / `<C-s>` | Open in a vertical / horizontal split |
| `<C-j>` / `<C-k>` | Next / previous item (also `<C-n>` / `<C-p>`) |
| `<C-d>` / `<C-u>` | Scroll the list |
| `<C-f>` / `<C-b>` | Scroll the preview |
| `<Tab>` | Select item and move to the next |
| `<C-a>` | Select all |
| `<C-g>` | Toggle live mode (re-run the search as you type) |
| `?` | Show all picker keymaps |
