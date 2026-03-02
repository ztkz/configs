return {
  -- add gruvbox
  { "maxmx03/solarized.nvim" },

  -- Configure LazyVim to load gruvbox
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "solarized",
    },
  },
}
