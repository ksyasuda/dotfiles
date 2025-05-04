package main

import (
	"bytes"
	"fmt"
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
	cmd := exec.Command("notify-send", title, body)
	if err := cmd.Run(); err != nil {
		fmt.Fprintf(os.Stderr, "notify error: %v\n", err)
	}
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
		{"2. Select a region and copy to clipboard", []string{"sh", "-c", "slurp | grim -g - - | wl-copy"}},
		{"3. Whole screen", []string{"grim", tmpScreenshot}},
		{"4. Current window", []string{"sh", "-c", fmt.Sprintf("hyprctl -j activewindow | jq -r '\\.at[0],(\\.at[1]) \\.size[0]x(\\.size[1])' | grim -g - '%s'", tmpScreenshot)}},
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
		notify("Screenshot copied to clipboard", "")
		os.Exit(0)
	}

	if err := exec.Command(selected.Cmd[0], selected.Cmd[1:]...).Run(); err != nil {
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
	if err := os.Rename(tmpScreenshot, dest); err != nil {
		notify(fmt.Sprintf("Failed to save screenshot to %s", dest), "")
	} else {
		notify(fmt.Sprintf("Screenshot saved to %s", dest), "")
	}
}
