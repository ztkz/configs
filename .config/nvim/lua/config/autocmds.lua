-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

local shell_theme_sync = vim.api.nvim_create_augroup("shell_theme_sync", { clear = true })
local shell_theme = require("config.shell_theme")
shell_theme.setup_user_commands()

if vim.v.vim_did_enter == 1 then
  shell_theme.start_watcher()
else
  vim.api.nvim_create_autocmd("VimEnter", {
    group = shell_theme_sync,
    once = true,
    callback = function()
      shell_theme.start_watcher()
    end,
  })
end
