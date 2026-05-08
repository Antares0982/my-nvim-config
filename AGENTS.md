# AGENTS.md

This is a **Neovim configuration repo** (not a software project). There is no `npm`, `make`, or `cargo` here.

**Important:** This directory is symlinked to `~/.config/nvim/`. Always read/write files here directly — do NOT navigate to `~/.config/nvim/` to read files, as they are the same files.

**Important:** If you need to read anything under `~/.local/share/nvim/`, first check whether `./local-share-nvim` already points there (it should be a symlink). If it doesn't exist, create it with `ln -s ~/.local/share/nvim local-share-nvim`, then read through the symlink.

## Architecture

- Entrypoint: `init.lua` → `require("config.lazy")` → `lua/config/lazy.lua`
- `lazy.lua` bootstraps lazy.nvim, then loads two spec imports:
  1. `"LazyVim/LazyVim"` → imports `lazyvim.plugins` (LazyVim's full curated plugin set)
  2. `"plugins"` → imports all `*.lua` files from `lua/plugins/` as overrides/additions
- LazyVim auto-loads `lua/config/options.lua`, `keymaps.lua`, and `autocmds.lua` on startup — these are currently stubs.

## User plugins directory (`lua/plugins/`)

- File naming: each `.lua` file is a plugin spec. Return a table or function. No manual `require()` needed.
- **`example.lua` is dead code** — returns `{}` at line 3. Do not edit it; it's a tutorial reference.
- **`no-mason.lua`** — disables mason.nvim. The user expects **system-installed** LSP servers, linters, and formatters (no install-on-the-fly inside Neovim).
- **`lsp.lua`** — adds `clangd` and `basedpyright` to nvim-lspconfig. LazyVim handles the `setup()` call.

## No build/test/lint commands

There is no CI, no Makefile, no package.json. Do not run `npm test` or `make lint`. This repo is deployed into `~/.config/nvim/` and used at Neovim runtime.

## Formatting

One command worth knowing:

```bash
stylua .
```

`stylua.toml` configures it (2-space indent, 120 col width). `conform.nvim` uses this inside Neovim too.

## Lazy-lock.json

Pins 32 plugins to exact commits for reproducibility. Updated automatically by lazy.nvim sync (`:Lazy sync` or `:Lazy restore`). Do not hand-edit.

## Key constraint

Mason is disabled. If an agent adds LSP/formatter/linter plugin configs, they must NOT rely on Mason auto-install — users provide the binaries themselves.
