# 功能清单

`~/.config/nvim/` 已软链接到本仓库，修改本目录即修改实际使用的 Neovim 配置。
下表记录本仓库的定制和明确启用的扩展；LazyVim 默认功能由上游提供，不逐项展开。每次维护后同步核对并更新此表。

| 功能概述 | 代码文件位置 |
| --- | --- |
| 启动 lazy.nvim 与 LazyVim，导入本地插件配置；缺少 lazy.nvim 时自动克隆，定期检查插件更新但不弹出通知 | [init.lua](init.lua)、[lua/config/lazy.lua](lua/config/lazy.lua)、[lazy-lock.json](lazy-lock.json) |
| 编辑器启用自动折行；终端命令优先使用 zsh，不可用时使用 bash | [lua/config/options.lua](lua/config/options.lua) |
| 离开插入模式时请求关闭输入法：Kitty 发送 `nvim_ime=off` 用户变量信号，由终端侧配合处理；其他本地终端调用 `fcitx5-remote -c`，SSH 中跳过该本地调用，无界面时跳过处理 | [lua/config/autocmds.lua](lua/config/autocmds.lua)、[tests/input-method.lua](tests/input-method.lua) |
| 启用 C/C++（clangd）、JSON、Nix、Python、Rust、TOML 的 LazyVim 语言扩展 | [lazyvim.json](lazyvim.json) |
| 配置 clangd 后台索引、clang-tidy、详细补全等选项，以及 Python 的 Pyright；提前注册并按文件类型启用服务器，兼容 Neovim 0.12 的 LSP 加载行为 | [lua/plugins/lsp.lua](lua/plugins/lsp.lua)、[lua/config/autocmds.lua](lua/config/autocmds.lua) |
| 禁用 Mason、Mason LSP 集成与工具自动安装器，外部工具由系统或开发环境提供 | [lua/plugins/no-mason.lua](lua/plugins/no-mason.lua) |
| Blink 补全中回车执行默认回退行为，Tab 使用 `super-tab` 预设映射 | [lua/plugins/blink.lua](lua/plugins/blink.lua) |
| Snacks 文件浏览器显示隐藏文件与被忽略文件，并沿用共享排除规则 | [lua/plugins/snacks.lua](lua/plugins/snacks.lua)、[lua/plugins/search.lua](lua/plugins/search.lua) |
| 文件与内容搜索包含隐藏文件和被忽略文件，统一排除 Git 元数据、Python 缓存/虚拟环境、Rust target、CMakeFiles 等目录；文件搜索保留空文件并排除含 NUL 的文件 | [lua/plugins/search.lua](lua/plugins/search.lua)、[tests/search.lua](tests/search.lua) |
| 最近文件、缓冲区及智能选择器复用路径排除规则；Git 文件选择器使用文件查找器，默认从 Git 根目录搜索 | [lua/plugins/search.lua](lua/plugins/search.lua)、[tests/search.lua](tests/search.lua) |
| Grep 与单词搜索优先排列整词匹配，按每条结果的首个匹配判断边界 | [lua/plugins/search.lua](lua/plugins/search.lua)、[tests/search.lua](tests/search.lua) |
| 可视模式下 `<leader>ss` 按选中文本进行字面量搜索，不启用正则或强制单词边界 | [lua/plugins/search.lua](lua/plugins/search.lua) |
| `:grep`、Grug Far 搜索替换及 TODO 搜索共享 ripgrep 参数与排除规则 | [lua/plugins/search.lua](lua/plugins/search.lua)、[tests/search.lua](tests/search.lua) |
| Diffview 查看工作区差异（`<leader>gd`）、指定版本差异（`<leader>gD`）、当前文件历史（`<leader>gf`）和仓库历史（`<leader>gF`）；`<leader>gq` 关闭，差异视图禁用诊断显示 | [lua/plugins/diffview.lua](lua/plugins/diffview.lua) |
| 加载 Overseer 任务运行扩展，本地覆盖文件目前为空 | [lua/config/lazy.lua](lua/config/lazy.lua)、[lua/plugins/overseer.lua](lua/plugins/overseer.lua) |
| 配置 Python DAP、GDB 的 `cppdbg` 适配器及 C/C++ LLDB 启动配置；运行需相应 Python/debugpy、GDB（支持 DAP）或 LLDB 可执行程序 | [lua/plugins/dap.lua](lua/plugins/dap.lua) |
| 调试会话自动打开/关闭 DAP UI，并启用变量虚拟文本；`<leader>du` 切换界面，`<leader>dr` 打开 REPL | [lua/plugins/dap.lua](lua/plugins/dap.lua) |
| 调试断点与单步：`<leader>dB` 切换断点，F5 继续，F10/F11/F12 分别单步跳过、进入、退出 | [lua/plugins/dap.lua](lua/plugins/dap.lua) |
| 指令级调试：`<leader>dg` 切换语句/指令粒度，Shift+F10/F11/F12 执行指令级单步；需调试适配器支持 | [lua/plugins/dap.lua](lua/plugins/dap.lua) |
| 反汇编浮窗显示当前指令附近内容并标记指令位置，停止时自动刷新；`<leader>da` 切换、`<leader>dq` 关闭，需适配器支持反汇编 | [lua/plugins/dap.lua](lua/plugins/dap.lua) |
| DAP 兼容处理：将 VS Code 风格 `environment` 数组转换为 `env` 对象，并在 Python 适配器可用时注册 `debugpy` 别名 | [lua/plugins/dap.lua](lua/plugins/dap.lua) |
| Nix 开发环境提供 StyLua 与 Python 3.14，声明支持 x86_64-linux、aarch64-linux、aarch64-darwin；Lua 格式配置为两空格缩进、120 列 | [flake.nix](flake.nix)、[stylua.toml](stylua.toml) |
| 项目级 Neoconf 配置启用 Neodev 库/插件信息及 Lua LSP 集成 | [.neoconf.json](.neoconf.json) |
| OpenCode 项目权限允许访问 `~/.local/share/nvim/**` 外部目录 | [opencode.json](opencode.json) |

`lua/plugins/example.lua` 是未启用的示例，`lua/config/keymaps.lua` 暂无自定义映射；实际快捷键主要定义在对应插件文件中。
