package main

import (
	"encoding/json"
	"fmt"
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
	data, err := os.ReadFile(path)
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

	// Override BROWSER if set in config
	if cfg.Browser != "" {
		BROWSER = cfg.Browser
	}

	// Override OPTIONS if set in config
	if len(cfg.Options) > 0 {
		OPTIONS = cfg.Options
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
