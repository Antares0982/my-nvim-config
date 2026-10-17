# 仓库维护指南

本仓库是基于 LazyVim 的 Neovim 配置，当前设备为 NixOS。
`~/.config/nvim/` 已软链接到本目录 `/home/antares/Documents/GitHub/my-nvim-config`，修改这里会直接影响实际使用的 Neovim 配置，无需复制或重新建立链接。

## 配置结构

- `init.lua` → `lua/config/lazy.lua`：启动 lazy.nvim，加载 LazyVim、Overseer 扩展及本地插件配置。
- `lua/config/`：编辑器选项、自动命令和通用快捷键。
- `lua/plugins/`：插件声明与覆盖配置；`example.lua` 提前返回空表，不启用其中示例。
- `lazyvim.json`：启用的语言扩展；`lazy-lock.json`：插件版本锁定。
- `tests/`：可通过 Neovim 独立运行的 Lua 回归检查。
- `FEATURES.md`：功能与代码位置的对应表，维护前先查阅。

## 修改原则

- 先阅读相关配置并追踪调用方；修复根因，复用已有实现，优先最小修改，不添加推测性功能或抽象。
- Lua 使用两空格缩进，遵循 `stylua.toml` 的 120 列配置；新增注释块不超过 7 个词，函数名不超过 4 个词。
- Mason 已禁用，语言服务器、调试器等外部工具由系统或开发环境提供，不擅自恢复 Mason 安装流程。
- 临时工具可用 `nix shell nixpkgs#<pkg>` 或 `nix run nixpkgs#<pkg>`，禁止使用 `nix-env` 安装。
- `flake.nix` 的开发环境提供 StyLua 和 Python；不要将它描述为完整的语言服务器或调试器安装配置。
- 不直接修改插件安装目录；除非任务涉及依赖更新，不顺带更新锁文件。

## 验证

在仓库根目录运行与改动相关的检查，完成后报告结果；未能执行时说明原因。

```sh
stylua --check init.lua lua tests
nvim --headless -u NONE -l tests/input-method.lua
nvim --headless -u NONE -l tests/search.lua
git diff --check
```

输入法检查覆盖模式切换、本地 fcitx5、Kitty 信号及 SSH/无界面分支。搜索检查需要 PATH 中的 `rg` 和 Neovim 数据目录中已安装的 `snacks.nvim`、`grug-far.nvim`。
新增非平凡逻辑时，补充或扩展最小可运行检查；纯文档修改核对内容、文件路径与表格结构即可。

## 功能文档同步

**每次维护后都必须检查并同步维护 `FEATURES.md`，始终以 Markdown 表格列出功能，每行包含“功能概述、代码文件位置”两列。**

- 新增、变更或删除功能时，同步新增、更新或移除对应行；移动文件时更新路径。
- 功能概述说明实际行为，必要时写明快捷键、依赖或限制；代码位置使用仓库相对路径链接。
- 只记录已生效的本地配置或明确启用的扩展，不把未启用的示例写成现有功能。
- 若维护不改变功能或位置，仍需核对表格，确认准确后无需制造无意义改动。
