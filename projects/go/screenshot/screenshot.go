package main

import (
	"bytes"
	"encoding/json"
	"fmt"
	"io"
	"log"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

var (
	scriptName      = filepath.Base(os.Args[0])
	tmpDir          = os.TempDir()
	defaultFilename = "screenshot.png"
	tmpScreenshot   = filepath.Join(tmpDir, defaultFilename)
	requirements    = []string{"grim", "slurp", "rofi", "zenity", "wl-copy", "jq", "hyprctl", "swappy", "notify-send"}
)

type Option struct {
	Desc string
	Cmd  []string
}

func notify(body, title string) {
	if title == "" {
		title = scriptName
	}
	cmd := exec.Command("notify-send", "-a", "Screenshot", "-i", "camera", title, body)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "notify error: %v\n", err)
	}
}

func notifyWithIcon(iconPath, body, title string) {
	if title == "" {
		title = scriptName
	}
	resizedPath := iconPath + ".icon.png"
	resizeCmd := exec.Command("convert", iconPath, "-resize", "128x128^", "-gravity", "center", "-extent", "128x128", resizedPath)
	if err := resizeCmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "resize error: %v\n", err)
		resizedPath = iconPath // fallback to original if resize fails
	}
	cmd := exec.Command("notify-send", "-a", "Screenshot", "--hint", "string:image-path:"+resizedPath, title, body)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "notify error: %v\n", err)
	}
	os.Remove(resizedPath)
}

func moveFile(src, dst string) error {
	in, err := os.Open(src)
	if err != nil {
		return err
	}
	defer in.Close()
	out, err := os.Create(dst)
	if err != nil {
		return err
	}
	defer out.Close()
	if _, err := io.Copy(out, in); err != nil {
		return err
	}
	return os.Remove(src)
}

func getActiveWindowGeom() (string, error) {
	type activeWindow struct {
		At   [2]int `json:"at"`
		Size [2]int `json:"size"`
	}
	cmd := exec.Command("hyprctl", "-j", "activewindow")
	out, err := cmd.Output()
	if err != nil {
		return "", err
	}
	var win activeWindow
	if err := json.Unmarshal(out, &win); err != nil {
		return "", err
	}
	return fmt.Sprintf("%d,%d %dx%d", win.At[0], win.At[1], win.Size[0], win.Size[1]), nil
}

func checkDeps() {
	for _, cmd := range requirements {
		if _, err := exec.LookPath(cmd); err != nil {
			log.Fatalf("Error: %s is not installed. Please install it first.", cmd)
		}
	}
}

func main() {
	checkDeps()
	options := []Option{
		{"1. Select a region and save", []string{"sh", "-c", fmt.Sprintf("slurp | grim -g - '%s'", tmpScreenshot)}},
		{"2. Select a region and copy to clipboard", []string{"sh", "-c", fmt.Sprintf("slurp | grim -g - '%s' && wl-copy < '%s'", tmpScreenshot, tmpScreenshot)}},
		{"3. Whole screen", []string{"grim", tmpScreenshot}},
		{"4. Current window", []string{"current-window"}},
		{"5. Edit", []string{"sh", "-c", "slurp | grim -g - - | swappy -f -"}},
		{"6. Quit", []string{"true"}},
	}

	var menu bytes.Buffer
	for _, opt := range options {
		menu.WriteString(opt.Desc)
		menu.WriteByte('\n')
	}

	rofi := exec.Command("rofi", "-dmenu", "-i", "-p", "Enter option or select from the list", "-mesg", "Select a Screenshot Option", "-format", "i", "-theme-str", "listview {columns: 2; lines: 3;} window {width: 55%;}", "-yoffset", "30", "-xoffset", "30", "-a", "0", "-no-custom", "-location", "0")
	rofi.Stdin = &menu
	out, err := rofi.Output()
	if err != nil {
		notify("No option selected.", "")
		os.Exit(0)
	}

	choiceStr := strings.TrimSpace(string(out))
	idx, err := strconv.Atoi(choiceStr)
	if err != nil || idx < 0 || idx >= len(options) {
		notify("No option selected.", "")
		os.Exit(0)
	}

	time.Sleep(200 * time.Millisecond)
	selected := options[idx]
	if idx == 1 {
		if err := exec.Command(selected.Cmd[0], selected.Cmd[1:]...).Run(); err != nil {
			notify("An error occurred while taking the screenshot.", "")
			os.Exit(1)
		}
		notifyWithIcon(tmpScreenshot, "Screenshot copied to clipboard", "")
		os.Exit(0)
	}

	if selected.Cmd[0] == "current-window" {
		geom, err := getActiveWindowGeom()
		if err != nil {
			notify(fmt.Sprintf("Failed to get current window geometry: %v", err), "")
			os.Exit(1)
		}
		if err := exec.Command("grim", "-g", geom, tmpScreenshot).Run(); err != nil {
			notify(fmt.Sprintf("An error occurred while taking the screenshot (grim -g '%s'): %v", geom, err), "")
			os.Exit(1)
		}
	} else if err := exec.Command(selected.Cmd[0], selected.Cmd[1:]...).Run(); err != nil {
		notify("An error occurred while taking the screenshot.", "")
		os.Exit(1)
	}

	if idx == 5 {
		os.Exit(0)
	}

	notify("Screenshot saved temporarily.\nChoose where to save it permanently", "")
	zenity := exec.Command("zenity", "--file-selection", "--title=Save Screenshot", "--filename="+defaultFilename, "--save")
	fileOut, err := zenity.Output()
	if err != nil {
		os.Remove(tmpScreenshot)
		notify("Screenshot discarded", "")
		os.Exit(0)
	}

	dest := strings.TrimSpace(string(fileOut))
	if _, err := os.Stat(tmpScreenshot); os.IsNotExist(err) {
		notify(fmt.Sprintf("Screenshot file %s does not exist. Save failed.", tmpScreenshot), "")
	} else if err := moveFile(tmpScreenshot, dest); err != nil {
		notify(fmt.Sprintf("Failed to save screenshot to %s", dest), "")
	} else {
		notifyWithIcon(dest, fmt.Sprintf("Screenshot saved to %s", dest), "")
	}
}
