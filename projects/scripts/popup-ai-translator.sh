#!/bin/bash

# Japanese Learning Assistant using OpenRouter API
# Uses Google Gemini Flash 2.0 for AJATT-aligned Japanese analysis

# Configuration
OPENROUTER_API_KEY="${OPENROUTER_API_KEY:-}"
MODEL="${OPENROUTER_MODEL:-google/gemini-2.0-flash-001}"
API_URL="https://openrouter.ai/api/v1/chat/completions"

if [[ -z $OPENROUTER_API_KEY && -f "$HOME/.openrouterapikey" ]]; then
    OPENROUTER_API_KEY="$(<"$HOME/.openrouterapikey")"
fi

# System prompt for Japanese learning
SYSTEM_PROMPT='You are my Japanese-learning assistant. Help me acquire Japanese through deep, AJATT-aligned analysis.

For every input, output exactly:

1. Japanese Input (Verbatim)

Repeat the original text exactly. Correct only critical OCR/punctuation errors.

2. Natural English Translation

Accurate and natural. Preserve tone, formality, and nuance. Avoid literalism.

3. Word-by-Word Breakdown

For each unit:

- Vocabulary: Part of speech + concise definition
- Grammar: Particles, conjugations, constructions (contextual usage)
- Nuance: Implied meaning, connotation, emotional tone, differences from similar expressions

Core Principles:

- Preserve native phrasing—never oversimplify
- Highlight subtle grammar, register shifts, and pragmatic implications
- Encourage pattern recognition; provide contrastive examples (e.g., ～のに vs ～けど)
- Focus on real Japanese usage

Rules:

- English explanations only (no romaji)
- Clean, structured formatting; calm, precise tone
- No filler text

Optional Additions (only when valuable):

- Synonyms, formality/register notes, cultural insights, common mistakes, extra native examples

Goal: Deep comprehension, natural grammar internalization, nuanced vocabulary, progress toward Japanese-only understanding.'

# Check for API key
if [[ -z "$OPENROUTER_API_KEY" ]]; then
    zenity --error --text="OPENROUTER_API_KEY environment variable is not set." --title="Error" 2>/dev/null
    exit 1
fi

# Get input from zenity
input=$(zenity --entry \
    --title="Japanese Assistant" \
    --text="Enter Japanese text to analyze:" \
    --width=500 \
    2>/dev/null)

# Exit if no input
if [[ -z "$input" ]]; then
    exit 0
fi

# Show loading notification
notify-send -t 0 -a "Japanese Assistant" "Processing..." "Analyzing: ${input:0:50}..." &
notif_pid=$!

# Escape special characters for JSON
escape_json() {
    local str="$1"
    str="${str//\\/\\\\}"
    str="${str//\"/\\\"}"
    str="${str//$'\n'/\\n}"
    str="${str//$'\r'/\\r}"
    str="${str//$'\t'/\\t}"
    printf '%s' "$str"
}

escaped_input=$(escape_json "$input")
escaped_system=$(escape_json "$SYSTEM_PROMPT")

# Build JSON payload
json_payload=$(
    cat <<EOF
{
  "model": "$MODEL",
  "messages": [
    {
      "role": "system",
      "content": "$escaped_system"
    },
    {
      "role": "user",
      "content": "$escaped_input"
    }
  ],
  "temperature": 0.7
}
EOF
)

# Make API request
response=$(curl -s -X POST "$API_URL" \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENROUTER_API_KEY" \
    -H "HTTP-Referer: https://github.com/sudacode/scripts" \
    -H "X-Title: Japanese Learning Assistant" \
    -d "$json_payload")

# Close loading notification
pkill -f "notify-send.*Processing.*Analyzing" 2>/dev/null

# Check for errors
if [[ -z "$response" ]]; then
    zenity --error --text="No response from API" --title="Error" 2>/dev/null
    exit 1
fi

# Parse response and extract content using Python (handles Unicode properly)
result=$(echo "$response" | python3 -c "
import json
import sys

try:
    data = json.load(sys.stdin)
    
    if 'error' in data:
        err = data['error'].get('message', 'Unknown error')
        print(f'ERROR:{err}', end='')
        sys.exit(1)
    
    content = data.get('choices', [{}])[0].get('message', {}).get('content', '')
    if not content:
        print('ERROR:Failed to parse API response', end='')
        sys.exit(1)
    
    # Decode any unicode escape sequences in the content
    try:
        content = content.encode('utf-8').decode('unicode_escape').encode('latin-1').decode('utf-8')
    except:
        pass  # Keep original if decoding fails
    
    print(content, end='')
except json.JSONDecodeError as e:
    print(f'ERROR:Invalid JSON response: {e}', end='')
    sys.exit(1)
except Exception as e:
    print(f'ERROR:{e}', end='')
    sys.exit(1)
")

# Check for errors from Python parsing
if [[ "$result" == ERROR:* ]]; then
    error_msg="${result#ERROR:}"
    zenity --error --text="$error_msg" --title="Error" 2>/dev/null
    exit 1
fi

content="$result"

if [[ -z "$content" ]]; then
    zenity --error --text="Empty response from API" --title="Error" 2>/dev/null
    exit 1
fi

# Display result in zenity
zenity --text-info \
    --title="Japanese Analysis" \
    --width=800 \
    --height=600 \
    --font="monospace" \
    <<<"$content" 2>/dev/null
