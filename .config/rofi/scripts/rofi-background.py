#!/usr/bin/env python


from pathlib import Path
from subprocess import Popen
from sys import exit as sysexit

from rofi import Rofi

CMD = ["feh", "--bg-scale"]

WALLPAPERS = {
    "Maisan": Path("~/nextcloud/pictures/sauce/MYSanGun.png").expanduser().as_posix()
    + ","
    + Path("~/nextcloud/pictures/sauce/MYSanGun-Inverted.png").expanduser().as_posix(),
    "Arch Logo (Purple)": Path(
        "~/Pictures/wallpapers/Arch Linux (Text Purple).png"
    ).expanduser(),
    "Arch Logo (Blue)": Path("~/Pictures/wallpapers/Arch Linux (Text Blue).png"),
    "Arch Pacman": Path("~/Pictures/wallpapers/ArchPacman.png").expanduser(),
    "Bash Hello World": Path("~/Pictures/wallpapers/Bash Hello World.png"),
    "Bash rm -rf": Path("~/Pictures/wallpapers/Bash rm -rf 1.png").expanduser(),
    "C++ Hello World": Path("~/Pictures/wallpapers/C++ Hello World.png").expanduser(),
    "C Hello World": Path("~/Pictures/wallpapers/C Hello World.png").expanduser(),
    "Python Hello World": Path(
        "~/Pictures/wallpapers/Python Hello World.png"
    ).expanduser(),
    "Jujutsu Kaisen": Path("~/Pictures/wallpapers/Jujutsu Kaisen 1.png").expanduser(),
    "My Hero Academia": Path(
        "~/Pictures/wallpapers/My Hero Academia 2.png"
    ).expanduser(),
    "NASA Japan": Path("~/Pictures/wallpapers/NASA-Japan.png").expanduser(),
    "Sasuke Seal": Path("~/Pictures/wallpapers/Sasuke Seal (Red).png").expanduser(),
    "Import Rice": Path("~/Pictures/wallpapers/Import Rice Unixporn 1.png")
    .expanduser()
    .expanduser()
    .as_posix()
    + ","
    + Path("~/Pictures/wallpapers/Import Rice Unixporn 2.png").expanduser().as_posix(),
}

if __name__ == "__main__":
    rofi = Rofi(
        config_file="~/Projects/Scripts/aniwrapper/themes/aniwrapper-dracula.rasi",
        theme_str="configuration {dpi: 144;} window {width: 45%;} listview {columns: 3; lines: 5;}",
        rofi_args=["-i"],
    )
    idx = rofi.select("Choose a wallpaper", sorted(WALLPAPERS.keys()))[0]
    wallpaper = WALLPAPERS[list(sorted(WALLPAPERS.keys()))[idx]]
    if isinstance(wallpaper, str) and "," in wallpaper:
        wallpaper = wallpaper.split(",")
    else:
        wallpaper = [wallpaper]
    print("wallpaper: {}".format(wallpaper))
    if wallpaper is None or wallpaper == "":
        sysexit(1)
    cmd = CMD + wallpaper
    print("cmd: {}".format(cmd))
    with Popen(cmd) as proc:
        proc.wait()
