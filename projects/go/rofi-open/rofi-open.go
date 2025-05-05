package main

import (
	"encoding/json"
	"fmt"
	"io/ioutil"
	"os"
	"os/exec"
	"path/filepath"
	"strings"
)

type Config struct {
	Browser         string   `json:"browser"`
	DefaultOpenType string   `json:"default_open_type"`
	Options         []string `json:"options"`
}

func loadConfig() (*Config, error) {
	home, err := os.UserHomeDir()
	if err != nil {
		return nil, err
	}
	path := filepath.Join(home, ".config", "rofi-open", "config.json")
	data, err := ioutil.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var cfg Config
	if err := json.Unmarshal(data, &cfg); err != nil {
		return nil, err
	}
	return &cfg, nil
}

var (
	BROWSER    = "zen-browser"
	OPEN_TYPES = []string{"window", "tab"}
	OPTIONS    = []string{
		"Anilist - https://anilist.co/home",
		"Authentik - https://auth.suda.codes",
		"Capital One - https://myaccounts.capitalone.com/accountSummary",
		"Chase Bank - https://secure03ea.chase.com/",
		"ChatGPT - https://chat.openai.com/chat",
		"Cloudflare - https://dash.cloudflare.com/",
		"CoinMarketCap - https://coinmarketcap.com/",
		"Deemix - http://pve-main:3358",
		"F1TV - https://f1tv.suda.codes",
		"Fidelity - https://login.fidelity.com/",
		"Gitea - https://gitea.suda.codes",
		"Github - https://github.com",
		"Ghostfolio - http://pve-main:3334",
		"Grafana - http://pve-main:3000",
		"Homepage - https://suda.codes",
		"Immich - https://immich.suda.codes",
		"Jellyseerr - https://jellyseerr.suda.codes",
		"Jellyfin - https://jellyfin.suda.codes",
		"Jellyfin (YouTube) - http://pve-main:8097",
		"Jellyfin (Vue) - http://pve-main:8098",
		"Karakeep - https://karakeep.suda.codes",
		"Komga - http://oracle-vm:3332",
		"Lidarr - http://pve-main:3357",
		"MeTube - https://metube.suda.codes",
		"Navidrome - https://navidrome.suda.codes",
		"Nzbhydra - https://nzbhydra.suda.codes",
		"OpenBooks - https://openbooks.suda.codes",
		"Pihole - https://pihole.suda.codes/admin",
		"Pihole2 - https://pihole2.suda.codes/admin",
		"Proxmox - https://thebox.unicorn-ilish.ts.net",
		"qBittorrent - https://qbit.suda.codes",
		"Paperless - https://paperless.suda.codes",
		"Prometheus - http://prometheus:9090",
		"Radarr - https://radarr.suda.codes",
		"Reddit (Anime) - https://www.reddit.com/r/anime/",
		"Reddit (Selfhosted) - https://www.reddit.com/r/selfhosted/",
		"Sabnzbd - https://sabnzbd.suda.codes",
		"Sonarr - https://sonarr.suda.codes",
		"Sonarr Anime - http://pve-main:6969",
		"Sudacode - https://sudacode.com",
		"Tailscale - https://login.tailscale.com/admin/machines",
		"Tranga - http://pve-main:9555",
		"Truenas - https://truenas.unicorn-ilish.ts.net",
		"Tdarr - https://tdarr.suda.codes",
		"Umami - https://umami.sudacode.com",
		"Vaultwarden - https://vault.suda.codes",
		"Wallabag - https://wallabag.suda.codes",
		"Youtube - https://youtube.com",
	}
)

func main() {
	// Load config
	cfg, err := loadConfig()
	if err != nil {
		fmt.Println("Error loading config:", err)
		os.Exit(1)
	}

	var openType string
	cliArgProvided := len(os.Args) >= 2

	if cliArgProvided {
		openType = strings.ToLower(strings.TrimSpace(os.Args[1]))
		valid := false
		for _, t := range OPEN_TYPES {
			if openType == t {
				valid = true
				break
			}
		}
		if !valid {
			fmt.Printf("Invalid open type: %s\n", openType)
			fmt.Printf("Valid open types: %s\n", strings.Join(OPEN_TYPES, ", "))
			os.Exit(1)
		}
	} else if cfg.DefaultOpenType != "" {
		openType = strings.ToLower(strings.TrimSpace(cfg.DefaultOpenType))
		valid := false
		for _, t := range OPEN_TYPES {
			if openType == t {
				valid = true
				break
			}
		}
		if !valid {
			fmt.Printf("Invalid default_open_type in config: %s\n", openType)
			fmt.Printf("Valid open types: %s\n", strings.Join(OPEN_TYPES, ", "))
			os.Exit(1)
		}
	} else {
		fmt.Println("Usage: rofi-open <window_type>")
		fmt.Println("Or set \"default_open_type\" in your config file.")
		os.Exit(1)
	}

	// Prepare display options for rofi
	displayOptions := make([]string, len(OPTIONS))
	for i, opt := range OPTIONS {
		parts := strings.SplitN(opt, "-", 2)
		displayOptions[i] = strings.TrimSpace(parts[0])
	}
	rofiInput := strings.Join(displayOptions, "\n")

	rofiCmd := exec.Command(
		"rofi",
		"-dmenu",
		"-i",
		"-theme", os.ExpandEnv("$HOME/.config/rofi/launchers/type-2/style-1.rasi"),
		"-theme-str", "window {width: 25%;} listview {columns: 1; lines: 6;}",
		"-p", "Select link to open:",
	)
	rofiCmd.Stdin = strings.NewReader(rofiInput)
	out, err := rofiCmd.Output()
	if err != nil {
		fmt.Println("Error running rofi:", err)
		os.Exit(1)
	}
	selection := strings.TrimSpace(string(out))
	if selection == "" {
		fmt.Println("No selection made.")
		os.Exit(1)
	}

	// Find the selected option's URL
	var url string
	for _, opt := range OPTIONS {
		parts := strings.SplitN(opt, "-", 2)
		name := strings.TrimSpace(parts[0])
		if name == selection && len(parts) > 1 {
			url = strings.TrimSpace(parts[1])
			break
		}
	}
	if url == "" {
		fmt.Println("Could not find URL for selection.")
		os.Exit(1)
	}

	fmt.Println("Opening:", url)
	var cmd *exec.Cmd
	if openType == "tab" {
		cmd = exec.Command(BROWSER, url)
	} else {
		cmd = exec.Command(BROWSER, "--new-window", url)
	}
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	if err := cmd.Run(); err != nil {
		fmt.Println("Error opening browser:", err)
		os.Exit(1)
	}
}
