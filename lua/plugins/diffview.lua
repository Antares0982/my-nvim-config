return {
  {
    "folke/snacks.nvim",
    keys = {
      { "<leader>gd", false },
      { "<leader>gD", false },
    },
  },
  {
    "sindrets/diffview.nvim",
    opts = {
      view = {
        default = {
          disable_diagnostics = true,
        },
        merge_tool = {
          disable_diagnostics = true,
        },
        file_history = {
          disable_diagnostics = true,
        },
      },
    },
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diffview" },
      {
        "<leader>gD",
        function()
          vim.api.nvim_feedkeys(":DiffviewOpen ", "n", false)
        end,
        desc = "Diffview (specify rev)",
      },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File History (current file)" },
      { "<leader>gF", "<cmd>DiffviewFileHistory<cr>", desc = "File History (repo)" },
      { "<leader>gq", "<cmd>DiffviewClose<cr>", desc = "Close Diffview" },
    },
    cmd = {
      "DiffviewOpen",
      "DiffviewClose",
      "DiffviewToggleFiles",
      "DiffviewFocusFiles",
      "DiffviewRefresh",
      "DiffviewFileHistory",
    },
  },
}
