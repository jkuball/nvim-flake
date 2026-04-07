# @ts: { pkgs: Nixpkgs; lib: NixvimLib; [key: string]: any }
{ pkgs, lib, ... }:
{
  extraConfigLua = ''
    vim.filetype.add({
      pattern = {
        [".*%.nix%.d%.ts"] = "nixts",
      },
    })
    vim.treesitter.language.register("typescript", { "nixts" })

    vim.lsp.config("typenix", {
      cmd = { "${lib.getExe pkgs.typenix}", "--lsp", "--stdio" },
      root_markers = { "flake.nix", ".git" },
      filetypes = { "nix", "nixts" },
      on_attach = function(client)
        client.server_capabilities.documentFormattingProvider = false
        client.server_capabilities.documentRangeFormattingProvider = false
      end,
    })
    vim.lsp.enable("typenix")
  '';

  extraPackages = [ pkgs.typenix ];
}
