return {
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      {
        "rcarriga/nvim-dap-ui",
        dependencies = { "nvim-neotest/nvim-nio" },
        opts = {},
      },
      {
        "mfussenegger/nvim-dap-python",
        config = function()
          local python = vim.fn.exepath("python3") or vim.fn.exepath("python") or "python"
          require("dap-python").setup(python)
        end,
      },
      {
        "theHamsta/nvim-dap-virtual-text",
        opts = {},
      },
    },
    config = function()
      local dap = require("dap")
      local dapui = require("dapui")

      -- GDB DAP adapter (for VSCode cppdbg/cppvsdbg type, requires GDB >= 14)
      dap.adapters.cppdbg = {
        type = "executable",
        command = "gdb",
        args = { "-i", "dap" },
      }

      -- C/C++ lldb adapter (optional, requires lldb-dap or lldb-vscode on PATH)
      local lldb_dap = vim.fn.exepath("lldb-dap") or vim.fn.exepath("lldb-vscode")
      if lldb_dap then
        dap.adapters.c = {
          type = "executable",
          command = lldb_dap,
          name = "lldb",
        }
        dap.adapters.cpp = dap.adapters.c
        dap.adapters.lldb = dap.adapters.c
        dap.adapters.codelldb = dap.adapters.c

        dap.configurations.c = {
          {
            name = "Launch (lldb)",
            type = "c",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }
        dap.configurations.cpp = {
          {
            name = "Launch (lldb)",
            type = "cpp",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntry = false,
            args = {},
          },
        }
      end

      -- Alias common VSCode type name for Python
      if dap.adapters.python then
        dap.adapters.debugpy = dap.adapters.python
      end

      -- Translate VSCode environment array format to DAP env object format
      dap.listeners.on_config["vscode_env"] = function(config)
        if config.environment then
          config.env = config.env or {}
          for _, item in ipairs(config.environment) do
            if item.name and item.value then
              config.env[item.name] = item.value
            end
          end
          config.environment = nil
        end
        return config
      end

      -- Auto open/close dap-ui on debug session events
      dap.listeners.after.event_initialized["dapui_config"] = function()
        dapui.open()
      end
      dap.listeners.before.event_terminated["dapui_config"] = function()
        dapui.close()
      end
      dap.listeners.before.event_exited["dapui_config"] = function()
        dapui.close()
      end

      -- Disassembly: show in floating window (or refresh if already open)
      local function disasm_show()
        local s = dap.session()
        if not s or not s.current_frame then
          vim.notify("No active debug session or frame", vim.log.levels.WARN)
          return
        end
        if not s.capabilities.supportsDisassembleRequest then
          vim.notify("Debug adapter does not support disassemble", vim.log.levels.WARN)
          return
        end
        local frame = s.current_frame
        local ref = frame.instructionPointerReference
        if not ref then
          vim.notify("No instruction pointer reference in current frame", vim.log.levels.WARN)
          return
        end

        -- Close previous disasm window if still valid
        local prev_win = package.loaded.dap_disasm_win
        if prev_win and vim.api.nvim_win_is_valid(prev_win) then
          pcall(vim.api.nvim_win_close, prev_win, true)
        end

        s:request("disassemble", { memoryReference = ref, offset = -128, instructionCount = 100 }, function(err, resp)
          if err then
            vim.notify("Disassemble error: " .. vim.inspect(err), vim.log.levels.ERROR)
            return
          end
          local lines = {}
          local ip_line = nil
          for i, inst in ipairs(resp.instructions or {}) do
            local line = string.format("%-20s %s", inst.address, inst.instruction)
            table.insert(lines, line)
            if inst.address == ref then
              ip_line = i
            end
          end
          if #lines == 0 then
            vim.notify("No disassembly instructions returned", vim.log.levels.WARN)
            return
          end
          local buf = vim.api.nvim_create_buf(false, true)
          vim.bo[buf].buftype = "nofile"
          vim.bo[buf].bufhidden = "wipe"
          vim.bo[buf].modifiable = true
          pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          vim.bo[buf].readonly = true
          vim.bo[buf].filetype = "asm"
          if ip_line then
            local ns = vim.api.nvim_create_namespace("dap_disasm")
            vim.api.nvim_buf_set_extmark(buf, ns, ip_line - 1, 0, {
              line_hl_group = "CursorLine",
              hl_mode = "combine",
            })
          end
          local win = vim.api.nvim_open_win(buf, true, {
            relative = "editor",
            width = math.floor(vim.o.columns * 0.6),
            height = math.floor(vim.o.lines * 0.7),
            row = math.floor(vim.o.lines * 0.15),
            col = math.floor(vim.o.columns * 0.2),
            border = "rounded",
            title = "Disassembly",
            title_pos = "center",
          })
          if ip_line then
            pcall(vim.api.nvim_win_set_cursor, win, { ip_line, 0 })
          end
          package.loaded.dap_disasm_win = win
        end)
      end

      -- Refresh-only variant (no notifications, reads current window)
      local function disasm_refresh()
        local s = dap.session()
        if not s or not s.current_frame then
          return
        end
        if not s.capabilities.supportsDisassembleRequest then
          return
        end
        local ref = s.current_frame.instructionPointerReference
        if not ref then
          return
        end
        s:request("disassemble", { memoryReference = ref, offset = -128, instructionCount = 100 }, function(err, resp)
          if err then
            return
          end
          local win = package.loaded.dap_disasm_win
          if not win or not vim.api.nvim_win_is_valid(win) then
            package.loaded.dap_disasm_win = nil
            return
          end
          local buf = vim.api.nvim_win_get_buf(win)
          if not buf or not vim.api.nvim_buf_is_valid(buf) then
            package.loaded.dap_disasm_win = nil
            return
          end
          -- Only operate on our disasm buffer (filetype = "asm", buftype = "nofile")
          if vim.bo[buf].filetype ~= "asm" or vim.bo[buf].buftype ~= "nofile" then
            package.loaded.dap_disasm_win = nil
            return
          end
          local lines = {}
          local ip_line = nil
          for i, inst in ipairs(resp.instructions or {}) do
            local line = string.format("%-20s %s", inst.address, inst.instruction)
            table.insert(lines, line)
            if inst.address == ref then
              ip_line = i
            end
          end
          if #lines == 0 then
            return
          end
          local ns = vim.api.nvim_create_namespace("dap_disasm")
          vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
          if ip_line then
            vim.api.nvim_buf_set_extmark(buf, ns, ip_line - 1, 0, {
              line_hl_group = "CursorLine",
              hl_mode = "combine",
            })
          end
          vim.bo[buf].modifiable = true
          pcall(vim.api.nvim_buf_set_lines, buf, 0, -1, false, lines)
          vim.bo[buf].modifiable = false
          if ip_line then
            pcall(vim.api.nvim_win_set_cursor, win, { ip_line, 0 })
          end
        end)
      end

      -- Store for use in keybindings and listeners
      package.loaded.dap_disasm_show = disasm_show
      package.loaded.dap_disasm_refresh = disasm_refresh

      -- Auto-refresh disassembly window on each stop
      dap.listeners.after.event_stopped["dap_disasm_refresh"] = function()
        vim.schedule(function()
          local f = package.loaded.dap_disasm_refresh
          if f then
            f()
          end
        end)
      end
    end,
    keys = {
      { "<leader>dB", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
      {
        "<leader>dg",
        function()
          local dap = require("dap")
          local current = dap.defaults.fallback.stepping_granularity
          if current == "instruction" then
            dap.defaults.fallback.stepping_granularity = "statement"
          else
            dap.defaults.fallback.stepping_granularity = "instruction"
          end
          vim.notify("Stepping: " .. dap.defaults.fallback.stepping_granularity, vim.log.levels.INFO)
        end,
        desc = "Toggle Stepping Granularity (line/instruction)",
      },
      { "<S-F10>", function() require("dap").step_over({ steppingGranularity = "instruction" }) end, desc = "Step Over (instruction)" },
      { "<S-F11>", function() require("dap").step_into({ steppingGranularity = "instruction" }) end, desc = "Step Into (instruction)" },
      { "<S-F12>", function() require("dap").step_out({ steppingGranularity = "instruction" }) end, desc = "Step Out (instruction)" },
      { "<leader>da", function()
        local win = package.loaded.dap_disasm_win
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
          package.loaded.dap_disasm_win = nil
        else
          package.loaded.dap_disasm_show()
        end
      end, desc = "Toggle Disassembly" },
      { "<leader>dq", function()
        local win = package.loaded.dap_disasm_win
        if win and vim.api.nvim_win_is_valid(win) then
          vim.api.nvim_win_close(win, true)
          package.loaded.dap_disasm_win = nil
        end
      end, desc = "Close Disassembly" },
    },
  },
}
