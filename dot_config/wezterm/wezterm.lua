local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.color_scheme = 'Kanagawa (Gogh)'
config.tab_bar_at_bottom = true
config.window_frame = {
  font_size = 14.0,
}
config.window_background_opacity = 0.8
config.text_background_opacity = 0.65
config.front_end = 'WebGpu'
config.font = wezterm.font_with_fallback { 'Iosevka Custom', 'Sarasa Term J', 'Sarasa Term K', 'Sarasa Term CL', 'Sarasa Term TC', 'Sarasa Term SC' }
config.launch_menu = {
  {
    label = 'btm',
    args = { 'sudo', '-E', 'btm' },
  },
}
config.use_ime = true
config.xim_im_name = 'ibus-daemon -drx'
config.keys = {
  { key = 'c', mods = 'ALT', action = wezterm.action.CopyTo 'Clipboard' },
  { key = 'v', mods = 'ALT', action = wezterm.action.PasteFrom 'Clipboard' },
  { key = 'm', mods = 'ALT', action = wezterm.action.Hide },
  { key = 'n', mods = 'ALT', action = wezterm.action.SpawnWindow },
  { key = 't', mods = 'ALT', action = wezterm.action.SpawnTab 'CurrentPaneDomain' },
  { key = 't', mods = 'ALT|SHIFT', action = wezterm.action.SpawnTab 'DefaultDomain' },
  { key = 'w', mods = 'ALT', action = wezterm.action.CloseCurrentTab{confirm=true} },
  { key = 'k', mods = 'ALT', action = wezterm.action.ScrollByLine(-1) },
  { key = 'j', mods = 'ALT', action = wezterm.action.ScrollByLine(1) },
}
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'ALT', action = wezterm.action.ActivateTab(i - 1), })
end
config.font_size = 24.0

return config
