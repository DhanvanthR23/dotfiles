return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- This matches the 'lspconfig.hyprlang.setup' from the GitHub
        hyprls = {
          settings = {
            hyprls = {
              preferIgnoreFile = false,
              ignore = { "hyprlock.conf", "hypridle.conf" },
            },
          },
        },
      },
      -- This fixes the filetype detection so the LSP actually attaches
      setup = {
        hyprls = function()
          vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
            pattern = { "*.hl", "hypr*.conf" },
            callback = function()
              vim.bo.filetype = "hyprlang"
            end,
          })
        end,
      },
    },
  },
}
