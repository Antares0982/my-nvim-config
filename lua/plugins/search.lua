local exclude = {}
for _, dir in ipairs({
  ".git",
  "__pycache__",
  ".mypy_cache",
  ".ruff_cache",
  ".pytest_cache",
  ".hypothesis",
  ".pytype",
  ".tox",
  ".nox",
  ".venv",
  "venv",
  "*.egg-info",
  "target",
  "CMakeFiles",
  ".ccache",
  ".cache/clangd",
}) do
  vim.list_extend(exclude, { "**/" .. dir, "**/" .. dir .. "/**" })
end

local rg_args = { "--no-config", "--hidden", "--no-ignore", "--no-text", "--no-binary" }
for _, glob in ipairs(exclude) do
  rg_args[#rg_args + 1] = "--glob=!" .. glob
end

local files = {
  hidden = true,
  ignored = true,
  cmd = "rg",
  -- Include empty files; reject NUL-containing files.
  args = { "--no-config", "--files-without-match", "--text", "--regexp", "\\x00" },
}

local excluded
local function filter_path(item)
  excluded = excluded or Snacks.picker.util.globber(exclude)
  local path = item.file and Snacks.picker.util.path(item)
  return not path or not excluded("/" .. path)
end

return {
  {
    "folke/snacks.nvim",
    init = function()
      vim.opt.grepprg =
        table.concat(vim.tbl_map(vim.fn.shellescape, vim.list_extend({ "rg", "--vimgrep" }, rg_args)), " ")
      vim.opt.grepformat = "%f:%l:%c:%m"
    end,
    opts = {
      picker = {
        hidden = true,
        ignored = true,
        exclude = exclude,
        sources = {
          files = files,
          git_files = vim.tbl_extend("force", files, {
            finder = "files",
            config = function(opts)
              opts.cwd = opts.cwd or Snacks.git.get_root()
            end,
          }),
          recent = { filter = { filter = filter_path } },
          buffers = { filter = { filter = filter_path } },
          smart = vim.tbl_extend("force", files, { filter = { filter = filter_path } }),
          grep = { args = rg_args },
          grep_word = { args = rg_args },
          grep_buffers = { args = rg_args, filter = { filter = filter_path } },
          git_grep = { finder = "grep", args = rg_args },
          todo_comments = { args = rg_args },
        },
      },
    },
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
  {
    "MagicDuck/grug-far.nvim",
    opts = { engines = { ripgrep = { extraArgs = table.concat(rg_args, " ") } } },
  },
  {
    "folke/todo-comments.nvim",
    opts = function(_, opts)
      opts.search = opts.search or {}
      opts.search.args = vim.list_extend({
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
      }, rg_args)
    end,
  },
}
