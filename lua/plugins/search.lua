return {
  {
    "folke/snacks.nvim",
    keys = {
      {
        "<leader>ss",
        function()
          local visual = require("snacks.picker.util").visual()
          if visual then
            Snacks.picker.grep({ search = visual.text, regex = false })
          end
        end,
        mode = "x",
        desc = "Grep visual selection (literal, no word boundary)",
      },
    },
  },
}
