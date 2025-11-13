{ lib, ... }:
let
  inherit (lib.nixvim) mkRaw listToUnkeyedAttrs;
in
{
  plugins = {
    harpoon.enable = true;
    which-key.settings.spec = [
      (listToUnkeyedAttrs [ "<leader>h" ] // { group = "Harpoon"; })
      (listToUnkeyedAttrs [ "<Leader>#" ] // { desc = "Go to Harpooned File (1-9)"; })
    ];
  };

  keymaps = [
    {
      key = "<Leader>hh";
      action = mkRaw ''
        function()
          local harpoon = require("harpoon")
          harpoon.ui:toggle_quick_menu(harpoon:list())
        end
      '';
      options.desc = "Toggle Harpoon UI";
    }
    {
      key = "<Leader>ha";
      action = mkRaw ''
        function()
          local harpoon = require("harpoon")
          harpoon:list():add()
        end
      '';
      options.desc = "Pin current position";
    }
    {
      key = "<Leader>hA";
      action = mkRaw ''
        function()
          local harpoon = require("harpoon")
          harpoon:list():clear()
          harpoon:list():add()
        end
      '';
      options.desc = "Pin ONLY current position";
    }
    {
      key = "<Leader>hc";
      action = mkRaw ''
        function()
          local harpoon = require("harpoon")
          harpoon:list():clear()
        end
      '';
      options.desc = "Clear harpoon list";
    }
    {
      key = "]h";
      action = mkRaw ''
        function()
          local harpoon = require("harpoon")
          harpoon:list():next({ui_nav_wrap=true})
        end
      '';
      options.desc = "Next Harpooned File (wrapping)";
    }
    {
      key = "]h";
      action = mkRaw ''
        function()
          local harpoon = require("harpoon")
          harpoon:list():prev({ui_nav_wrap=true})
        end
      '';
      options.desc = "Previous Harpooned File (wrapping)";
    }
  ] ++ (builtins.genList
    (i: {
      key = "<Leader>${toString(i+1)}";
      action = mkRaw ''
        function()
          local harpoon = require("harpoon")
          harpoon:list():select(${toString (i+1)})
        end
      '';
      options.desc = "which_key_ignore";
    }) 9);
}
