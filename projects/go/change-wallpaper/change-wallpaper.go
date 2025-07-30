package main

import (
	"encoding/json"
	"fmt"
	"io"
	"math/rand"
	"net/http"
	"net/url"
	"os"
	"os/exec"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
	"time"
)

const (
	wallhavenAPI = "https://wallhaven.cc/api/v1"
	wallpaperDir = "Pictures/wallpapers/wallhaven"
)

type Config struct {
	Topics       []string `json:"topics"`
	Keep         int      `json:"keep"`         // Number of wallpapers to keep (0 = never delete)
	WallpaperDir string   `json:"wallpaperDir"` // Directory to store wallpapers
}

var defaultTopics = []string{
	"lofi",
}

const defaultKeep = 10

func loadConfig() (topics []string, keep int, wallpaperDir string) {
	homeDir, err := os.UserHomeDir()
	if err != nil {
		return defaultTopics, defaultKeep, wallpaperDir
	}
	configPath := filepath.Join(homeDir, ".config", "change-wallpaper", "config.json")
	file, err := os.Open(configPath)
	if err != nil {
		return defaultTopics, defaultKeep, wallpaperDir
	}
	defer file.Close()
	var cfg Config
	if err := json.NewDecoder(file).Decode(&cfg); err != nil {
		return defaultTopics, defaultKeep, wallpaperDir
	}
	if len(cfg.Topics) == 0 {
		cfg.Topics = defaultTopics
	}
	if cfg.Keep < 0 {
		cfg.Keep = defaultKeep
	}
	if cfg.WallpaperDir == "" {
		cfg.WallpaperDir = wallpaperDir
	}
	return cfg.Topics, cfg.Keep, cfg.WallpaperDir
}

type WallhavenResponse struct {
	Data []struct {
		Path string `json:"path"`
	} `json:"data"`
}

func main() {
	// Initialize random source
	r := rand.New(rand.NewSource(time.Now().UnixNano()))

	// Load topics from config or use defaults
	topics, keep, configWallpaperDir := loadConfig()

	// Check if a file path was provided as argument
	if len(os.Args) > 1 {
		imgPath := os.Args[1]
		if _, err := os.Stat(imgPath); err == nil {
			changeWallpaper(imgPath, "")
			return
		}
	}

	// Create wallpaper directory if it doesn't exist
	homeDir, err := os.UserHomeDir()
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error getting home directory: %v\n", err)
		os.Exit(1)
	}

	// Use config wallpaper directory if set, otherwise use default
	var wallpaperPath string
	if configWallpaperDir != "" {
		if strings.HasPrefix(configWallpaperDir, "~/") {
			wallpaperPath = filepath.Join(homeDir, configWallpaperDir[2:])
		} else if configWallpaperDir == "~" {
			wallpaperPath = homeDir
		} else {
			wallpaperPath = configWallpaperDir
		}
	} else {
		wallpaperPath = filepath.Join(homeDir, wallpaperDir)
	}
	if err := os.MkdirAll(wallpaperPath, 0755); err != nil {
		fmt.Fprintf(os.Stderr, "Error creating wallpaper directory: %v\n", err)
		os.Exit(1)
	}

	// Download and set new wallpaper
	newWallpaper, topic := downloadRandomWallpaper(wallpaperPath, r, topics, keep)
	if newWallpaper != "" {
		changeWallpaper(newWallpaper, topic)
	} else {
		notify("Failed to download new wallpaper", "critical")
		os.Exit(1)
	}
}

