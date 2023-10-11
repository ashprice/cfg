local wezterm = require 'wezterm'
local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = 'Kanagawa (Gogh)'
config.tab_bar_at_bottom = true
config.window_background_opacity = 0.8
config.text_background_opacity = 0.65
config.front_end = 'WebGpu'
config.font = wezterm.font 'Noto Sans Mono'

return config

