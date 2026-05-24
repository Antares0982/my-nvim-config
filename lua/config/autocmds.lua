-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Pre-register LSP server configs.
-- Needed because Neovim 0.12's built-in :lsp command causes nvim-lspconfig
-- to skip its own init, so default configs (cmd, filetypes, etc.) are
-- never registered. Without these, vim.lsp.enable() has nothing to launch.
vim.lsp.config("pyright", {
  cmd = { "pyright-langserver", "--stdio" },
  filetypes = { "python" },
  root_markers = { "pyproject.toml", "pyrightconfig.json", "setup.py", "setup.cfg", "requirements.txt", "Pipfile", ".git" },
  single_file_support = true,
  settings = {
    python = {
      analysis = { autoSearchPaths = true, diagnosticMode = "openFilesOnly" },
    },
  },
})

vim.lsp.config("clangd", {
  cmd = {
    "clangd",
    "--background-index",
    "--clang-tidy",
    "--header-insertion=never",
    "--completion-style=detailed",
    "--function-arg-placeholders",
    "--fallback-style=llvm",
  },
  filetypes = { "c", "cpp", "cuda", "objc", "objcpp" },
  root_markers = { ".git", "compile_commands.json", "compile_flags.txt" },
})

-- Enable LSP servers on FileType. Idempotent — safe to call even if
-- LazyVim's own config also calls vim.lsp.enable() later.
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "python", "c", "cpp", "cuda", "objc", "objcpp" },
  callback = function(args)
    local servers = {
      python = "pyright",
      c = "clangd",
      cpp = "clangd",
      cuda = "clangd",
      objc = "clangd",
      objcpp = "clangd",
    }
    local server = servers[vim.bo[args.buf].filetype]
    if server then
      vim.lsp.enable(server)
    end
  end,
})
