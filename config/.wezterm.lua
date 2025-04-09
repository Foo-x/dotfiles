local wezterm = require("wezterm")

local config = wezterm.config_builder()

config.default_prog = { "wsl" }

-- config.color_scheme = "nordfox"
-- config.color_scheme = "nightfox"
-- config.color_scheme = "OneHalfDark"
-- config.color_scheme = "Catppuccin Frappe"
-- config.color_scheme = "Catppuccin Macchiato"
config.color_scheme = "Catppuccin Mocha"

config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"

config.font = wezterm.font_with_fallback {
  "FirgeNerd Console",
  "Moralerspace Argon HWNF",
}
config.font_size = 12

config.keys = {
  {
    key = "c",
    mods = "CTRL|SHIFT",
    action = wezterm.action.QuitApplication,
  }
}

return config
