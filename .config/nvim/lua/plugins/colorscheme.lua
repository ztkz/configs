local shell_theme = require("config.shell_theme")

return {
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = function(_, opts)
      opts = opts or {}
      opts.flavour = shell_theme.get_initial_flavor()
      return opts
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin",
    },
  },
}
