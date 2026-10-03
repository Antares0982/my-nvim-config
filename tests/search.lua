-- Run using Neovim's -l option.
local plugins = vim.fn.stdpath("data") .. "/lazy/"
vim.opt.rtp:prepend(plugins .. "snacks.nvim")
vim.opt.rtp:prepend(plugins .. "grug-far.nvim")
local specs = dofile("lua/plugins/search.lua")
require("snacks").setup(vim.tbl_deep_extend("force", dofile("lua/plugins/snacks.lua")[1].opts, specs[1].opts))

local root = vim.fn.tempname()
local function write(path, data)
  path = root .. "/" .. path
  vim.fn.mkdir(vim.fs.dirname(path), "p")
  local file = assert(io.open(path, "wb"))
  file:write(data)
  file:close()
end

local function run(args)
  local result = vim.system(vim.list_extend({ "rg" }, args), { cwd = root, text = true }):wait()
  assert(result.code <= 1, result.stderr)
  return result.stdout
end

local ok, err = xpcall(function()
  local kept = { "src/main.cpp", ".hidden.py", "ignored.rs", "README", "中文 name.txt", "build-debug/keep.c" }
  local skipped = {
    ".git/config",
    "pkg/.git/config",
    "pkg/__pycache__/a.pyc",
    ".mypy_cache/a",
    ".ruff_cache/a",
    ".pytest_cache/a",
    ".venv/a",
    "venv/a",
    ".tox/a",
    ".nox/a",
    ".hypothesis/a",
    ".pytype/a",
    "pkg/a.egg-info/a",
    "target/debug/a",
    "target/release/a",
    "pkg/target/aarch64/debug/a",
    "target/custom/a",
    "build/CMakeFiles/a",
    "pkg/build-debug/CMakeFiles/a",
    "cmake-build-debug/CMakeFiles/a",
    ".ccache/a",
    "pkg/.cache/clangd/a",
  }
  for _, path in ipairs(vim.list_extend(vim.deepcopy(kept), skipped)) do
    write(path, "needle\n")
  end
  write(".gitignore", "ignored.rs\n")
  write("empty", "")
  write("binary", "\0needle\n")
  write("late-binary", string.rep("x", 100000) .. "\0")

  local captured
  require("snacks.picker.source.proc").proc = function(opts)
    captured = opts
  end
  for _, source in ipairs({ "files", "git_files", "grep", "grep_word", "grep_buffers", "git_grep" }) do
    local opts = Snacks.picker.config.get({ source = source, cwd = root })
    assert(opts.hidden and opts.ignored, source)
    local ctx = {
      filter = { search = source:find("grep") and "needle" or "" },
      opts = function(_, extra)
        return vim.tbl_extend("force", opts, extra)
      end,
    }
    Snacks.picker.config.finder(opts.finder)(opts, ctx)
    assert(captured.cmd == "rg", source)
    local output = run(captured.args)
    for _, path in ipairs(kept) do
      assert(output:find(path, 1, true), source .. " missed " .. path)
    end
    for _, path in ipairs(skipped) do
      assert(not output:find(path, 1, true), source .. " included " .. path)
    end
    assert(not output:find("binary", 1, true), source .. " included binary")
    if not source:find("grep") then
      assert(output:find("empty", 1, true), source .. " missed empty file")
    end
  end

  local tree = require("snacks.explorer.tree")
  local explorer = tree:filter(Snacks.picker.config.get({ source = "explorer" }))
  local recent = Snacks.picker.config.get({ source = "recent" }).filter.filter
  for _, path in ipairs(skipped) do
    assert(not explorer({ path = root .. "/" .. path }), path)
    assert(not recent({ file = path, cwd = root }), path)
  end
  assert(explorer({ path = root .. "/.hidden.py", hidden = true, ignored = true }))
  assert(recent({ file = "build-debug/keep.c", cwd = root }))

  local options = vim.tbl_deep_extend("force", require("grug-far.opts").defaultOptions, specs[2].opts)
  local args = require("grug-far.engine.ripgrep.getArgs")({
    search = "needle",
    replacement = "",
    flags = "",
    filesFilter = "",
    paths = "",
  }, options, { "--files-with-matches" })
  local output = run(args)
  assert(output:find("ignored.rs", 1, true) and output:find(".hidden.py", 1, true))
  for _, path in ipairs(skipped) do
    assert(not output:find(path, 1, true), "grug-far included " .. path)
  end
  assert(not output:find("binary", 1, true))

  local todo = {}
  specs[3].opts(nil, todo)
  output = run(vim.list_extend(todo.search.args, { "needle" }))
  assert(output:find("ignored.rs", 1, true) and output:find(".hidden.py", 1, true))
  for _, path in ipairs(skipped) do
    assert(not output:find(path, 1, true), "todo included " .. path)
  end

  specs[1].init()
  local cwd = vim.fn.getcwd()
  vim.api.nvim_set_current_dir(root)
  vim.cmd("silent grep! needle")
  vim.api.nvim_set_current_dir(cwd)
  local matches = vim.fn.getqflist()
  assert(#matches == #kept, ":grep returned unexpected files")
  for _, match in ipairs(matches) do
    assert(vim.tbl_contains(kept, vim.api.nvim_buf_get_name(match.bufnr):sub(#root + 2)))
  end
end, debug.traceback)
vim.fn.delete(root, "rf")
assert(ok, err)
print("Search checks passed")
