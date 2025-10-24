local wezterm = require 'wezterm'

local config = {}

if wezterm.config_builder then
	config = wezterm.config_builder()
end

config.scrollback_lines = 1000000
config.color_scheme = 'Monokai Remastered'
config.tab_bar_at_bottom = false
config.window_frame = {
  font_size = 14.0,
}
config.window_background_opacity = 0.9
config.text_background_opacity = 0.8
config.front_end = 'WebGpu'
config.enable_wayland = true
config.font = wezterm.font_with_fallback { 'Sarasa Mono J', 'Sarasa Mono K', 'Sarasa Mono CL', 'Sarasa Mono TC', 'Sarasa Mono SC' }
config.font_size = 18
config.detect_password_input = true
config.ime_preedit_rendering = "Builtin"
config.launch_menu = {
  {
    label = 'btm',
    args = { 'sudo', '-E', 'btm' },
  },
}
config.use_ime = true
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
  { key = 'Space', mods = 'CTRL', action = wezterm.action.DisableDefaultAssignment },
  { key = 'Space', mods = 'CTRL|SHIFT', action = wezterm.action.DisableDefaultAssignment },
}
for i = 1, 9 do
  table.insert(config.keys, { key = tostring(i), mods = 'ALT', action = wezterm.action.ActivateTab(i - 1), })
end

return config
