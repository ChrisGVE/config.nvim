local M = {}

local uv = vim.uv or vim.loop
local cache_dir = vim.fn.stdpath("cache")
local debug_log_path = cache_dir .. "/lsp_cleanup_debug.log"
local marker_file = cache_dir .. "/last_lsp_cleanup.txt"
local read_chunk_size = 1024 * 1024

local function log_debug(msg)
  local file = io.open(debug_log_path, "a")
  if file then
    file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. msg .. "\n")
    file:close()
  end
end

local function format_number(n)
  return tostring(n):reverse():gsub("(%d%d%d)(%d*)", "%1'%2"):reverse():gsub("^'", "")
end

local function parse_entry_time(line)
  local timestamp = line:match("(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)")
  if not timestamp then
    return nil
  end

  local y, m, d, h, mi, s = timestamp:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
  if not (y and m and d and h and mi and s) then
    return nil
  end

  return os.time({
    year = tonumber(y),
    month = tonumber(m),
    day = tonumber(d),
    hour = tonumber(h),
    min = tonumber(mi),
    sec = tonumber(s),
  })
end

function M.purge_old_lsp_logs(days_to_keep)
  local log_path = vim.lsp.get_log_path()
  local tmp_path = log_path .. ".tmp"
  local cutoff_time = os.time() - (days_to_keep * 86400)
  local kept_count, removed_count = 0, 0
  local read_fd, write_fd
  local read_offset = 0
  local pending = ""

  local function close_fd(fd, cb)
    if not fd then
      if cb then
        cb()
      end
      return
    end

    uv.fs_close(fd, function()
      if cb then
        cb()
      end
    end)
  end

  local function cleanup_tmp()
    uv.fs_unlink(tmp_path, function() end)
  end

  local function abort_cleanup(message)
    log_debug(message)
    local current_read_fd = read_fd
    local current_write_fd = write_fd
    read_fd = nil
    write_fd = nil
    close_fd(current_read_fd, function()
      close_fd(current_write_fd, cleanup_tmp)
    end)
  end

  local function filter_lines(block)
    local kept = {}
    for line in block:gmatch("[^\r\n]+") do
      local entry_time = parse_entry_time(line)
      if not entry_time or entry_time >= cutoff_time then
        kept[#kept + 1] = line
        kept_count = kept_count + 1
      else
        removed_count = removed_count + 1
      end
    end

    if #kept == 0 then
      return ""
    end
    return table.concat(kept, "\n") .. "\n"
  end

  local function write_filtered(block, cb)
    local filtered = filter_lines(block)
    if filtered == "" then
      cb(true)
      return
    end

    uv.fs_write(write_fd, filtered, -1, function(write_err)
      if write_err then
        cb(false, write_err)
        return
      end
      cb(true)
    end)
  end

  local function finish_cleanup()
    local current_read_fd = read_fd
    local current_write_fd = write_fd
    read_fd = nil
    write_fd = nil

    close_fd(current_read_fd, function()
      close_fd(current_write_fd, function()
        uv.fs_rename(tmp_path, log_path, function(rename_err)
          if rename_err then
            abort_cleanup("❌ Failed to replace LSP log with filtered output: " .. tostring(rename_err))
            return
          end

          log_debug("🔢 Kept " .. format_number(kept_count) .. " log lines, removed " .. format_number(removed_count))

          uv.fs_stat(log_path, function(_, new_stat)
            if new_stat then
              log_debug("✅ LSP log cleanup complete. New size: " .. format_number(new_stat.size) .. " bytes")
            else
              log_debug("⚠ Couldn't determine new log size.")
            end
          end)
        end)
      end)
    end)
  end

  local function read_next()
    uv.fs_read(read_fd, read_chunk_size, read_offset, function(read_err, data)
      if read_err then
        abort_cleanup("❌ Error reading LSP log: " .. tostring(read_err))
        return
      end

      if not data or #data == 0 then
        if pending ~= "" then
          write_filtered(pending, function(ok, write_err)
            if not ok then
              abort_cleanup("❌ Error writing filtered LSP log: " .. tostring(write_err))
              return
            end
            finish_cleanup()
          end)
        else
          finish_cleanup()
        end
        return
      end

      read_offset = read_offset + #data
      local combined = pending .. data
      local last_newline = combined:match(".*()\n")

      if not last_newline then
        pending = combined
        read_next()
        return
      end

      pending = combined:sub(last_newline + 1)
      local complete_block = combined:sub(1, last_newline)
      write_filtered(complete_block, function(ok, write_err)
        if not ok then
          abort_cleanup("❌ Error writing filtered LSP log: " .. tostring(write_err))
          return
        end
        read_next()
      end)
    end)
  end

  log_debug("📁 Checking LSP log: " .. log_path)
  uv.fs_stat(log_path, function(stat_err, stat)
    if stat_err then
      log_debug("❌ Failed to stat LSP log: " .. tostring(stat_err))
      return
    end

    if not stat or stat.size == 0 then
      log_debug("✅ LSP log is empty, skipping cleanup.")
      return
    end

    log_debug("📊 LSP log size before cleanup: " .. format_number(stat.size) .. " bytes")
    uv.fs_open(log_path, "r", 438, function(open_err, fd)
      if open_err then
        log_debug("❌ Error opening LSP log file: " .. tostring(open_err))
        return
      end

      read_fd = fd
      uv.fs_open(tmp_path, "w", 438, function(tmp_err, tmp_fd)
        if tmp_err then
          log_debug("❌ Error opening temporary LSP log file: " .. tostring(tmp_err))
          local current_read_fd = read_fd
          read_fd = nil
          close_fd(current_read_fd)
          return
        end

        write_fd = tmp_fd
        read_next()
      end)
    end)
  end)
end

function M.should_run_cleanup(callback)
  local callback_done = false
  local function finish(should_run)
    if callback_done then
      return
    end
    callback_done = true
    callback(should_run)
  end

  local current_date = os.date("%Y-%m")

  uv.fs_open(marker_file, "r", 438, function(open_err, fd)
    if open_err then
      log_debug("⚠ Marker file does not exist. Creating new one.")
      uv.fs_open(marker_file, "w", 438, function(write_err, write_fd)
        if write_err then
          log_debug("❌ Failed to create marker file: " .. tostring(write_err))
          finish(true)
          return
        end

        uv.fs_write(write_fd, current_date .. "\n", 0, function(marker_write_err)
          if marker_write_err then
            log_debug("❌ Failed to write marker file: " .. tostring(marker_write_err))
          end
          uv.fs_close(write_fd, function()
            if not marker_write_err then
              log_debug("✅ Created marker file: " .. marker_file)
            end
            finish(true)
          end)
        end)
      end)
      return
    end

    uv.fs_read(fd, 32, 0, function(read_err, data)
      uv.fs_close(fd, function()
        if read_err then
          log_debug("❌ Failed to read marker file: " .. tostring(read_err))
          finish(true)
          return
        end

        local last_cleanup_date = (data or ""):match("[^\r\n]+") or ""
        if last_cleanup_date == current_date then
          log_debug("✅ Cleanup already done this month. Skipping.")
          finish(false)
          return
        end

        log_debug("🆕 New month detected, updating marker file.")
        uv.fs_open(marker_file, "w", 438, function(write_err, write_fd)
          if write_err then
            log_debug("❌ Failed to update marker file: " .. tostring(write_err))
            finish(true)
            return
          end

          uv.fs_write(write_fd, current_date .. "\n", 0, function(marker_write_err)
            if marker_write_err then
              log_debug("❌ Failed to update marker content: " .. tostring(marker_write_err))
            end
            uv.fs_close(write_fd, function()
              if not marker_write_err then
                log_debug("✅ Updated marker file to " .. current_date)
              end
              finish(true)
            end)
          end)
        end)
      end)
    end)
  end)
end

return M
