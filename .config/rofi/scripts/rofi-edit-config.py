#!/usr/bin/env python3
"""Edit the chosen config file"""

from subprocess import Popen

from rofi import Rofi

CMD = "kitty nvim {}"

CONFIGS = (
    "~/.config/rofi/config.rasi",
    "~/.config/nvim/init.vim",
    "~/.config/rofi/scripts/rofi-open.py",
    "~/.config/rofi/scripts/rofi-edit-config.py",
    "~/.config/rofi/scripts/rofi-background.py",
    "~/.config/sxhkd/sxhkdrc",
    "~/.config/awesome/rc.lua",
    "~/.config/awesome/bindings/keybindings.lua",
    "~/.config/awesome/autorun.sh",
    "~/.config/ranger/rc.conf",
    "~/.config/ranger/rifle.conf",
    "~/.config/ranger/scope.sh",
    "~/.config/picom/picom.conf",
    "~/.config/compfy/compfy.conf",
    "~/.config/kitty/kitty.conf",
    "~/.config/mpv/mpv.conf",
)

if __name__ == "__main__":
    rofi = Rofi(
        config_file="~/Projects/Scripts/aniwrapper/themes/aniwrapper-nord2.rasi",
        theme_str="configuration {dpi: 144;} window {width: 55%;} listview {columns: 3; lines: 7;}",
    )
    chosen, _ = rofi.select("Edit config", CONFIGS)
    print("Chosen: {}".format(chosen))
    print("Config: {}".format(CONFIGS[chosen]))
    print(CMD.format(CONFIGS[chosen]))
    if chosen != -1:
        with Popen(CMD.format(CONFIGS[chosen]), shell=True) as proc:
            proc.wait()
