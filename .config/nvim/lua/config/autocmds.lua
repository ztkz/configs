-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
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

local group = vim.api.nvim_create_augroup("my_file_reload", { clear = true })

vim.api.nvim_create_autocmd("FileChangedShell", {
  group = group,
  callback = function(args)
    if vim.bo[args.buf].modified then
      vim.notify("File changed on disk, but this buffer has unsaved edits", vim.log.levels.WARN)
      vim.v.fcs_choice = ""
    else
      vim.v.fcs_choice = "reload"
    end
  end,
})

vim.api.nvim_create_autocmd("FileChangedShellPost", {
  group = group,
  callback = function()
    vim.notify("File reloaded from disk", vim.log.levels.INFO)
  end,
})

vim.api.nvim_create_autocmd({ "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = group,
  callback = function()
    if vim.o.buftype ~= "nofile" then
      vim.cmd("checktime")
    end
  end,
})
