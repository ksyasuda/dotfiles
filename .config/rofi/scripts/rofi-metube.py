#!/usr/bin/env python3

from pathlib import Path
from subprocess import PIPE, Popen
from sys import exit as sysexit

from rofi import Rofi

CFG_FILE = "~/.config/rofi/aniwrapper-dracula.rasi"


def send_notification(title, message):
    Popen(["notify-send", title, message])


if __name__ == "__main__":
    cfg = Path(CFG_FILE).expanduser()
    if not cfg.exists():
        print("Config file not found:", cfg)
        sysexit(1)

    # make sure rofi cfg file is valid
    rofi = Rofi(
        config_file="",
        theme_str="window { width: 35%; height: 10%; anchor: north; location: north;}",
    )
    url = rofi.text_entry("Enter YouTube URL:")

    # Make sure the URL is valid
    if not url.startswith("https://www.youtube.com/watch?v="):
        print("Invalid URL")
        sysexit(1)

    # Send video to metube using ~/.bin/metube
    with Popen(
        ["/home/sudacode/.bin/metube", f"{url}"],
        stdout=PIPE,
        stderr=PIPE,
    ) as proc:
        res = proc.communicate()
        if proc.returncode != 0:
            send_notification("Metube Upload Failed", res[1].decode("utf-8"))
            print(res[1].decode("utf-8"))
            sysexit(1)
        print(res[0].decode("utf-8"))
        send_notification("Metube Upload Successful", res[0].decode("utf-8"))
        sysexit(0)
