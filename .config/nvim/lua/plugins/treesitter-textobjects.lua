return {
  {
    "nvim-treesitter/nvim-treesitter-textobjects",
    config = function(_, opts)
      require("nvim-treesitter-textobjects").setup(opts)

      for _, mode in ipairs({ "n", "x", "o" }) do
        pcall(vim.keymap.del, mode, ";")
        pcall(vim.keymap.del, mode, ",")
      end
    end,
  },
}
