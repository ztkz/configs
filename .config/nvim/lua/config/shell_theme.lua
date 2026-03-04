local M = {}

local uv = vim.uv or vim.loop
local theme_file = vim.fn.expand("~/.config/shell_theme")
local theme_dir = vim.fn.fnamemodify(theme_file, ":h")
local theme_name = vim.fn.fnamemodify(theme_file, ":t")

local aliases = {
  latte = "latte",
  frappe = "frappe",
  macchiato = "macchiato",
  mocha = "mocha",
  light = "latte",
  dark = "frappe",
}

local current_flavor
local fs_event_watcher
local fs_poll_watcher
local debounce_timer
local started = false
local commands_registered = false
local poll_interval_ms

local function normalize(raw)
  if type(raw) ~= "string" then
    return nil
  end
  local trimmed = vim.trim(raw):lower()
  if trimmed == "" then
    return nil
  end
  return aliases[trimmed]
end

function M.read_flavor()
  local fd = uv.fs_open(theme_file, "r", 438)
  if not fd then
    return nil
  end

  local stat = uv.fs_fstat(fd)
  if not stat or stat.size <= 0 then
    uv.fs_close(fd)
    return nil
  end

  local content = uv.fs_read(fd, math.min(stat.size, 64), 0)
  uv.fs_close(fd)
  return normalize(content)
end

function M.get_initial_flavor()
  return M.read_flavor() or "frappe"
end

function M.apply(flavor)
  local target = normalize(flavor) or M.read_flavor() or "frappe"
  if target == current_flavor then
    return
  end

  local ok, catppuccin = pcall(require, "catppuccin")
  if not ok then
    return
  end

  catppuccin.setup({ flavour = target })
  pcall(vim.cmd.colorscheme, "catppuccin")
  current_flavor = target
end

function M.start_watcher()
  if started then
    return
  end

  if not uv.new_timer then
    return
  end

  debounce_timer = uv.new_timer()
  if not debounce_timer then
    return
  end

  local function queue_apply()
    if not debounce_timer or debounce_timer:is_closing() then
      return
    end
    debounce_timer:stop()
    debounce_timer:start(
      50,
      0,
      vim.schedule_wrap(function()
        M.apply()
      end)
    )
  end

  local fs_event_ok = false
  if uv.new_fs_event then
    fs_event_watcher = uv.new_fs_event()
    if fs_event_watcher then
      fs_event_ok = pcall(function()
        fs_event_watcher:start(theme_dir, {}, function(err, filename, _)
          if err then
            return
          end
          if filename then
            local base = vim.fn.fnamemodify(filename, ":t")
            if base ~= theme_name then
              return
            end
          end
          queue_apply()
        end)
      end)
      if not fs_event_ok then
        fs_event_watcher:close()
        fs_event_watcher = nil
      end
    end
  end

  local fs_poll_ok = false
  if uv.new_fs_poll then
    fs_poll_watcher = uv.new_fs_poll()
    if fs_poll_watcher then
      local interval = fs_event_ok and 20000 or 3000
      poll_interval_ms = interval
      fs_poll_ok = pcall(function()
        fs_poll_watcher:start(theme_file, interval, function(err, prev, curr)
          if err or not curr then
            return
          end
          if not prev then
            queue_apply()
            return
          end
          local prev_mtime = prev.mtime and (prev.mtime.sec * 1000000000 + prev.mtime.nsec) or 0
          local curr_mtime = curr.mtime and (curr.mtime.sec * 1000000000 + curr.mtime.nsec) or 0
          local prev_size = prev.size or 0
          local curr_size = curr.size or 0
          if prev_mtime ~= curr_mtime or prev_size ~= curr_size then
            queue_apply()
          end
        end)
      end)
      if not fs_poll_ok then
        fs_poll_watcher:close()
        fs_poll_watcher = nil
        poll_interval_ms = nil
      end
    end
  end

  if not fs_event_ok and not fs_poll_ok then
    debounce_timer:close()
    debounce_timer = nil
    return
  end

  started = true

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = vim.api.nvim_create_augroup("shell_theme_sync_cleanup", { clear = true }),
    callback = function()
      if fs_event_watcher and not fs_event_watcher:is_closing() then
        fs_event_watcher:stop()
        fs_event_watcher:close()
      end
      if fs_poll_watcher and not fs_poll_watcher:is_closing() then
        fs_poll_watcher:stop()
        fs_poll_watcher:close()
      end
      if debounce_timer and not debounce_timer:is_closing() then
        debounce_timer:stop()
        debounce_timer:close()
      end
      fs_event_watcher = nil
      fs_poll_watcher = nil
      poll_interval_ms = nil
      debounce_timer = nil
    end,
  })
end

function M.get_status()
  local status = {
    started = started,
    file = theme_file,
    file_flavor = M.read_flavor() or "none",
    active_flavor = current_flavor or "none",
    fs_event = false,
    fs_poll = false,
    poll_interval_ms = poll_interval_ms,
  }

  if fs_event_watcher and not fs_event_watcher:is_closing() then
    status.fs_event = true
  end
  if fs_poll_watcher and not fs_poll_watcher:is_closing() then
    status.fs_poll = true
  end

  return status
end

function M.setup_user_commands()
  if commands_registered then
    return
  end
  commands_registered = true

  vim.api.nvim_create_user_command("ThemeWatchStatus", function()
    local status = M.get_status()
    local poll_seconds = status.poll_interval_ms and tostring(math.floor(status.poll_interval_ms / 1000)) .. "s" or "n/a"
    local lines = {
      "Theme watch status:",
      "started: " .. tostring(status.started),
      "fs_event: " .. tostring(status.fs_event),
      "fs_poll: " .. tostring(status.fs_poll),
      "poll interval: " .. poll_seconds,
      "file: " .. status.file,
      "file flavor: " .. status.file_flavor,
      "active flavor: " .. status.active_flavor,
    }
    vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "ThemeWatchStatus" })
  end, {
    desc = "Show shell theme watcher backend/status",
  })
end

return M
