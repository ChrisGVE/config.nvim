return {
  "jake-stewart/multicursor.nvim",
  branch = "1.0",
  config = function()
    local mc = require("multicursor-nvim")
    mc.setup()

    local set = vim.keymap.set

    -- Add or skip cursor above/below the main cursor.
    set({ "n", "x" }, "<Up>", function()
      mc.lineAddCursor(-1)
    end, { desc = "Add cursor above the main cursor" })
    set({ "n", "x" }, "<Down>", function()
      mc.lineAddCursor(1)
    end, { desc = "Add cursor below the main cursor" })
    set({ "n", "x" }, "<S-Up>", function()
      mc.lineSkipCursor(-1)
    end, { desc = "Skip adding cursor above the main cursor" })
    set({ "n", "x" }, "<S-Down>", function()
      mc.lineSkipCursor(1)
    end, { desc = "Skip adding cursor below the main cursor" })

    -- Add or skip adding a new cursor by matching word/selection
    set({ "n", "x" }, "<leader>n", function()
      mc.matchAddCursor(1)
    end, { desc = "Add a new cursor below by matching word/selection" })
    set({ "n", "x" }, "<leader>s", function()
      mc.matchSkipCursor(1)
    end, { desc = "Skip adding a new cursor below by matching word/selection" })
    set({ "n", "x" }, "<leader>N", function()
      mc.matchAddCursor(-1)
    end, { desc = "Add a new cursor above by matching word/selection" })
    set({ "n", "x" }, "<leader>S", function()
      mc.matchSkipCursor(-1)
    end, { desc = "Skip adding a new cursor above by matching word/selection" })

    -- Add and remove cursors with control + left click.
    set("n", "<c-leftmouse>", mc.handleMouse, { desc = "Add and remove cursors with control + left click" })
    set("n", "<c-leftdrag>", mc.handleMouseDrag, { desc = "Add and remove cursors with control + left click" })
    set("n", "<c-leftrelease>", mc.handleMouseRelease, { desc = "Add and remove cursors with control + left click" })

    -- Disable and enable cursors.
    set({ "n", "x" }, "<c-q>", mc.toggleCursor, { desc = "Toggle cursors" })

    -- Pressing `gaip` will add a cursor on each line of a paragraph.
    set("n", "ga", mc.addCursorOperator, { desc = "Add cursors using operators" })

    -- Clone every cursor and disable the originals.
    set({ "n", "x" }, "<leader><c-q>", mc.duplicateCursors, { desc = "Clone every cursor and disable the originals" })

    -- Align cursor columns.
    set("n", "<leader>a", mc.alignCursors, { desc = "Align cursor columns" })

    -- Split visual selections by regex.
    set("x", "S", mc.splitCursors, { desc = "Split visual selections by regex" })

    -- Match new cursors within visual selections by regex.
    set("x", "M", mc.matchCursors, { desc = "Match new cursors within visual selections by regex" })

    -- Bring back cursors if you accidentally clear them
    set("n", "<leader>gv", mc.restoreCursors, { desc = "Restore cursors if accidentally cleared" })

    -- Add a cursor for all matches of cursor word/selection in the document.
    set(
      { "n", "x" },
      "<leader>A",
      mc.matchAllAddCursors,
      { desc = "Add cursor for all matches of cursor word/selection in the buffer" }
    )

    -- Rotate the text contained in each visual selection between cursors.
    set("x", "<leader>t", function()
      mc.transposeCursors(1)
    end, { desc = "Rotate the text contained in each visual selection between cursors" })
    set("x", "<leader>T", function()
      mc.transposeCursors(-1)
    end, { desc = "Rotate the text contained in each visual selection between cursors" })

    -- Append/insert for each line of visual selections.
    -- Similar to block selection insertion.
    set("x", "I", mc.insertVisual, { desc = "Insert for each line of visual selection" })
    set("x", "A", mc.appendVisual, { desc = "Append for each line of visual selection" })

    -- Increment/decrement sequences, treating all cursors as one sequence.
    set(
      { "n", "x" },
      "g<c-c>",
      mc.sequenceIncrement,
      { desc = "Increment sequences, treating all cursors as one sequence" }
    )
    set(
      { "n", "x" },
      "g<c-x>",
      mc.sequenceDecrement,
      { desc = "Decrement sequences, treating all cursors as one sequence" }
    )

    -- Add a cursor and jump to the next/previous search result.
    set("n", "<leader>/n", function()
      mc.searchAddCursor(1)
    end, { desc = "Add a cursor and jump to the next search result" })
    set("n", "<leader>/N", function()
      mc.searchAddCursor(-1)
    end, { desc = "Add a cursor and jump to the previous search result" })

    -- Jump to the next/previous search result without adding a cursor.
    set("n", "<leader>/s", function()
      mc.searchSkipCursor(1)
    end, { desc = "Jump to the next search result without adding a cursor" })
    set("n", "<leader>/S", function()
      mc.searchSkipCursor(-1)
    end, { desc = "Jump to the previous search result without adding a cursor" })

    -- Add a cursor to every search result in the buffer.
    set("n", "<leader>/A", mc.searchAllAddCursors, { desc = "Add a cursor to every search results in the buffer" })

    -- Pressing `<leader>miwap` will create a cursor in every match of the
    -- string captured by `iw` inside range `ap`.
    -- This action is highly customizable, see `:h multicursor-operator`.
    set({ "n", "x" }, "<leader>m", mc.operator, { desc = "Create cursor by operation (see :h multicursor-operator)" })

    -- Add or skip adding a new cursor by matching diagnostics.
    set({ "n", "x" }, "]d", function()
      mc.diagnosticAddCursor(1)
    end, { desc = "Add a new cursor by matching next diagnostic" })
    set({ "n", "x" }, "[d", function()
      mc.diagnosticAddCursor(-1)
    end, { desc = "Add a new cursor by matching previous diagnostic" })
    set({ "n", "x" }, "]s", function()
      mc.diagnosticSkipCursor(1)
    end, { desc = "Skip adding a cursor by matching next diagnostic" })
    set({ "n", "x" }, "[S", function()
      mc.diagnosticSkipCursor(-1)
    end, { desc = "Skip adding a cursor by matching previous diagnostic" })

    -- Press `mdip` to add a cursor for every error diagnostic in the range `ip`.
    set({ "n", "x" }, "md", function()
      -- See `:h vim.diagnostic.GetOpts`.
      mc.diagnosticMatchCursors({ severity = vim.diagnostic.severity.ERROR })
    end, { desc = "Press mdip to add a cursor for every error diagnostic in the range ip" })

    -- Mappings defined in a keymap layer only apply when there are
    -- multiple cursors. This lets you have overlapping mappings.
    mc.addKeymapLayer(function(layerSet)
      -- Select a different cursor as the main one.
      layerSet({ "n", "x" }, "<left>", mc.prevCursor, { desc = "Select previous cursor" })
      layerSet({ "n", "x" }, "<right>", mc.nextCursor, { desc = "Select next cursor" })

      -- Delete the main cursor.
      layerSet({ "n", "x" }, "<leader>x", mc.deleteCursor, { desc = "Delete the main cursor" })

      -- Enable and clear cursors using escape.
      layerSet("n", "<esc>", function()
        if not mc.cursorsEnabled() then
          mc.enableCursors()
        else
          mc.clearCursors()
        end
      end, { desc = "Enable and clear cursors" })
    end)

    -- Customize how cursors look.
    local hl = vim.api.nvim_set_hl
    hl(0, "MultiCursorCursor", { reverse = true })
    hl(0, "MultiCursorVisual", { link = "Visual" })
    hl(0, "MultiCursorSign", { link = "SignColumn" })
    hl(0, "MultiCursorMatchPreview", { link = "Search" })
    hl(0, "MultiCursorDisabledCursor", { reverse = true })
    hl(0, "MultiCursorDisabledVisual", { link = "Visual" })
    hl(0, "MultiCursorDisabledSign", { link = "SignColumn" })
  end,
}
