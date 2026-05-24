return {
  {
    "neovim/nvim-lspconfig",
    -- Must be non-lazy in Neovim 0.12 otherwise LSP configs (cmd, filetypes)
    -- from nvim-lspconfig are never registered, causing "cmd: expected table, got nil"
    -- https://github.com/neovim/nvim-lspconfig/issues/4388
    lazy = false,
    opts = {
      servers = {
        clangd = {
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=never",
            "--completion-style=detailed",
            "--function-arg-placeholders",
            "--fallback-style=llvm",
          },
        },
        pyright = {
          cmd = { "pyright-langserver", "--stdio" },
          filetypes = { "python" },
        },
      },
    },
  },
}
