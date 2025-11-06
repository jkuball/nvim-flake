{ lib, ... }:
let
  inherit (lib.nixvim) listToUnkeyedAttrs;
in
{
  plugins = {
    which-key.settings.spec = [
      (listToUnkeyedAttrs [ "<leader>g" ] // { group = "Git"; })
    ];

    fugitive.enable = true;
    gitsigns = {
      enable = true;
      settings = {
        current_line_blame = true;
        numhl = true;
      };
    };
  };

  keymaps = [
    {
      key = "<Leader>gg";
      options.desc = "Open fugitive in new tab";
      action = "<cmd>tab Git | only<cr>";
    }
  ];
}
