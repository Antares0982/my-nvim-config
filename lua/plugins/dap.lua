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

      -- C/C++ debug adapter (requires lldb-dap or lldb-vscode on PATH)
      local lldb_dap = vim.fn.exepath("lldb-dap") or vim.fn.exepath("lldb-vscode")
      if lldb_dap then
        dap.adapters.c = {
          type = "executable",
          command = lldb_dap,
          name = "lldb",
        }
        dap.adapters.cpp = dap.adapters.c

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
    end,
    keys = {
      { "<leader>dB", function() require("dap").toggle_breakpoint() end, desc = "Toggle Breakpoint" },
      { "<F5>", function() require("dap").continue() end, desc = "Continue" },
      { "<F10>", function() require("dap").step_over() end, desc = "Step Over" },
      { "<F11>", function() require("dap").step_into() end, desc = "Step Into" },
      { "<F12>", function() require("dap").step_out() end, desc = "Step Out" },
      { "<leader>dr", function() require("dap").repl.open() end, desc = "Open REPL" },
      { "<leader>du", function() require("dapui").toggle() end, desc = "Toggle DAP UI" },
    },
  },
}
