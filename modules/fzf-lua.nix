{ pkgs, lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
  inherit (lib.nixvim.lua) toLuaObject;
in
{
  plugins.fzf-lua = {
    enable = true;

    luaConfig.post = ''
      require("fzf-lua.providers.ui_select").register()
    '';

    keymaps = {
      "<Leader>fg" = {
        action = "live_grep";
        options.desc = "live grep";
      };
      "<Leader>ff" = {
        action = "files";
        options.desc = "find files";
      };
      "<Leader>fl" = {
        action = "blines";
        options.desc = "buffer lines";
      };
      "<Leader>fh" = {
        action = "oldfiles";
        options.desc = "historic files";
      };
      "<Leader>fb" = {
        action = "buffers";
        options.desc = "find buffers";
      };
    };
  };

  keymaps = [
    {
      key = "<Leader>fs";
      options.desc = "insert gitmoji";
      action =
        let
          src = pkgs.fetchurl {
            url = "https://gitmoji.dev/api/gitmojis";
            hash = "sha256-+bzNCqGOnVkpgvTdpWfcRtVfHQO2pX1/nYgluMA7VYo=";
          };

          gitmojis = map
            ({ emoji, name, description, ... }: "${emoji} | ${name} | ${description}")
            (builtins.fromJSON (builtins.readFile src)).gitmojis;
        in
        mkRaw ''
          function()
            local f = require("fzf-lua")
            local a = require("fzf-lua.actions")
            f.fzf_exec(
              ${toLuaObject gitmojis},
              {
                actions = {
                  ['default'] = function(selected)
                    local emoji = string.match(selected[1], "[^ ]+")
                    vim.api.nvim_paste(emoji, false, -1)
                  end
                }
              }
            )
          end
        '';
    }
  ];
}
