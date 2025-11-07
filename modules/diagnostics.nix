{ lib, ... }:
let
  # Not my idea, but I always wanted it.
  # Found an implementation on reddit: https://www.reddit.com/r/neovim/comments/1jpbc7s/disable_virtual_text_if_there_is_diagnostic_in/
  # Changed it so it works for me, and with lsp-lines.

  inherit (lib.nixvim) mkRaw;
in
{
  plugins.lsp-lines.enable = true;

  diagnostic.settings = {
    virtual_text = true;
    virtual_lines.only_current_line = true;
    update_in_insert = false;
  };

  autoGroups = {
    "diagnostic_only_virtlines" = { };
    "diagnostic_redraw" = { };
  };

  autoCmd = [
    {
      event = [ "CursorMoved" "DiagnosticChanged" ];
      group = "diagnostic_only_virtlines";
      callback = mkRaw ''
        function()
          if og_virt_line == nil then
            og_virt_line = vim.diagnostic.config().virtual_lines
          end

          -- ignore if virtual_lines.only_current_line is disabled
          if not (og_virt_line and og_virt_line.only_current_line) then
            if og_virt_text then
              vim.diagnostic.config({ virtual_text = og_virt_text })
              og_virt_text = nil
            end
            return
          end

          if og_virt_text == nil then
            og_virt_text = vim.diagnostic.config().virtual_text
          end

          local lnum = vim.api.nvim_win_get_cursor(0)[1] - 1

          if vim.tbl_isempty(vim.diagnostic.get(0, { lnum = lnum })) then
            vim.diagnostic.config({ virtual_text = og_virt_text })
          else
            vim.diagnostic.config({ virtual_text = false })
          end
        end
      '';

    }
    {
      event = [ "ModeChanged" ];
      group = "diagnostic_redraw";
      callback = mkRaw ''
        function()
          pcall(vim.diagnostic.show)
        end
      '';
    }
  ];
}
