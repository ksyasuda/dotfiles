#!/usr/bin/env python3
from subprocess import Popen
from sys import exit as sysexit

from pyperclip import paste


def notify(title, message, icon=None):
    """Use dunstify to send notifications"""
    if icon:
        Popen(["dunstify", title, message, "-i", icon])
    else:
        Popen(["dunstify", title, message])


if __name__ == "__main__":
    url = paste()
    if not url:
        sysexit(1)
    if not url.startswith("https://www.youtube.com/"):
        notify(
            "ERROR",
            "URL is not from YouTube",
            "/usr/share/icons/Dracula/scalable/apps/YouTube-youtube.com.svg",
        )
        sysexit(1)
    with Popen(["/usr/bin/mpv", url]) as proc:
        notify(
            "rofi-mpv",
            "Playing video",
            "/usr/share/icons/Dracula/scalable/apps/YouTube-youtube.com.svg",
        )
        proc.wait()
    if proc.returncode != 0:
        sysexit(1)
