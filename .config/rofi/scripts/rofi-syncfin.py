#!/usr/bin/env python3

import logging
from pathlib import Path
from subprocess import Popen
from sys import argv
from sys import exit as sysexit

from rofi import Rofi

DEFAULT = Path.home().expanduser() / "Videos" / "sauce"

logger = logging.getLogger("rofi-syncfin")
logger.setLevel(logging.DEBUG)
sh = logging.StreamHandler()
sh.setFormatter(
    logging.Formatter("%(asctime)s | %(name)s | %(levelname)s | %(message)s")
)
logger.addHandler(sh)


def notification(title: str, message: str) -> None:
    """Sends a notification."""
    Popen(["dunstify", title, message])


def run_syncfin(pth: Path | str) -> None:
    """Runs syncfin in the given path."""
    pth = Path(pth)
    if not pth.exists() or not pth.is_dir():
        notification("Syncfin:", f"Path {pth} does not exist.")
        logger.error("Invalid path: %s", pth)
        sysexit(1)
    with Popen(["/home/sudacode/.bin/syncfin", pth]) as proc:
        ret = proc.wait()
    if ret != 0:
        notification("Syncfin:", f"Syncfin failed with exit code {ret}.")
        logger.error("syncfin returned non-zero exit code: %s", ret)
        sysexit(1)


def get_dirs(in_pth: Path | str) -> list[Path]:
    """Returns a list of directories in the given path."""
    path = Path(in_pth)
    return [x for x in path.iterdir() if x.is_dir()]


if __name__ == "__main__":
    rofi = Rofi(
        rofi_args=[
            "-dmenu",
            "-i",
            "-config",
            "/home/sudacode/.config/aniwrapper/themes/aniwrapper-nord2.rasi",
            "-dpi",
            "144",
        ],
        theme_str="window { width: 85%; } listview { lines: 10; }",
    )
    logger.debug("Starting rofi-syncfin.py")
    logger.debug("HOME: %s", DEFAULT)
    dirs = get_dirs(DEFAULT)
    dirs = [x.name for x in dirs]
    choice, status = rofi.select("Select a directory", dirs)
    if status == -1:
        notification("rofi-syncfin", "Failed")
        sysexit(1)
    else:
        logger.debug("Selected dir: %s", choice)
        logger.info("Running syncfin on %s", dirs[choice])
        pth = str(DEFAULT / dirs[choice])
        logger.debug("Path: %s", pth)
        notification("rofi-syncfin:", f"Syncing {dirs[choice]}")
        run_syncfin(pth)
        notification("rofi-syncfin", f"Finished syncing {dirs[choice]}")
