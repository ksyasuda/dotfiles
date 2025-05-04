#!/usr/bin/env python3

from subprocess import Popen
from sys import exit as sysexit

import pyperclip
from rofi import Rofi


def notify(title, message, icon=None):
    """Use dunstify to send notifications"""
    if icon:
        Popen(["dunstify", title, message, "-i", icon])
    else:
        Popen(["dunstify", title, message])


def main():
    """Send video to MPV"""
    rofi = Rofi(
        lines=1, width="35%", config_file="~/.config//rofi//aniwrapper-dracula.rasi"
    )
    url = rofi.text_entry("Enter video URL")
    with Popen(["/usr/bin/mpv", url]) as proc:
        notify("rofi-mpv", "Playing video", "video-x-generic")
        proc.wait()
    if proc.returncode != 0:
        sysexit(1)
    sysexit(0)


if __name__ == "__main__":
    main()
