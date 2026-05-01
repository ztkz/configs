local shell_theme = require("config.shell_theme")

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = function(_, opts)
      opts = opts or {}
      opts.show_end_of_buffer = true
      opts.term_colors = true
      opts.default_integrations = true
      opts.auto_integrations = true
      opts.integrations.cmp = true
      opts.integrations.gitsigns = true
      opts.integrations.nvimtree = true
      opts.integrations.notify = true
      opts.integrations.mini = {
        enabled = true,
        indentscope_color = "",
      }
      opts.integrations.tmux = true
      opts.flavour = shell_theme.get_initial_flavor()
      return opts
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = function()
        vim.cmd.colorscheme("catppuccin-" .. shell_theme.get_initial_flavor())
      end,
    },
  }
}
