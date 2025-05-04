#!/usr/bin/env python3

from subprocess import Popen
from sys import argv
from sys import exit as sysexit

from rofi import Rofi

# BROWSER = "qutebrowser"
# BROWSER = "microsoft-edge-beta"
# BROWSER = "google-chrome-stable"
BROWSER = "firefox"
OPEN_TYPES = ["window", "tab"]

OPTIONS = [
    "Anilist - https://anilist.co/home",
    "Apprise - http://thebox:8888/",
    "Audiobookshelf - https://audiobookshelf.suda.codes",
    "Authentik - http://thebox:9000",
    "Calendar - https://nextcloud.suda.codes/apps/calendar",
    "Capital One - https://myaccounts.capitalone.com/accountSummary",
    "Chase Bank - https://secure03ea.chase.com/web/auth/dashboard#/dashboard/overviewAccounts/overview/singleDeposit",
    "ChatGPT - https://chat.openai.com/chat",
    "CloudBeaver - https://cloudbeaver.suda.codes",
    "Cloudflare - https://dash.cloudflare.com/",
    "CoinMarketCap - https://coinmarketcap.com/watchlist/",
    "Dashy - http://thebox:4000",
    "Deemix - http://thebox:3358",
    "F1TV - https://f1tv.suda.codes",
    "Fidelity - https://login.fidelity.com/ftgw/Fas/Fidelity/RtlCust/Login/Init?AuthRedUrl=https://oltx.fidelity.com/ftgw/fbc/oftop/portfolio#summary",
    "Firefly3 - https://firefly.suda.codes",
    "Gitea - https://gitea.suda.codes",
    "Github - https://github.com",
    "Ghostfolio - http://thebox:3334",
    "Grafana - http://thebox:3333",
    "Grafana (sudacode) - https://grafana.sudacode.com/d/1lcjN0bik3/nginx-logs-and-geo-map?orgId=1&refresh=10s",
    "Grafana (suda.codes) - http://thebox:3333/d/1lcjN0bik3/nginx-logs-and-geo-map?orgId=1&refresh=1m",
    "Grafana (Loki) - http://thebox:3333/explore?schemaVersion=1&panes=%7B%22rtz%22%3A%7B%22datasource%22%3A%22bdvgbaoxphu68c%22%2C%22queries%22%3A%5B%7B%22refId%22%3A%22A%22%2C%22expr%22%3A%22%22%2C%22queryType%22%3A%22range%22%2C%22datasource%22%3A%7B%22type%22%3A%22loki%22%2C%22uid%22%3A%22bdvgbaoxphu68c%22%7D%7D%5D%2C%22range%22%3A%7B%22from%22%3A%22now-1h%22%2C%22to%22%3A%22now%22%7D%7D%7D&orgId=1",
    "Homepage - https://homepage.suda.codes",
    "HomeAssistant - http://thebox:8123",
    "Icloud - https://www.icloud.com/",
    "Interactive Brokers - https://ndcdyn.interactivebrokers.com/sso/Login?RL=1&locale=en_US",
    "Jackett - http://thebox:9117",
    "Jellyseerr - http://thebox:5055",
    "Jellyfin - http://thebox-ts:8096",
    "Jellyfin (YouTube) - http://thebox-ts:8097",
    "Jellyfin (Vue) - http://thebox-ts:8098",
    "Kanboard - https://kanboard.suda.codes",
    "Komga - http://thebox:3359",
    "Lidarr - http://thebox:3357",
    "Linkding - http://thebox:3341",
    "Lychee - https://lychee.sudacode.com",
    "Medusa - https://medusa.suda.codes",
    "Metamask - https://portfolio.metamask.io/",
    "MeTube - https://metube.suda.codes",
    "Netdata - https://netdata.suda.codes",
    "Navidrome - http://thebox:3346",
    "Nextcloud - https://nextcloud.suda.codes",
    "Nzbhydra - http://thebox:5076",
    "OpenBooks - https://openbooks.suda.codes",
    "Pihole - http://pi5/admin",
    "qBittorrent - https://qbit.suda.codes",
    "Paperless - https://paperless.suda.codes",
    "Photoprism - http://thebox:2342",
    "Portainer - http://thebox:10003",
    "Prometheus - https://prometheus.suda.codes",
    "Pterodactyl - https://gameserver.suda.codes",
    "Radarr - https://radarr.suda.codes",
    "Reddit (Anime) - https://www.reddit.com/r/anime/",
    "Reddit (Selfhosted) - https://www.reddit.com/r/selfhosted/",
    "Robinhood - https://robinhood.com",
    "Sabnzbd - https://sabnzbd.suda.codes",
    "Sonarr - https://sonarr.suda.codes",
    "Sonarr Anime - http://thebox:6969",
    "Skinport - https://skinport.com/",
    "Steamfolio - https://steamfolio.com/CustomPortfolio",
    "Sudacode - https://sudacode.com",
    "Tailscale - https://login.tailscale.com/admin/machines",
    "Tanoshi - http://thebox:3356",
    "Tranga - http://thebox:9555",
    "Tdarr - http://thebox:8265/",
    "TD Ameritrade - https://invest.ameritrade.com",
    "ThinkOrSwim - https://trade.thinkorswim.com",
    "Umami - https://umami.sudacode.com",
    "Vaultwarden - https://vault.suda.codes",
    "Wallabag - https://wallabag.suda.codes",
    "Youtube - https://youtube.com",
]

if __name__ == "__main__":
    if len(argv) < 2:
        print("Usage: rofi-open.py <window_type>")
        sysexit(1)
    open_type = argv[1].strip().lower()
    if open_type not in OPEN_TYPES:
        print("Invalid open type: {}".format(open_type))
        print("Valid open types: {}".format(", ".join(OPEN_TYPES)))
        sysexit(1)
    try:
        r = Rofi(
            config_file="~/.config/rofi/aniwrapper-dracula.rasi",
            theme_str="configuration {dpi: 144;} window {width: 75%;} listview {columns: 2; lines: 10;}",
        )
    except Exception as e:
        print(e)
        sysexit(1)
    index, key = r.select("Select link to open", OPTIONS, rofi_args=["-i"])
    if index < 0 or index >= len(OPTIONS):
        print("Invalid index:", index)
        sysexit(1)
    url = OPTIONS[index].split("-")
    if isinstance(url, list) and len(url) > 2:
        url = "-".join(url[1:]).strip()
    else:
        url = url[1].strip()
    print("Opening:", url)
    """Open a URL in browser: <BROWSER>."""
    if open_type == "tab":
        with Popen([BROWSER, url]) as proc:
            proc.wait()
    else:
        with Popen([BROWSER, "--new-window", url]) as proc:
            proc.wait()
        # with Popen([BROWSER, "--target", open_type, url]) as proc:
