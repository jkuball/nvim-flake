{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw listToUnkeyedAttrs;
in
{
  userCommands = {
    # See https://github.com/stevearc/overseer.nvim/blob/master/doc/recipes.md#restart-last-task
    "OverseerRestartLast" = {
      command = mkRaw ''
        function()
          local overseer = require("overseer")
          local tasks = overseer.list_tasks({ recent_first = true })
          if vim.tbl_isempty(tasks) then
            vim.notify("No previous tasks found. Select a new one.", vim.log.levels.WARN)
            vim.cmd("OverseerRun")
          else
            overseer.run_action(tasks[1], "restart")
          end
        end
      '';
    };
  };

  plugins.which-key.settings.spec = [
    (listToUnkeyedAttrs [ "<leader>o" ] // { group = "Overseer"; })
  ];

  plugins.overseer = {
    enable = true;
  };

  keymaps = [
    {
      key = "<f5>";
      options.desc = "Restart Last";
      action = "<cmd>OverseerRestartLast<cr>";
    }
    {
      key = "<Leader>o<Space>";
      options.desc = "Restart Last";
      action = "<cmd>OverseerRestartLast<cr>";
    }
    {
      key = "<Leader>oo";
      options.desc = "Toggle UI";
      action = "<cmd>OverseerToggle<cr>";
    }
    {
      key = "<Leader>oh";
      options.desc = "Toggle UI (left)";
      action = "<cmd>OverseerToggle left<cr>";
    }
    {
      key = "<Leader>oj";
      options.desc = "Toggle UI (bottom)";
      action = "<cmd>OverseerToggle bottom<cr>";
    }
    {
      key = "<Leader>ol";
      options.desc = "Toggle UI (right)";
      action = "<cmd>OverseerToggle right<cr>";
    }
    {
      key = "<Leader>or";
      options.desc = "Run";
      action = "<cmd>OverseerRun<cr>";
    }
    {
      key = "<Leader>os";
      options.desc = "Shell";
      action = "<cmd>OverseerShell<cr>";
    }
    {
      key = "<Leader>oa";
      options.desc = "Task Action";
      action = "<cmd>OverseerTaskAction<cr>";
    }
  ];
}
