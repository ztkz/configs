return {
  "sindrets/diffview.nvim",
  opts = {
    hg_cmd = { vim.fn.expand("~/.local/bin/hg-diffview") },
  },
  dependencies = { "nvim-lua/plenary.nvim" },
}
