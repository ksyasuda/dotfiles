#!/usr/bin/env bash

set -euo pipefail

location_input="${1:-Los_Angeles}"
location_query="${location_input//_/ }"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/waybar"
cache_key="${location_input//[^[:alnum:]_.-]/_}"
geo_cache_file="$cache_dir/weather-geo-${cache_key}.json"
weather_cache_file="$cache_dir/weather-${cache_key}.json"

json_escape() {
  jq -Rsa .
}

emit_json() {
  local text="$1"
  local tooltip="$2"

  printf '{"text":%s,"tooltip":%s}\n' \
    "$(printf '%s' "$text" | json_escape)" \
    "$(printf '%s' "$tooltip" | json_escape)"
}

emit_cached_or_error() {
  if [[ -f "$weather_cache_file" ]]; then
    cat "$weather_cache_file"
    return
  fi

  emit_json "weather unavailable" "weather service unavailable"
}

url_encode() {
  jq -rn --arg value "$1" '$value | @uri'
}

weather_icon() {
  local code="$1"
  local is_day="$2"

  case "$code" in
    0) [[ "$is_day" == "1" ]] && printf '☀' || printf '☾' ;;
    1 | 2) [[ "$is_day" == "1" ]] && printf '⛅' || printf '☁' ;;
    3) printf '☁' ;;
    45 | 48) printf '🌫' ;;
    51 | 53 | 55 | 56 | 57) printf '🌦' ;;
    61 | 63 | 65 | 66 | 67 | 80 | 81 | 82) printf '🌧' ;;
    71 | 73 | 75 | 77 | 85 | 86) printf '🌨' ;;
    95 | 96 | 99) printf '⛈' ;;
    *) printf '☁' ;;
  esac
}

weather_description() {
  case "$1" in
    0) printf 'Clear sky' ;;
    1) printf 'Mainly clear' ;;
    2) printf 'Partly cloudy' ;;
    3) printf 'Overcast' ;;
    45 | 48) printf 'Fog' ;;
    51) printf 'Light drizzle' ;;
    53) printf 'Drizzle' ;;
    55) printf 'Dense drizzle' ;;
    56 | 57) printf 'Freezing drizzle' ;;
    61) printf 'Slight rain' ;;
    63) printf 'Rain' ;;
    65) printf 'Heavy rain' ;;
    66 | 67) printf 'Freezing rain' ;;
    71) printf 'Slight snow' ;;
    73) printf 'Snow' ;;
    75) printf 'Heavy snow' ;;
    77) printf 'Snow grains' ;;
    80) printf 'Rain showers' ;;
    81) printf 'Rain showers' ;;
    82) printf 'Heavy rain showers' ;;
    85 | 86) printf 'Snow showers' ;;
    95) printf 'Thunderstorm' ;;
    96 | 99) printf 'Thunderstorm with hail' ;;
    *) printf 'Weather unavailable' ;;
  esac
}

load_geocode() {
  if [[ -f "$geo_cache_file" ]]; then
    cat "$geo_cache_file"
    return
  fi

  local encoded_query response
  encoded_query="$(url_encode "$location_query")"
  response="$(
    curl \
      --silent \
      --show-error \
      --fail \
      --max-time 10 \
      "https://geocoding-api.open-meteo.com/v1/search?name=${encoded_query}&count=1&language=en&format=json" 2>/dev/null || true
  )"

  if jq -e '.results[0] | .name and .latitude and .longitude and .timezone' >/dev/null <<<"$response"; then
    jq -c '.results[0] | {name, admin1, country, latitude, longitude, timezone}' <<<"$response" | tee "$geo_cache_file"
    return
  fi

  return 1
}

fetch_weather() {
  local latitude="$1"
  local longitude="$2"
  local timezone="$3"

  curl \
    --silent \
    --show-error \
    --fail \
    --max-time 10 \
    "https://api.open-meteo.com/v1/forecast?latitude=${latitude}&longitude=${longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,weather_code,wind_speed_10m,is_day&timezone=$(url_encode "$timezone")" 2>/dev/null || true
}

format_weather() {
  local place_json="$1"
  local weather_json="$2"
  local name region place code is_day icon description temperature feels_like humidity wind text tooltip

  name="$(jq -r '.name' <<<"$place_json")"
  region="$(jq -r '.admin1 // empty' <<<"$place_json")"
  place="$name"
  if [[ -n "$region" ]]; then
    place+=", $region"
  fi

  code="$(jq -r '.current.weather_code' <<<"$weather_json")"
  is_day="$(jq -r '.current.is_day' <<<"$weather_json")"
  icon="$(weather_icon "$code" "$is_day")"
  description="$(weather_description "$code")"
  temperature="$(jq -r '.current.temperature_2m | round | "\(.)"' <<<"$weather_json")"
  feels_like="$(jq -r '.current.apparent_temperature | round | "\(.)"' <<<"$weather_json")"
  humidity="$(jq -r '.current.relative_humidity_2m | round | "\(.)"' <<<"$weather_json")"
  wind="$(jq -r '.current.wind_speed_10m | round | "\(.)"' <<<"$weather_json")"

  text="${icon} ${temperature}°C"
  tooltip="${place}: ${description}. Feels like ${feels_like}°C, humidity ${humidity}%, wind ${wind} km/h"

  emit_json "$text" "$tooltip"
}

mkdir -p "$cache_dir"

if ! place_json="$(load_geocode)"; then
  emit_cached_or_error
  exit 0
fi

latitude="$(jq -r '.latitude' <<<"$place_json")"
longitude="$(jq -r '.longitude' <<<"$place_json")"
timezone="$(jq -r '.timezone' <<<"$place_json")"

weather_json="$(fetch_weather "$latitude" "$longitude" "$timezone")"

if jq -e '.current | .temperature_2m and .relative_humidity_2m and .apparent_temperature and .weather_code and .wind_speed_10m and .is_day' >/dev/null <<<"$weather_json"; then
  format_weather "$place_json" "$weather_json" | tee "$weather_cache_file"
  exit 0
fi

emit_cached_or_error
