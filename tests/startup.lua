-- Run using Neovim's -l option.
local filereadable = vim.fn.filereadable
for _, available in ipairs({ 0, 1 }) do
  vim.fn.filereadable = function(path)
    assert(path == "/etc/NIXOS")
    return available
  end
  local specs = dofile("lua/plugins/no-mason.lua")
  if available == 0 then
    assert(next(specs) == nil, "Mason must keep its defaults outside NixOS")
  else
    assert(#specs == 3)
    for i, name in ipairs({
      "mason-org/mason.nvim",
      "mason-org/mason-lspconfig.nvim",
      "WhoIsSethDaniel/mason-tool-installer.nvim",
    }) do
      assert(specs[i][1] == name and specs[i].enabled == false, name)
    end
  end
end
vim.fn.filereadable = filereadable

vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/snacks.nvim")
require("snacks").setup(dofile("lua/plugins/snacks.lua")[1].opts)
local opened = 0
Snacks.picker.explorer = function()
  opened = opened + 1
end
for _, path in ipairs({ "", "init.lua", vim.fn.getcwd(), vim.fn.getcwd() }) do
  vim.api.nvim_exec_autocmds("BufEnter", { pattern = path })
  assert(opened == 0, "Explorer opened automatically: " .. path)
end
Snacks.explorer()
assert(opened == 1, "Explorer must still open manually")

print("Startup checks passed")