func downloadRandomWallpaper(wallpaperPath string, r *rand.Rand, topics []string, keep int) (string, string) {
	// Clean up old wallpapers before downloading a new one, if keep > 0
	if keep > 0 {
		files, err := os.ReadDir(wallpaperPath)
		if err == nil && len(files) > keep {
			type fileInfo struct {
				name string
				mod  int64
			}
			var fileInfos []fileInfo
			for _, f := range files {
				if !f.IsDir() {
					info, err := f.Info()
					if err == nil {
						fileInfos = append(fileInfos, fileInfo{f.Name(), info.ModTime().Unix()})
					}
				}
			}
			// Sort by mod time, newest first
			sort.Slice(fileInfos, func(i, j int) bool { return fileInfos[i].mod > fileInfos[j].mod })
			for _, f := range fileInfos[keep:] {
				os.Remove(filepath.Join(wallpaperPath, f.name))
			}
		}
	}
	// If keep == 0, never delete

	// Select random topic
	topic := topics[r.Intn(len(topics))]
	var query string
	var displayName string

	// Check if the topic is a tag ID with name
	if tagRegex := regexp.MustCompile(`^(\d+)\s*-\s*(.+)$`); tagRegex.MatchString(topic) {
		matches := tagRegex.FindStringSubmatch(topic)
		query = fmt.Sprintf("id:%s", matches[1])
		displayName = strings.TrimSpace(matches[2])
	} else {
		query = url.QueryEscape(topic)
		displayName = topic
	}

	fmt.Fprintf(os.Stderr, "Searching for wallpapers related to: %s\n", displayName)

	// Get wallpapers from Wallhaven API
	resp, err := http.Get(fmt.Sprintf("%s/search?q=%s&purity=100&categories=110&sorting=random", wallhavenAPI, query))
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error fetching from Wallhaven: %v\n", err)
		return "", ""
	}
	defer resp.Body.Close()

	// Parse response
	var wallhavenResp WallhavenResponse
	if err := json.NewDecoder(resp.Body).Decode(&wallhavenResp); err != nil {
		fmt.Fprintf(os.Stderr, "Error parsing response: %v\n", err)
		return "", ""
	}

	if len(wallhavenResp.Data) == 0 {
		fmt.Fprintf(os.Stderr, "No wallpapers found for topic: %s\n", displayName)
		return "", ""
	}

	// Select a random image from the results
	randomIndex := r.Intn(len(wallhavenResp.Data))
	wallpaperURL := wallhavenResp.Data[randomIndex].Path
	orig := filepath.Base(wallpaperURL)
	sanitizedTopic := strings.ReplaceAll(strings.ToLower(displayName), " ", "-")
	filename := fmt.Sprintf("%s-%s", sanitizedTopic, orig)
	filepath := filepath.Join(wallpaperPath, filename)

	fmt.Fprintf(os.Stderr, "Downloading: %s\n", filename)

	resp, err = http.Get(wallpaperURL)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error downloading wallpaper: %v\n", err)
		return "", ""
	}
	defer resp.Body.Close()

	file, err := os.Create(filepath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "Error creating file: %v\n", err)
		return "", ""
	}
	defer file.Close()

	if _, err := io.Copy(file, resp.Body); err != nil {
		fmt.Fprintf(os.Stderr, "Error saving wallpaper: %v\n", err)
		return "", ""
	}

	return filepath, displayName
}

func changeWallpaper(wallpaperPath, topic string) {
	// Save current wallpaper path
	homeDir, _ := os.UserHomeDir()
	wallpaperFile := filepath.Join(homeDir, ".wallpaper")
	if err := os.WriteFile(wallpaperFile, []byte(wallpaperPath), 0644); err != nil {
		fmt.Fprintf(os.Stderr, "Error saving wallpaper path: %v\n", err)
	}

	// Change wallpaper using hyprctl
	cmd := exec.Command("hyprctl", "hyprpaper", "reload", ","+wallpaperPath)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error changing wallpaper: %v\n", err)
	}

	// Send notification with wallpaper as icon
	filename := filepath.Base(wallpaperPath)
	message := fmt.Sprintf("Wallpaper changed to %s", filename)
	if topic != "" {
		message += fmt.Sprintf(" (%s)", topic)
	}
	notifyWithIcon(message, "normal", wallpaperPath)
}

func notify(message, urgency string) {
	cmd := exec.Command("notify-send", "-a", "change-wallpaper", "-i", "hyprpaper", "-u", urgency, "change-wallpaper.go", message)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error sending notification: %v\n", err)
	}
}

// notifyWithIcon sends a notification with a custom icon (wallpaper image)
func notifyWithIcon(message, urgency, iconPath string) {
	cmd := exec.Command("notify-send", "-a", "change-wallpaper", "-i", iconPath, "-u", urgency, "change-wallpaper.go", message)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "Error sending notification: %v\n", err)
	}
}
