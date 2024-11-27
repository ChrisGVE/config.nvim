return {
  "NvChad/nvim-colorizer.lua",
  event = "BufReadPre",
  opts = { -- set to setup table
    user_default_options = {
      RGB = false, -- #RGB hex codes
      RRGGBB = false,
      RRGGBBAA = true, -- #RRGGBBAA hex codes
      AARRGGBB = true, -- 0xAARRGGBB hex codes
      rgb_fn = true, -- CSS rgb() and rgba() functions
      hsl_fn = true, -- CSS hsl() and hsla() functions
      -- Virtualtext character to use
      virtualtext = "■",
      -- Display virtualtext inline with color
      virtualtext_inline = true,
    },
  },
}
