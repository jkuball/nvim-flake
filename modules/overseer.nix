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

  extraConfigLua = ''
    local function find_flake()
      local flake = vim.fs.find("flake.nix", { upward = true, type = "file" })[1]
      if flake then
        return vim.fs.dirname(flake)
      end
      return nil
    end

    local overseer = require("overseer")

    -- Static tasks
    overseer.register_template({
      name = "nix fmt",
      builder = function()
        local cwd = find_flake()
        return {
          cmd = { "nix", "fmt" },
          cwd = cwd,
        }
      end,
      condition = {
        callback = function()
          return find_flake() ~= nil
        end,
      },
    })

    overseer.register_template({
      name = "nix flake check",
      builder = function()
        local cwd = find_flake()
        return {
          cmd = { "nix", "flake", "check" },
          cwd = cwd,
        }
      end,
      condition = {
        callback = function()
          return find_flake() ~= nil
        end,
      },
    })

    -- Dynamic tasks from nix flake show
    overseer.register_template({
      name = "nix flake",
      generator = function(opts, cb)
        local flake_dir = find_flake()
        if not flake_dir then
          return cb({})
        end

        overseer.builtin.system(
          { "nix", "flake", "show", "--json" },
          { cwd = flake_dir, text = true },
          vim.schedule_wrap(function(out)
            if out.code ~= 0 then
              return cb({})
            end

            local ok, data = pcall(vim.json.decode, out.stdout)
            if not ok then
              return cb({})
            end

            local tasks = {}

            -- Helper to get current system
            local system = vim.fn.system("nix eval --raw --impure --expr builtins.currentSystem"):gsub("%s+$", "")

            local packages = data.packages and data.packages[system] or {}
            local apps = data.apps and data.apps[system] or {}

            -- Extract packages (build tasks)
            for name, _ in pairs(packages) do
              table.insert(tasks, {
                name = string.format("nix build .#%s", name),
                builder = function()
                  return {
                    cmd = { "nix", "build", ".#" .. name },
                    cwd = flake_dir,
                  }
                end,
              })
            end

            -- Extract run tasks: apps take priority, fallback to packages
            for name, _ in pairs(apps) do
              table.insert(tasks, {
                name = string.format("nix run .#%s", name),
                builder = function()
                  return {
                    cmd = { "nix", "run", ".#" .. name },
                    cwd = flake_dir,
                  }
                end,
              })
            end

            -- Add nix run for packages that don't have a corresponding app
            for name, _ in pairs(packages) do
              if not apps[name] then
                table.insert(tasks, {
                  name = string.format("nix run .#%s", name),
                  builder = function()
                    return {
                      cmd = { "nix", "run", ".#" .. name },
                      cwd = flake_dir,
                    }
                  end,
                })
              end
            end

            cb(tasks)
          end)
        )
      end,
      condition = {
        callback = function()
          return find_flake() ~= nil
        end,
      },
    })
  '';

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
