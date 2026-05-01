-- Plugin Manager
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

local meta = require("config.meta")
local spec = {
  -- add LazyVim and import its plugins
  { "LazyVim/LazyVim", tag = "v15.13.0", import = "lazyvim.plugins" },
  { import = "lazyvim.plugins.extras.lsp.none-ls" },
  -- import/override with your plugins in `~/.config/nvim/lua/plugins`
  -- this can overwrite configurations from all of the above
  { import = "plugins" },
}

if meta.is_enabled() then
  table.insert(spec, 2, {
    dir = meta.plugin_dir(),
    name = "meta.nvim",
    import = "meta.lazyvim",
  })
end

require("lazy").setup({
  spec = spec,
  defaults = {
    -- By default, only LazyVim plugins will be lazy-loaded. Your custom plugins
    -- will load during startup. If you know what you're doing, you can set this
    -- to `true` to have all your custom plugins lazy-loaded by default.
    lazy = false,
    -- It's recommended to leave version=false for now, since a lot the plugin
    -- that support versioning, have outdated releases, which may break your
    -- Neovim install.
    version = false, -- always use the latest git commit
    -- try installing the latest stable version for plugins that support semver
    -- version = "*",
    news = false, -- don't show news popup on each launch of nvim
  },
  install = { colorscheme = { "tokyonight" } },
  checker = { enabled = false }, -- don't automatically check for plugin updates
  performance = {
    rtp = {
      -- disable some rtp plugins
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

if meta.is_enabled() then
  vim.keymap.set("n", "<leader>hh", "<cmd>HgDiff<cr>", { desc = "HG diff" })
end
