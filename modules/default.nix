{ pkgs, lib, ... }:
let
  inherit (lib.nixvim) listToUnkeyedAttrs mkRaw;
in
{
  imports = [
    ./fzf-lua.nix
    ./git.nix
    ./lsp.nix
  ];

  config = {
    colorschemes.gruvbox.enable = true;

    globals = {
      mapleader = " ";
      maplocalleader = ",";
    };

    opts = {
      tabstop = 2;
      shiftwidth = 2;
      expandtab = true;
      mouse = "a";
    };

    plugins.notify.enable = true;
    plugins.lualine.enable = true;

    plugins.treesitter = {
      enable = true;
      settings = {
        incremental_selection = {
          enable = true;
          keymaps = {
            init_selection = "gnn";
            node_incremental = "n";
            node_decremental = "N";
            scope_incremental = "grc";
          };
        };
        folding.enable = true;
        highlight.enable = true;
        indent.enable = true;
      };
    };

    plugins.markdown-preview.enable = true;
    plugins.vim-surround.enable = true;
    plugins.which-key = {
      enable = true;
      settings.spec = [
        (listToUnkeyedAttrs [ "<leader>c" ] // { group = "Code"; })
        (listToUnkeyedAttrs [ "<leader>f" ] // { group = "Find"; })
        (listToUnkeyedAttrs [ "<leader>y" ] // { group = "Toggle"; })
      ];
    };

    plugins.indent-blankline = {
      enable = true;
      settings.scope.enabled = false;
    };

    plugins.mini = {
      enable = true;
      modules = {
        ai = { };
        comment = { };
        cursorword = { };
        trailspace = { };
        jump2d = {
          mappings.start_jumping = "<Leader><Leader>";
        };
      };
    };

    userCommands."Trim" = {
      command = mkRaw ''
        function()
          MiniTrailspace.trim_last_lines()
          MiniTrailspace.trim()
        end
      '';
    };

    plugins.oil.enable = true;
    keymaps = [{
      key = "-";
      options.desc = "Open oil in the cwd";
      action = "<cmd>Oil<cr>";
    }];

    plugins.friendly-snippets.enable = true;
    plugins.blink-cmp = {
      enable = true;
      settings = {
        keymap.preset = "enter";
      };
    };

    extraPlugins = builtins.attrValues {
      inherit (pkgs.vimPlugins)
        vim-abolish
        vim-characterize
        vim-eunuch
        vim-polyglot
        vim-repeat
        vim-rsi
        vim-unimpaired
        ;
    };
  };
}
