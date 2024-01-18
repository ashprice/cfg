#!/usr/bin/fish
# TODO: add quick regex to avoid matching MacOS files that syncthing brings over
# Alternatively, tell syncthing not to bring them
set monitor (hyprctl monitors | rg Monitor | awk '{print $2}')
set background (find ~/pictures/ -type f | shuf -n1)

hyprctl hyprpaper unload all
hyprctl hyprpaper preload $background
hyprctl hyprpaper wallpaper "$monitor,$background"

