return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts.keymap["<CR>"] = { "fallback" }
    opts.keymap["<Tab>"] = require("blink.cmp.keymap.presets").get("super-tab")["<Tab>"]
  end,
}
