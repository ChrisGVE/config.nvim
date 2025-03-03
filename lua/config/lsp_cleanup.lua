local M = {}

local uv = vim.loop
local cache_dir = vim.fn.stdpath("cache")
local debug_log_path = cache_dir .. "/lsp_cleanup_debug.log"
local marker_file = cache_dir .. "/last_lsp_cleanup.txt"

local function log_debug(msg)
  local debug_log_path = vim.fn.stdpath("cache") .. "/lsp_cleanup_debug.log"
  local file = io.open(debug_log_path, "a")
  if file then
    file:write(os.date("[%Y-%m-%d %H:%M:%S] ") .. msg .. "\n")
    file:close()
  end
end

local function format_number(n)
  return tostring(n):reverse():gsub("(%d%d%d)(%d*)", "%1'%2"):reverse():gsub("^'", "")
end

function M.purge_old_lsp_logs(days_to_keep)
  local log_path = vim.lsp.get_log_path()
  log_debug("📁 Checking LSP log: " .. log_path)

  vim.loop.fs_stat(log_path, function(stat_err, stat)
    if stat_err then
      log_debug("❌ Failed to stat LSP log: " .. tostring(stat_err))
      return
    end
    log_debug("📊 LSP log size before cleanup: " .. format_number(stat.size) .. " bytes")

    vim.loop.fs_open(log_path, "r", 438, function(err, fd)
      if err then
        log_debug("❌ Error opening LSP log file: " .. tostring(err))
        return
      end

      vim.loop.fs_fstat(fd, function(stat_err, stat)
        if stat_err then
          log_debug("❌ Error getting LSP log stats: " .. tostring(stat_err))
          return
        end

        vim.loop.fs_read(fd, stat.size, 0, function(read_err, data)
          vim.loop.fs_close(fd)
          if read_err then
            log_debug("❌ Error reading LSP log: " .. tostring(read_err))
            return
          end

          local lines = {}
          local cutoff_time = os.time() - (days_to_keep * 86400)
          local kept_count, removed_count = 0, 0

          for line in data:gmatch("[^\r\n]+") do
            -- Updated timestamp pattern
            local timestamp = line:match("(%d%d%d%d%-%d%d%-%d%d %d%d:%d%d:%d%d)")
            if timestamp then
              local y, m, d, h, mi, s = timestamp:match("(%d+)-(%d+)-(%d+) (%d+):(%d+):(%d+)")
              local entry_time = os.time({ year = y, month = m, day = d, hour = h, min = mi, sec = s })
              if entry_time >= cutoff_time then
                table.insert(lines, line)
                kept_count = kept_count + 1
              else
                removed_count = removed_count + 1
              end
            else
              table.insert(lines, line)
            end
          end

          log_debug("🔢 Kept " .. format_number(kept_count) .. " log lines, removed " .. format_number(removed_count))

          vim.loop.fs_open(log_path, "w", 438, function(write_err, write_fd)
            if write_err then
              log_debug("❌ Error writing LSP log: " .. tostring(write_err))
              return
            end

            vim.loop.fs_write(write_fd, table.concat(lines, "\n") .. "\n", 0, function()
              vim.loop.fs_close(write_fd)
              vim.loop.fs_stat(log_path, function(stat_err2, new_stat)
                if new_stat then
                  log_debug("✅ LSP log cleanup complete. New size: " .. format_number(new_stat.size) .. " bytes")
                else
                  log_debug("⚠ Couldn't determine new log size.")
                end
              end)
            end)
          end)
        end)
      end)
    end)
  end)
end

function M.should_run_cleanup(callback)
  local marker_file = vim.fn.stdpath("cache") .. "/last_lsp_cleanup.txt"

  vim.loop.fs_open(marker_file, "r", 438, function(err, fd)
    if err then
      log_debug("⚠ Marker file does not exist. Creating new one.")
      -- Create the file if missing
      vim.loop.fs_open(marker_file, "w", 438, function(write_err, write_fd)
        if write_err then
          log_debug("❌ Failed to create marker file: " .. tostring(write_err))
        else
          vim.loop.fs_write(write_fd, os.date("%Y-%m") .. "\n", 0, function()
            vim.loop.fs_close(write_fd)
            log_debug("✅ Created marker file: " .. marker_file)
          end)
        end
        callback(true)
      end)
      return
    end

    vim.loop.fs_read(fd, 20, 0, function(read_err, data)
      vim.loop.fs_close(fd)
      if read_err then
        log_debug("❌ Failed to read marker file: " .. tostring(read_err))
        callback(true)
        return
      end

      local last_cleanup_date = data:match("[^\r\n]+") or ""
      local current_date = os.date("%Y-%m")

      if last_cleanup_date ~= current_date then
        log_debug("🆕 New month detected, updating marker file.")

        vim.loop.fs_open(marker_file, "w", 438, function(write_err, write_fd)
          if write_err then
            log_debug("❌ Failed to update marker file: " .. tostring(write_err))
            return
          end
          vim.loop.fs_write(write_fd, current_date .. "\n", 0, function()
            vim.loop.fs_close(write_fd)
            log_debug("✅ Updated marker file to " .. current_date)
          end)
          callback(true)
        end)
      else
        log_debug("✅ Cleanup already done this month. Skipping.")
        callback(false)
      end
    end)
  end)
end

return M
