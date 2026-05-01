local M = {}

local META_PLUGIN_DIR = "/usr/share/fb-editor-support/nvim"
local META_PROXY_ARGS = { "--proxy", "http://fwdproxy:8080" }

local function env_to_bool(name)
  local value = vim.env[name]
  if value == nil or value == "" then
    return nil
  end

  value = value:lower()
  if value == "1" or value == "true" or value == "yes" or value == "on" then
    return true
  end
  if value == "0" or value == "false" or value == "no" or value == "off" then
    return false
  end

  return nil
end

local function load_meta_config()
  local ok, config = pcall(require, "meta.config")
  if ok then
    return config
  end

  local original_package_path = package.path
  package.path = string.format(
    "%s;%s/lua/?.lua;%s/lua/?/init.lua",
    package.path,
    META_PLUGIN_DIR,
    META_PLUGIN_DIR
  )

  ok, config = pcall(require, "meta.config")
  package.path = original_package_path

  if ok then
    return config
  end

  return nil
end

function M.plugin_dir()
  return META_PLUGIN_DIR
end

function M.is_available()
  return vim.fn.isdirectory(META_PLUGIN_DIR) ~= 0
end

function M.is_enabled()
  local override = env_to_bool("NVIM_ENABLE_META")
  if override ~= nil then
    return override and M.is_available()
  end

  return M.is_available()
end

function M.proxy_args()
  if not M.is_enabled() then
    return {}
  end

  local config = load_meta_config()
  if config == nil then
    return {}
  end

  local config_exts = config.options
    and config.options.lsp
    and config.options.lsp.vscode_extensions
  if config_exts == nil then
    return {}
  end

  local is_macos = config_exts.macos_app_dir
    and vim.fn.isdirectory(config_exts.macos_app_dir) ~= 0
  local is_fedora = config_exts.fedora_app_dir
    and vim.fn.isdirectory(config_exts.fedora_app_dir) ~= 0

  if is_macos or is_fedora then
    return {}
  end

  return vim.deepcopy(META_PROXY_ARGS)
end

return M
