{ pkgs, lib, ... }:
let
  inherit (lib.nixvim) mkRaw;
in
{
  lsp = {
    inlayHints.enable = true;
    servers = {
      helm_ls.enable = true;
      jsonls.enable = true;
      nil_ls = {
        enable = true;
        config.settings."nil" = {
          formatting.command = [ (lib.getExe pkgs.nixpkgs-fmt) ];
          diagnostics.excludedFiles = [ "generated.nix" ];
        };
      };
      pyright.enable = true;
      ruff.enable = true;
      yamlls.enable = true;
    };
  };

  plugins.fidget.enable = true;
  plugins.lsp-format.enable = true;
  plugins.lsp.enable = true;

  keymaps = [
    # for lsp-format
    {
      key = "<Leader>yf";
      options.desc = "Toggle format-on-save";
      action = "<cmd>FormatToggle<cr>";
    }
    # for lsp-lines
    {
      key = "<Leader>yd";
      options.desc = "Toggle virtual lines for lsp annotations";
      action = mkRaw ''require("lsp_lines").toggle'';
    }
  ];

  # :h lsp-defaults
  lsp.keymaps = [
    {
      key = "gra";
      action = "<cmd>FzfLua lsp_code_actions jump1=true<cr>";
    }
    {
      key = "grr";
      action = "<cmd>FzfLua lsp_references jump1=true<cr>";
    }
    {
      key = "gri";
      action = "<cmd>FzfLua lsp_implementations jump1=true<cr>";
    }
    {
      key = "grt";
      action = "<cmd>FzfLua lsp_typedefs jump1=true<cr>";
    }
    {
      key = "gO";
      action = "<cmd>FzfLua lsp_document_symbols<cr>";
    }
    {
      key = "gd";
      action = "<cmd>FzfLua lsp_definitions jump1=true<cr>";
    }
    {
      key = "<Leader>ca";
      action = "<cmd>FzfLua lsp_code_actions jump1=true<cr>";
    }
  ];
}
