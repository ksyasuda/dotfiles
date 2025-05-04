#!/usr/bin/env python3
"""Sends the search query to a new tab in the browser"""

from subprocess import Popen
from sys import exit as sysexit

from rofi import Rofi

BROWSER = "google-chrome-stable"

if __name__ == "__main__":
    rofi = Rofi(
        config_file="~/Projects/Scripts/aniwrapper/themes/aniwrapper-nord2.rasi",
        theme_str="configuration {dpi: 144;} window {width: 45%;} listview {columns: 1; lines: 1;}",
    )
    query = rofi.text_entry("Search Youtube", rofi_args=["-i"])
    if query is None or query == "":
        sysexit(1)
    url = "https://www.youtube.com/results?search_query={}".format(query)
    with Popen([BROWSER, url]) as proc:
        proc.wait()
