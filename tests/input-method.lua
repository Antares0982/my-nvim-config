-- Run using Neovim's -l option.
local available = 0
local calls = 0
local signals = 0
local uis = { {} }
vim.env.TERM = "xterm-256color"
vim.env.SSH_CONNECTION = nil
vim.env.SSH_TTY = nil
vim.api.nvim_list_uis = function()
  return uis
end
vim.api.nvim_ui_send = function(data)
  assert(data == "\027]1337;SetUserVar=nvim_ime=b2Zm\007")
  signals = signals + 1
end
vim.fn.executable = function(command)
  assert(command == "fcitx5-remote")
  return available
end
vim.system = function(command, options)
  assert(vim.deep_equal(command, { "fcitx5-remote", "-c" }))
  assert(options.timeout == 1000)
  calls = calls + 1
end

local function load()
  dofile("lua/config/autocmds.lua")
end

local function change(pattern, expected, sent)
  calls = 0
  signals = 0
  vim.api.nvim_exec_autocmds("ModeChanged", { pattern = pattern })
  assert(calls == expected, pattern .. ": " .. calls)
  assert(signals == (sent or 0), pattern .. " signals: " .. signals)
end

load()
change("i:n", 0)

available = 1
load()
load()
assert(#vim.api.nvim_get_autocmds({ group = "fcitx5_english" }) == 1)

for _, pattern in ipairs({ "i:n", "ic:n", "ix:n", "i:niI" }) do
  change(pattern, 1)
end
for _, pattern in ipairs({ "n:i", "i:ic", "ic:i", "i:ix", "ix:i", "c:n", "t:nt", "R:n" }) do
  change(pattern, 0)
end

for key, expected in pairs({ ["<Esc>"] = 1, ["<C-[>"] = 1, ["<C-C>"] = 1, ["<C-O>h<Esc>"] = 2 }) do
  calls = 0
  local keys = vim.api.nvim_replace_termcodes("ia" .. key, true, false, true)
  vim.api.nvim_feedkeys(keys, "xt", false)
  assert(calls == expected, key .. ": " .. calls)
  assert(vim.fn.mode() == "n")
end

vim.env.SSH_CONNECTION = "remote"
change("i:n", 0)
vim.env.SSH_CONNECTION = nil
vim.env.SSH_TTY = "/dev/pts/1"
change("i:n", 0)
vim.env.SSH_TTY = nil

vim.env.TERM = "xterm-kitty"
change("i:n", 0, 1)
vim.env.SSH_CONNECTION = "remote"
change("i:n", 0, 1)
available = 0
change("i:n", 0, 1)
change("n:i", 0)
change("i:ic", 0)

uis = {}
change("i:n", 0)
vim.env.TERM = "xterm-256color"
vim.env.SSH_CONNECTION = nil
available = 1
change("i:n", 0)

print("Input method checks passed")
